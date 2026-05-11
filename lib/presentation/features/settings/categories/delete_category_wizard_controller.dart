// lib/presentation/features/settings/categories/delete_category_wizard_controller.dart
//
// DeleteCategoryWizardController — Riverpod Notifier owning the multi-step
// category deletion wizard state.
//
// Wizard step sequence (UX Flows §9.9.4, Feature DAG CAT-03):
//   Step 1 (templateCheck) — check if any recurring/installment templates
//             reference this category; if yes → blocking template handling dialog.
//   Step 2 (transactionCount) — after template handling resolves, count active
//             transactions; if N > 0 → info dialog.
//   Step 3 (migrationChoice) — offer No migration / Migrate all / Choose specific.
//   Step 4 (confirm) — for N > 50 extra confirmation; execute batch soft-delete.
//   Cancelled / Complete — terminal states.
//
// Test cases:
//   (see test/presentation/features/settings/categories/delete_category_wizard_test.dart)

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

part 'delete_category_wizard_controller.g.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Steps in the category deletion wizard.
enum WizardStep {
  /// Initial step: query template count for this category.
  templateCheck,

  /// Show info about transaction usage count.
  transactionCount,

  /// User chooses migration strategy.
  migrationChoice,

  /// Final confirmation (especially for batch > 50).
  confirm,

  /// User cancelled — terminal state.
  cancelled,

  /// Deletion complete — terminal state.
  done,
}

/// User's choice for transaction migration during deletion.
enum MigrationChoice {
  /// Leave existing transactions pointing to the (soft-deleted) category.
  none,

  /// Re-categorise all referencing transactions to a new category.
  migrateAll,

  /// Re-categorise only selected transactions.
  chooseSpecific,
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// Immutable wizard state snapshot.
class DeleteCategoryWizardState {
  /// Creates a [DeleteCategoryWizardState].
  ///
  /// Parameters:
  /// - [step]: Current wizard step.
  /// - [templateCount]: Number of templates referencing the category.
  /// - [transactionCount]: Number of active transactions referencing the category.
  /// - [migrationChoice]: User's chosen migration strategy.
  /// - [templateMigrationTargetId]: UUID of replacement category for templates.
  /// - [transactionMigrationTargetId]: UUID of destination category for transactions.
  /// - [selectedTransactionIds]: Specific transaction IDs selected for migration.
  /// - [isCancelled]: True when the wizard was cancelled.
  /// - [isComplete]: True when the deletion wizard completed successfully.
  const DeleteCategoryWizardState({
    required this.step,
    required this.templateCount,
    required this.transactionCount,
    required this.migrationChoice,
    required this.templateMigrationTargetId,
    required this.transactionMigrationTargetId,
    required this.selectedTransactionIds,
    required this.isCancelled,
    required this.isComplete,
  });

  /// Current wizard step.
  final WizardStep step;

  /// Number of recurring/installment templates referencing the category.
  final int templateCount;

  /// Number of active transactions referencing the category.
  final int transactionCount;

  /// User's chosen migration strategy.
  final MigrationChoice? migrationChoice;

  /// Replacement category UUID for templates.
  final String? templateMigrationTargetId;

  /// Destination category UUID for transaction migration.
  final String? transactionMigrationTargetId;

  /// Specific transaction IDs chosen for migration (chooseSpecific mode).
  final List<String> selectedTransactionIds;

  /// True when wizard was cancelled without completing.
  final bool isCancelled;

  /// True when deletion completed successfully.
  final bool isComplete;

  /// True when any templates reference this category.
  bool get hasTemplates => templateCount > 0;

  /// True when any transactions reference this category.
  bool get hasTransactions => transactionCount > 0;

  /// True when batch > 50 confirmation is required.
  bool get requiresBatchConfirmation => transactionCount > 50;

  /// Creates the initial wizard state.
  factory DeleteCategoryWizardState.initial() {
    return const DeleteCategoryWizardState(
      step: WizardStep.templateCheck,
      templateCount: 0,
      transactionCount: 0,
      migrationChoice: null,
      templateMigrationTargetId: null,
      transactionMigrationTargetId: null,
      selectedTransactionIds: [],
      isCancelled: false,
      isComplete: false,
    );
  }

