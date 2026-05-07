// lib/data/repositories/recurring_template_repository_impl.dart
//
// Concrete implementation of IRecurringTemplateRepository backed by Drift via
// TemplateDao.
//
// This stub implementation wires the DI graph for INFRA-3.
// Full business logic is implemented in later feature tasks.

import 'package:variance/data/database/daos/template_dao.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';

/// Drift-backed implementation of [IRecurringTemplateRepository].
///
/// Delegates all data access to [TemplateDao]. Business rules live in use cases.
class RecurringTemplateRepositoryImpl implements IRecurringTemplateRepository {
  /// Creates a [RecurringTemplateRepositoryImpl] backed by [dao].
  const RecurringTemplateRepositoryImpl(this._dao);

  // ignore: unused_field — used by full implementation in later feature tasks
  final TemplateDao _dao;

  @override
  Stream<List<RecurringTemplate>> watchAll() {
    // TODO(dev): Map Drift RecurringTemplate rows to domain entities.
    throw UnimplementedError('watchAll not yet implemented');
  }

  @override
  Stream<RecurringTemplate?> watchById(String id) {
    // TODO(dev): Implement single-template stream.
    throw UnimplementedError('watchById not yet implemented');
  }

  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate template) {
    // TODO(dev): Implement template creation with status=active.
    throw UnimplementedError('create not yet implemented');
  }

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate template) {
    // TODO(dev): Implement editable field update.
    throw UnimplementedError('update not yet implemented');
  }

  @override
  Future<Result<void>> pause(String id) {
    // TODO(dev): Transition status → paused.
    throw UnimplementedError('pause not yet implemented');
  }

  @override
  Future<Result<void>> resume(String id) {
    // TODO(dev): Transition status → active.
    throw UnimplementedError('resume not yet implemented');
  }

  @override
  Future<Result<void>> softDelete(String id) {
    // TODO(dev): Soft-delete and cancel pending occurrences.
    throw UnimplementedError('softDelete not yet implemented');
  }

  @override
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf) {
    // TODO(dev): Query active templates where next_occurrence_at <= asOf.
    throw UnimplementedError('getDue not yet implemented');
  }
}
