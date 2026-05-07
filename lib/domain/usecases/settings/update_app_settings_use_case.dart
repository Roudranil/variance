// lib/domain/usecases/settings/update_app_settings_use_case.dart
//
// Use case: update one or more app settings.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';

/// Applies a partial update to the app settings.
class UpdateAppSettingsUseCase {
  const UpdateAppSettingsUseCase(this._repository);

  // ignore: unused_field
  final IAppSettingsRepository _repository;

  /// Executes the use case.
  Future<Result<void>> call(AppSettingsPatch patch) {
    throw UnimplementedError(
      'UpdateAppSettingsUseCase.call is not implemented',
    );
  }
}
