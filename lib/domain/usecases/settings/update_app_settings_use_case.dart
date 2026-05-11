// lib/domain/usecases/settings/update_app_settings_use_case.dart
//
// Use case: apply a partial update to app settings.
//
// Thin delegation to IAppSettingsRepository.update(patch). No domain logic
// beyond the repository boundary is required for settings writes.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';

/// Applies a partial update to the app settings.
///
/// Delegates to [IAppSettingsRepository.update] with the provided [patch].
/// Only non-null fields in [patch] are written; null fields are left unchanged.
class UpdateAppSettingsUseCase {
  /// Creates an [UpdateAppSettingsUseCase] backed by [repository].
  const UpdateAppSettingsUseCase(this._repository);

  final IAppSettingsRepository _repository;

  /// Executes the use case.
  ///
  /// Returns [Ok] on success or [Err] with a [Failure] on repository error.
  ///
  /// Parameters:
  /// - [patch]: Partial settings update.
  Future<Result<void>> call(AppSettingsPatch patch) =>
      _repository.update(patch);
}
