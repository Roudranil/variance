// test/unit/domain/usecases/home/get_catch_up_banner_use_case_test.dart
//
// Unit tests for GetCatchUpBannerUseCase (T-171).
//
// Test cases:
//   T-171.1  Returns empty list when lastAutoPostedCount == 0
//   T-171.2  Returns list when lastAutoPostedCount > 0
//   T-171.3  Returned count capped to actual active template count

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/usecases/home/get_catch_up_banner_use_case.dart';
import 'package:variance/infrastructure/scheduling/app_initializer.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRecurringTemplateRepository
    implements IRecurringTemplateRepository {
  _FakeRecurringTemplateRepository(this._templates);

  final List<RecurringTemplate> _templates;

  @override
  Stream<List<RecurringTemplate>> watchAll() => Stream.value(_templates);

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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    // Reset static state between tests.
    AppInitializer.clearForTest();
  });

  group('GetCatchUpBannerUseCase', () {
    test(
      'T-171.1 Returns empty list when lastAutoPostedCount == 0',
      () async {
        // lastAutoPostedCount == 0 by default after clearForTest.
        final repo = _FakeRecurringTemplateRepository([
          _makeTemplate('t1'),
          _makeTemplate('t2'),
        ]);
        final useCase = GetCatchUpBannerUseCase(repo);

        final result = await useCase.call();

        expect(result, isA<Ok<List<RecurringTemplate>>>());
        final ok = result as Ok<List<RecurringTemplate>>;
        expect(ok.value, isEmpty);
      },
    );

    test(
      'T-171.2 Returns non-empty list when lastAutoPostedCount > 0',
      () async {
        AppInitializer.lastAutoPostedCount = 2;

        final repo = _FakeRecurringTemplateRepository([
          _makeTemplate('t1'),
          _makeTemplate('t2'),
          _makeTemplate('t3'),
        ]);
        final useCase = GetCatchUpBannerUseCase(repo);

        final result = await useCase.call();

        expect(result, isA<Ok<List<RecurringTemplate>>>());
        final ok = result as Ok<List<RecurringTemplate>>;
        expect(ok.value, hasLength(2));
      },
    );

    test(
      'T-171.3 Count capped to available active template count',
      () async {
        AppInitializer.lastAutoPostedCount = 10;

        // Only 2 active templates exist.
        final repo = _FakeRecurringTemplateRepository([
          _makeTemplate('t1'),
          _makeTemplate('t2'),
        ]);
        final useCase = GetCatchUpBannerUseCase(repo);

        final result = await useCase.call();

        expect(result, isA<Ok<List<RecurringTemplate>>>());
        final ok = result as Ok<List<RecurringTemplate>>;
        // Capped to 2 (actual template count).
        expect(ok.value, hasLength(2));
      },
    );
  });
}
