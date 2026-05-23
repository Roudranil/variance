// test/presentation/features/home/catch_up_banner_test.dart
//
// Widget tests for CatchUpBanner (T-171).
//
// Test cases:
//   T-171.1  Banner absent when use case returns empty list
//   T-171.2  Banner shown when use case returns non-empty list
//   T-171.3  Correct N appears in the banner message
//   T-171.4  "View details" tap calls FilterNotifier setDateRange
//   T-171.5  Dismiss hides the banner

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/usecases/home/get_catch_up_banner_use_case.dart';
import 'package:variance/infrastructure/scheduling/app_initializer.dart';
import 'package:variance/presentation/features/home/widgets/catch_up_banner.dart';
import 'package:variance/presentation/providers/filter_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

// ---------------------------------------------------------------------------
// Fake use case
// ---------------------------------------------------------------------------

class _FakeGetCatchUpBannerUseCase extends GetCatchUpBannerUseCase {
  _FakeGetCatchUpBannerUseCase(this._result)
      : super(_NullRecurringTemplateRepository());

  final Result<List<RecurringTemplate>> _result;

  @override
  Future<Result<List<RecurringTemplate>>> call() async => _result;
}

class _NullRecurringTemplateRepository
    implements IRecurringTemplateRepository {
  @override
  Stream<List<RecurringTemplate>> watchAll() => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        invocation.memberName.toString(),
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

RecurringTemplate _makeTemplate(String id) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return RecurringTemplate(
    id: id,
    transactionType: 'expense',
    amountMinor: 1000,
    currencyCode: 'INR',
    recurrenceN: 1,
    recurrenceUnit: RecurrenceUnit.month,
    startDate: now - 86400 * 30,
    status: RecurringTemplateStatus.active,
    postingBehaviour: PostingBehaviour.autoPost,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildApp({
  required _FakeGetCatchUpBannerUseCase fakeUseCase,
}) {
  return ProviderScope(
    overrides: [
      getCatchUpBannerUseCaseProvider.overrideWith(
        (ref) async => fakeUseCase,
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: CatchUpBanner(),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() => AppInitializer.clearForTest());

  group('CatchUpBanner T-171', () {
    testWidgets(
      'T-171.1 Banner absent when use case returns empty list',
      (tester) async {
        final fakeUseCase =
            _FakeGetCatchUpBannerUseCase(const Ok([]));
        await tester.pumpWidget(_buildApp(fakeUseCase: fakeUseCase));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('catch_up_banner_card')), findsNothing);
      },
    );

    testWidgets(
      'T-171.2 Banner shown when use case returns non-empty list',
      (tester) async {
        final fakeUseCase = _FakeGetCatchUpBannerUseCase(
          Ok([_makeTemplate('t1')]),
        );
        await tester.pumpWidget(_buildApp(fakeUseCase: fakeUseCase));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('catch_up_banner_card')), findsOneWidget);
      },
    );

    testWidgets(
      'T-171.3 Correct N appears in banner message',
      (tester) async {
        final fakeUseCase = _FakeGetCatchUpBannerUseCase(
          Ok([_makeTemplate('t1'), _makeTemplate('t2'), _makeTemplate('t3')]),
        );
        await tester.pumpWidget(_buildApp(fakeUseCase: fakeUseCase));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('3 recurring transactions'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'T-171.4 "View details" tap calls FilterNotifier setDateRange',
      (tester) async {
        final fakeUseCase = _FakeGetCatchUpBannerUseCase(
          Ok([_makeTemplate('t1')]),
        );
        DateTimeRange? capturedRange;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              getCatchUpBannerUseCaseProvider.overrideWith(
                (ref) async => fakeUseCase,
              ),
              filterProvider.overrideWith(
                () => _CapturingFilterNotifier(
                  onDateRange: (r) => capturedRange = r,
                ),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(body: CatchUpBanner()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('catch_up_view_details')));
        await tester.pump();

        expect(capturedRange, isNotNull);
      },
    );

    testWidgets(
      'T-171.5 Dismiss hides the banner',
      (tester) async {
        final fakeUseCase = _FakeGetCatchUpBannerUseCase(
          Ok([_makeTemplate('t1')]),
        );
        await tester.pumpWidget(_buildApp(fakeUseCase: fakeUseCase));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('catch_up_banner_card')), findsOneWidget);

        await tester.tap(find.byKey(const Key('catch_up_dismiss')));
        await tester.pump();

        expect(find.byKey(const Key('catch_up_banner_card')), findsNothing);
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Capturing FilterNotifier fake
// ---------------------------------------------------------------------------

class _CapturingFilterNotifier extends FilterNotifier {
  _CapturingFilterNotifier({required this.onDateRange});

  final void Function(DateTimeRange?) onDateRange;

  @override
  FilterState build() => const FilterState();

  @override
  void setDateRange(DateTimeRange? range) {
    onDateRange(range);
    // Don't call super to avoid state initialization issues.
  }
}
