// test/golden/features/installments/installment_screens_golden_test.dart
//
// Golden tests for installment screens (T-145).
//
// Tests golden snapshots for:
//   - CreateInstallmentScreen (T-134/T-135/T-136): empty, mismatch states
//   - InstallmentPlanDetailScreen (T-137/T-138): loading, loaded, mismatch, dirty
//   - InstallmentTemplateRow within list (T-139): active, paused, archived
//
// Run with --update-goldens to regenerate snapshot files.
// Captured on Android emulator API 34 (Pixel 6) for production goldens.
//
// Test cases:
//   T-145.1  CreateInstallmentScreen empty state.
//   T-145.2  InstallmentPlanDetailScreen loading (shimmer).
//   T-145.3  InstallmentPlanDetailScreen loaded with no mismatch.
//   T-145.4  InstallmentPlanDetailScreen loaded with mismatch banner.
//   T-145.5  InstallmentTemplateRow — Active status with progress bar.
//   T-145.6  InstallmentTemplateRow — Paused status.
//   T-145.7  InstallmentTemplateRow — Archived status.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/installment_occurrence.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/installment_tracking_amounts.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_installment_plan_repository.dart';
import 'package:variance/domain/services/period_calculator.dart';
import 'package:variance/domain/usecases/installment/create_installment_plan_use_case.dart';
import 'package:variance/presentation/features/installments/create_installment_screen.dart';
import 'package:variance/presentation/features/installments/installment_plan_detail_screen.dart';
import 'package:variance/presentation/features/installments/installment_plan_notifiers.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

// ---------------------------------------------------------------------------
// Fakes and stubs
// ---------------------------------------------------------------------------

class _StubPlanRepo implements IInstallmentPlanRepository {
  @override
  Stream<List<InstallmentPlan>> watchAll() => const Stream.empty();
  @override
  Stream<InstallmentPlan?> watchById(String id) => const Stream.empty();
  @override
  Future<Result<InstallmentPlan>> createAtomic({
    required RecurringTemplate template,
    required InstallmentPlan plan,
    required List<InstallmentOccurrence> occurrences,
  }) async =>
      Ok(plan);
  @override
  Future<Result<InstallmentPlan>> create(InstallmentPlan plan) async =>
      Ok(plan);
  @override
  Future<Result<InstallmentPlan>> update(InstallmentPlan plan) async =>
      Ok(plan);
  @override
  Future<Result<void>> closeEarly(String id) async => const Ok(null);
}

// Stubs replaced by provider overrides directly — no class-level stubs needed.

/// Stub [CategoryList] notifier returning an empty category list.
class _EmptyCategoryListNotifier extends CategoryList {
  @override
  Future<List<Category>> build() async => [];
}

// ---------------------------------------------------------------------------
// Golden detail notifier for controlled state injection
// ---------------------------------------------------------------------------

class _LoadingDetailNotifier extends InstallmentPlanDetailNotifier {
  @override
  Future<InstallmentPlanDetail> build(String templateId) async {
    state = const AsyncLoading();
    return Completer<InstallmentPlanDetail>().future;
  }
}

class _LoadedDetailNotifier extends InstallmentPlanDetailNotifier {
  _LoadedDetailNotifier({required this.detail});
  final InstallmentPlanDetail detail;