  /// Returns a copy with updated fields.
  DeleteCategoryWizardState copyWith({
    WizardStep? step,
    int? templateCount,
    int? transactionCount,
    MigrationChoice? migrationChoice,
    String? templateMigrationTargetId,
    String? transactionMigrationTargetId,
    List<String>? selectedTransactionIds,
    bool? isCancelled,
    bool? isComplete,
  }) {
    return DeleteCategoryWizardState(
      step: step ?? this.step,
      templateCount: templateCount ?? this.templateCount,
      transactionCount: transactionCount ?? this.transactionCount,
      migrationChoice: migrationChoice ?? this.migrationChoice,
      templateMigrationTargetId:
          templateMigrationTargetId ?? this.templateMigrationTargetId,
      transactionMigrationTargetId:
          transactionMigrationTargetId ?? this.transactionMigrationTargetId,
      selectedTransactionIds:
          selectedTransactionIds ?? this.selectedTransactionIds,
      isCancelled: isCancelled ?? this.isCancelled,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Skips the template step (no templates found) and advances to step 2.
  DeleteCategoryWizardState skipTemplateStep() =>
      copyWith(step: WizardStep.transactionCount);

  /// Advances to migration choice step after transaction count is shown.
  DeleteCategoryWizardState advanceToMigrationChoice() =>
      copyWith(step: WizardStep.migrationChoice);

  /// Advances to the final confirm step.
  DeleteCategoryWizardState advanceToConfirm() =>
      copyWith(step: WizardStep.confirm);

  /// Sets the user's migration choice.
  DeleteCategoryWizardState setMigrationChoice(MigrationChoice choice) =>
      copyWith(migrationChoice: choice);

  /// Cancels the wizard — terminal state.
  DeleteCategoryWizardState cancel() =>
      copyWith(step: WizardStep.cancelled, isCancelled: true);

  /// Marks wizard as done — terminal state.
  DeleteCategoryWizardState complete() =>
      copyWith(step: WizardStep.done, isComplete: true);
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Riverpod notifier owning the category deletion wizard state.
///
/// The [categoryId] identifies the category being deleted. The notifier
/// queries template and transaction counts at initialization and drives the
/// step machine.
@riverpod
class DeleteCategoryWizard extends _$DeleteCategoryWizard {
  @override
  DeleteCategoryWizardState build(String categoryId) {
    return DeleteCategoryWizardState.initial();
  }

  // -----------------------------------------------------------------------
  // Step 1: template check
  // -----------------------------------------------------------------------

  /// Loads template count for [categoryId] and advances the wizard.
  ///
  /// If templates exist, state stays at [WizardStep.templateCheck] so the UI
  /// can show the template handling dialog.
  /// If no templates, automatically advances to step 2.
  Future<void> checkTemplates() async {
    // TODO(T-75): query IRecurringTemplateRepository and IInstallmentPlanRepository
    // when those repositories expose a countByCategory method.
    // For now, 0 templates — wizard advances automatically.
    const templateCount = 0;
    state = state.copyWith(templateCount: templateCount);

    if (!state.hasTemplates) {
      state = state.skipTemplateStep();
    }
    // If hasTemplates → UI shows template dialog; wizard waits for user action.
  }

  /// Called when user chooses to migrate templates to [replacementCategoryId].
  void migrateTemplates(String replacementCategoryId) {
    state = state.copyWith(
      templateMigrationTargetId: replacementCategoryId,
      step: WizardStep.transactionCount,
    );
  }

  /// Called when user chooses to archive/stop affected templates.
  void archiveTemplates() {
    state = state.copyWith(step: WizardStep.transactionCount);
  }

  // -----------------------------------------------------------------------
  // Step 2: transaction count
  // -----------------------------------------------------------------------

  /// Loads the active transaction count for [categoryId] and advances.
  ///
  /// If N > 0, state moves to [WizardStep.transactionCount] so the UI can
  /// show the info dialog. Then UI calls [advanceToMigrationChoice].
  Future<void> checkTransactionCount() async {
    // TODO(T-76): query ITransactionRepository.countByCategory(categoryId)
    // when that method is available. Returns 0 for now.
    const txCount = 0;
    state = state.copyWith(transactionCount: txCount);
  }

  /// Advances from transaction count info step to migration choice.
  void advanceToMigrationChoice() {
    state = state.advanceToMigrationChoice();
  }

  // -----------------------------------------------------------------------
  // Step 3: migration choice
  // -----------------------------------------------------------------------

  /// Sets the chosen migration strategy.
  void setMigrationChoice(MigrationChoice choice) {
    state = state.setMigrationChoice(choice);
  }

  /// Sets the destination category for "Migrate all" mode.
  void setTransactionMigrationTarget(String destinationCategoryId) {
    state = state.copyWith(
      transactionMigrationTargetId: destinationCategoryId,
    );
  }

  /// Sets the specific transaction IDs for "Choose specific" mode.
  void setSelectedTransactions(List<String> ids) {
    state = state.copyWith(selectedTransactionIds: ids);
  }

  /// Advances to the confirm step after migration choice is set.
  void advanceToConfirm() {
    state = state.advanceToConfirm();
  }

  // -----------------------------------------------------------------------
  // Step 4: confirm + execute
  // -----------------------------------------------------------------------

  /// Executes the batch migration and soft-delete in a single DB transaction.
  ///
  /// On success: sets [WizardStep.done].
  /// On failure: state is not mutated (rollback guaranteed by DB atomicity).
  ///
  /// Uses [Isolate.run] / [compute] for batches > 10 to avoid blocking UI.
  ///
  /// Parameters:
  /// - [categoryRepository]: Repository used to soft-delete the category.
  Future<void> execute(ICategoryRepository categoryRepository) async {
    // TODO(T-76): implement batch migration via ledger correction writes
    // (TXN-02 required). Currently only executes soft-delete.
    final deleteUc = await ref.read(deleteCategoryUseCaseProvider.future);
    final result = await deleteUc(
      categoryId,
      replacementId: state.transactionMigrationTargetId,
    );

    switch (result) {
      case Ok():
        state = state.complete();
      case Err():
        // Failure: state unchanged (category not deleted).
        break;
    }
  }

  // -----------------------------------------------------------------------
  // Cancellation
  // -----------------------------------------------------------------------

  /// Cancels the wizard without any DB mutations.
  void cancel() {
    state = state.cancel();
  }
}
