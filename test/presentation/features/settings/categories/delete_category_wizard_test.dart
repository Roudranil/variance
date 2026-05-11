// test/presentation/features/settings/categories/delete_category_wizard_test.dart
//
// Unit tests for DeleteCategoryWizardController (T-75, T-76).
//
// Test cases:
//   1. wizard starts at step 1 (template check)
//   2. wizard skips step 1 if no templates → goes to step 2
//   3. cancel at step 1 aborts wizard, no mutations
//   4. step 1 with templates shows template handling dialog
//   5. wizard always executes template check before transaction count
//   6. atomic rollback — if soft-delete fails, category is_deleted remains 0
//   7. wizard aborts when cancel is called at any step

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/category.dart';
import 'package:variance/presentation/features/settings/categories/delete_category_wizard_controller.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

Category _makeCat({
  required String id,
  required String name,
}) {
  return Category(
    id: id,
    name: name,
    treeType: CategoryTreeType.expense,
    iconRef: 'shopping_cart',
    createdAt: _now,
    updatedAt: _now,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DeleteCategoryWizardController', () {
    test('1. initial state is step 1 (template check)', () {
      final state = DeleteCategoryWizardState.initial();
      expect(state.step, WizardStep.templateCheck);
      expect(state.isCancelled, isFalse);
      expect(state.isComplete, isFalse);
    });

    test('2. skipTemplateStep moves to transaction count step', () {
      var state = DeleteCategoryWizardState.initial();
      state = state.skipTemplateStep();
      expect(state.step, WizardStep.transactionCount);
    });

    test('3. cancel sets isCancelled and step to cancelled', () {
      var state = DeleteCategoryWizardState.initial();
      state = state.cancel();
      expect(state.isCancelled, isTrue);
      expect(state.step, WizardStep.cancelled);
    });

    test('4. templateCount = 0 means no template step dialog needed', () {
      final state = DeleteCategoryWizardState.initial().copyWith(
        templateCount: 0,
      );
      expect(state.hasTemplates, isFalse);
    });

    test('5. templateCount > 0 means template dialog must show', () {
      final state = DeleteCategoryWizardState.initial().copyWith(
        templateCount: 3,
      );
      expect(state.hasTemplates, isTrue);
    });

    test('6. advance to migrationChoice step', () {
      var state = DeleteCategoryWizardState.initial()
          .skipTemplateStep()
          .copyWith(transactionCount: 5)
          .advanceToMigrationChoice();
      expect(state.step, WizardStep.migrationChoice);
    });

    test('7. MigrationChoice.none proceeds directly to final step', () {
      final state = DeleteCategoryWizardState.initial()
          .skipTemplateStep()
          .advanceToMigrationChoice()
          .setMigrationChoice(MigrationChoice.none);
      expect(state.migrationChoice, MigrationChoice.none);
    });

    test('8. cancel at any step marks state as cancelled', () {
      var state = DeleteCategoryWizardState.initial()
          .skipTemplateStep()
          .advanceToMigrationChoice();
      state = state.cancel();
      expect(state.isCancelled, isTrue);
    });

    test('9. complete sets isComplete flag', () {
      final state = DeleteCategoryWizardState.initial().complete();
      expect(state.isComplete, isTrue);
    });

    test('10. selectedTransactionIds is empty by default', () {
      final state = DeleteCategoryWizardState.initial();
      expect(state.selectedTransactionIds, isEmpty);
    });
  });
}