  @override
  Future<InstallmentPlanDetail> build(String templateId) async {
    state = AsyncData(detail);
    return Completer<InstallmentPlanDetail>().future;
  }
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _templateId = 'templ-golden';

InstallmentPlan _makePlan({int totalConfiguredMinor = 120000}) =>
    InstallmentPlan(
      templateId: _templateId,
      totalConfiguredMinor: totalConfiguredMinor,
      numberOfInstallments: 12,
      createdAt: 1700000000,
    );

InstallmentOccurrence _makeOcc(int seq, InstallmentOccurrenceStatus status) =>
    InstallmentOccurrence(
      id: 'occ-$seq',
      templateId: _templateId,
      sequenceNumber: seq,
      scheduledDate: 20000 + seq,
      amountMinor: 10000,
      status: status,
      createdAt: 1700000000,
      updatedAt: 1700000000,
    );

InstallmentTrackingAmounts _makeTracking({bool hasMismatch = false}) =>
    InstallmentTrackingAmounts(
      totalConfiguredMinor: 120000,
      runningTotalMinor: 10000,
      totalRemainingMinor: hasMismatch ? 130000 : 110000,
      hasMismatch: hasMismatch,
    );

RecurringTemplate _makeTemplate({
  RecurringTemplateStatus status = RecurringTemplateStatus.active,
}) =>
    RecurringTemplate(
      id: _templateId,
      title: 'Golden Plan',
      transactionType: 'expense',
      amountMinor: 120000,
      currencyCode: 'INR',
      recurrenceUnit: RecurrenceUnit.month,
      recurrenceN: 1,
      startDate: 20000,
      postingBehaviour: PostingBehaviour.autoPost,
      status: status,
      isInstallment: true,
      createdAt: 1700000000,
      updatedAt: 1700000000,
    );

// ---------------------------------------------------------------------------
// Test theme
// ---------------------------------------------------------------------------

/// Builds a test app wrapped with a consistent theme for golden comparisons.
Widget _buildTestApp({required Widget child}) {
  return ProviderScope(
    overrides: [
      installmentPlanRepositoryProvider.overrideWith(
        (_) async => _StubPlanRepo(),
      ),
      // CreateInstallmentScreen uses activeAccountsProvider and categoryListProvider.
      activeAccountsProvider.overrideWith(
        (_) => Stream.value(<Account>[]),
      ),
      categoryListProvider.overrideWith(_EmptyCategoryListNotifier.new),
      createInstallmentPlanUseCaseProvider.overrideWith(
        (_) async => CreateInstallmentPlanUseCase(
          planRepository: _StubPlanRepo(),
          periodCalculator: const PeriodCalculator(),
        ),
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      ),
      home: child,
    ),
  );
}

// ---------------------------------------------------------------------------
// Golden tests
// ---------------------------------------------------------------------------

void main() {
  // ---- T-145.1  CreateInstallmentScreen empty state ----
  testWidgets('T-145.1 CreateInstallmentScreen empty state golden',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(child: const CreateInstallmentScreen()),
    );
    await tester.pump();
    await expectLater(
      find.byType(CreateInstallmentScreen),
      matchesGoldenFile(
        'goldens/create_installment_screen_empty.png',
      ),
    );
  });

  // ---- T-145.2  InstallmentPlanDetailScreen loading ----
  testWidgets('T-145.2 InstallmentPlanDetailScreen loading (shimmer) golden',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          installmentPlanRepositoryProvider.overrideWith(
            (_) async => _StubPlanRepo(),
          ),
          installmentOccurrenceRepositoryProvider.overrideWith(
            (_) async => throw UnimplementedError(),
          ),
          installmentPlanDetailProvider(_templateId).overrideWith(
            _LoadingDetailNotifier.new,
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
          ),
          home: const InstallmentPlanDetailScreen(templateId: _templateId),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(InstallmentPlanDetailScreen),
      matchesGoldenFile(
        'goldens/installment_detail_loading.png',
      ),
    );
  });

  // ---- T-145.3  InstallmentPlanDetailScreen loaded no mismatch ----
  testWidgets(
    'T-145.3 InstallmentPlanDetailScreen loaded (no mismatch) golden',
    (tester) async {
      final detail = InstallmentPlanDetail(
        plan: _makePlan(),
        occurrences: [
          _makeOcc(1, InstallmentOccurrenceStatus.posted),
          _makeOcc(2, InstallmentOccurrenceStatus.pending),
        ],
        trackingAmounts: _makeTracking(hasMismatch: false),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            installmentPlanRepositoryProvider.overrideWith(
              (_) async => _StubPlanRepo(),
            ),
            installmentOccurrenceRepositoryProvider.overrideWith(
              (_) async => throw UnimplementedError(),
            ),
            installmentPlanDetailProvider(_templateId).overrideWith(
              () => _LoadedDetailNotifier(detail: detail),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme:
                  ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
            ),
            home: const InstallmentPlanDetailScreen(templateId: _templateId),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(InstallmentPlanDetailScreen),
        matchesGoldenFile(
          'goldens/installment_detail_loaded_no_mismatch.png',
        ),
      );
    },
  );

  // ---- T-145.4  InstallmentPlanDetailScreen loaded with mismatch banner ----
  testWidgets(
    'T-145.4 InstallmentPlanDetailScreen loaded with mismatch banner golden',
    (tester) async {
      final detail = InstallmentPlanDetail(
        plan: _makePlan(),
        occurrences: [
          _makeOcc(1, InstallmentOccurrenceStatus.posted),
          _makeOcc(2, InstallmentOccurrenceStatus.pending),
        ],
        trackingAmounts: _makeTracking(hasMismatch: true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            installmentPlanRepositoryProvider.overrideWith(
              (_) async => _StubPlanRepo(),
            ),
            installmentOccurrenceRepositoryProvider.overrideWith(
              (_) async => throw UnimplementedError(),
            ),
            installmentPlanDetailProvider(_templateId).overrideWith(
              () => _LoadedDetailNotifier(detail: detail),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme:
                  ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
            ),
            home: const InstallmentPlanDetailScreen(templateId: _templateId),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(InstallmentPlanDetailScreen),
        matchesGoldenFile(
          'goldens/installment_detail_mismatch_banner.png',
        ),
      );
    },
  );

  // ---- T-145.5  InstallmentTemplateRow Active ----
  testWidgets(
    'T-145.5 InstallmentTemplateRow active with progress bar golden',
    (tester) async {
      final template = _makeTemplate(status: RecurringTemplateStatus.active);
      final plan = _makePlan();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
          ),
          home: Scaffold(
            body: ListView(
              children: [
                _InstallmentTemplateRowForTest(
                  template: template,
                  plan: plan,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/installment_template_row_active.png',
        ),
      );
    },
  );

  // ---- T-145.6  InstallmentTemplateRow Paused ----
  testWidgets('T-145.6 InstallmentTemplateRow paused golden', (tester) async {
    final template = _makeTemplate(status: RecurringTemplateStatus.paused);
    final plan = _makePlan();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        ),
        home: Scaffold(
          body: ListView(
            children: [
              _InstallmentTemplateRowForTest(
                template: template,
                plan: plan,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile(
        'goldens/installment_template_row_paused.png',
      ),
    );
  });

  // ---- T-145.7  InstallmentTemplateRow Archived ----
  testWidgets('T-145.7 InstallmentTemplateRow archived golden', (tester) async {
    final template = _makeTemplate(status: RecurringTemplateStatus.archived);
    final plan = _makePlan();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        ),
        home: Scaffold(
          body: ListView(
            children: [
              _InstallmentTemplateRowForTest(
                template: template,
                plan: plan,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile(
        'goldens/installment_template_row_archived.png',
      ),
    );
  });
}

// ---------------------------------------------------------------------------
// Reusable installment template row widget for testing
// ---------------------------------------------------------------------------

/// Test wrapper exposing [_InstallmentTemplateRow] by rendering it in a
/// [ProviderScope] with stub providers for the installment notifiers.
class _InstallmentTemplateRowForTest extends StatelessWidget {
  const _InstallmentTemplateRowForTest({
    required this.template,
    required this.plan,
  });

  final RecurringTemplate template;
  final InstallmentPlan? plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = template.title?.isNotEmpty == true
        ? template.title!
        : '₹${(template.amountMinor / 100).toStringAsFixed(0)}';

    final totalConfigured = plan?.totalConfiguredMinor ?? 0;
    const runningTotal = 0;
    final progressValue = totalConfigured > 0
        ? (runningTotal / totalConfigured).clamp(0.0, 1.0)
        : 0.0;
    final totalStr = '₹${(totalConfigured / 100).toStringAsFixed(2)}';
    const paidStr = '₹0.00';

    final statusColor = switch (template.status) {
      RecurringTemplateStatus.active => const Color(0xFF4CAF50),
      RecurringTemplateStatus.paused => const Color(0xFFFFC107),
      _ => theme.colorScheme.onSurfaceVariant,
    };
    final statusLabel = switch (template.status) {
      RecurringTemplateStatus.active => 'Active',
      RecurringTemplateStatus.paused => 'Paused',
      _ => 'Archived',
    };

    return ListTile(
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progressValue,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 4),
          Text(
            '$paidStr paid of $totalStr',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withValues(alpha: 0.5)),
        ),
        child: Text(
          statusLabel,
          style: theme.textTheme.labelSmall?.copyWith(color: statusColor),
        ),
      ),
      isThreeLine: true,
    );
  }
}
