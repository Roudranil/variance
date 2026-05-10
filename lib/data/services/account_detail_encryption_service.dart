// lib/data/services/account_detail_encryption_service.dart
//
// Service for encrypting and decrypting sensitive account detail values.
//
// Sensitive keys (card_number, account_number) are encrypted using
// flutter_secure_storage's platform-native AES mechanism. The ciphertext is
// stored in detail_value_encrypted; detail_value is left null.
//
// CVV is never written to either column (data model §3.2 note).
//
// Encryption key derivation:
//   Each sensitive field uses a composite key in secure storage:
//     "account_detail_{accountId}_{detailKey}"
//   The encrypted value is the ciphertext string returned by secure storage.
//
// Test cases (see test/data/services/account_detail_encryption_service_test.dart):
//   1. encryptIfNeeded — non-sensitive key returns value in detailValue
//   2. encryptIfNeeded — sensitive key returns value in detailValueEncrypted
//   3. revealEncryptedValue — returns plaintext after prior encrypt call
//   4. maskedValue — returns masked string for encrypted field

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:variance/domain/entities/account_detail.dart';

/// Platform-native AES encryption service for sensitive account detail fields.
///
/// Delegates to [FlutterSecureStorage] which uses Android Keystore /
/// iOS Keychain for key storage. Each encrypted value is keyed by a composite
/// storage key combining the account UUID and the detail key name.
class AccountDetailEncryptionService {
  /// Creates an [AccountDetailEncryptionService].
  ///
  /// Parameters:
  /// - [secureStorage]: The platform-secure storage instance.
  const AccountDetailEncryptionService(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  // -----------------------------------------------------------------------
  // Public API
  // -----------------------------------------------------------------------

  /// Returns an [AccountDetail] with the value in the correct column.
  ///
  /// For sensitive keys (see [AccountDetailKey.encrypted]): stores the value
  /// using [FlutterSecureStorage] and returns the composite storage key as
  /// [AccountDetail.detailValueEncrypted]. The [AccountDetail.detailValue] is
  /// left null.
  ///
  /// For non-sensitive keys: returns the value in [AccountDetail.detailValue]
  /// unchanged.
  ///
  /// CVV keys are rejected outright (returned with both value fields null).
  ///
  /// Parameters:
  /// - [accountId]: UUID of the parent account.
  /// - [detail]: Detail with a plaintext value to process.
  Future<AccountDetail> encryptIfNeeded(
    String accountId,
    AccountDetail detail,
  ) async {
    // CVV is never persisted.
    if (detail.detailKey == 'cvv') {
      return detail.copyWith(
        detailValue: null,
        detailValueEncrypted: null,
      );
    }

    final keyMeta = AccountDetailKey.fromString(detail.detailKey);
    final isEncrypted = keyMeta?.encrypted ?? false;

    if (!isEncrypted) {
      // Store plaintext in detailValue; clear encrypted column.
      return detail.copyWith(
        detailValueEncrypted: null,
      );
    }

    // Sensitive field — store via secure storage.
    final plaintext = detail.detailValue ?? '';
    final storageKey = _storageKey(accountId, detail.detailKey);
    await _secureStorage.write(key: storageKey, value: plaintext);

    // Store the composite storage key as the encrypted blob reference so we
    // can look it up on reveal without reconstructing it.
    return detail.copyWith(
      detailValue: null,
      detailValueEncrypted: storageKey,
    );
  }

  /// Returns the plaintext value for a sensitive detail field.
  ///
  /// Reads from [FlutterSecureStorage] using the storage key stored in
  /// [AccountDetail.detailValueEncrypted].
  ///
  /// Returns null if the value was never written or has been deleted.
  ///
  /// Parameters:
  /// - [detail]: An [AccountDetail] with a non-null [AccountDetail.detailValueEncrypted].
  Future<String?> revealEncryptedValue(AccountDetail detail) async {
    final storageKey = detail.detailValueEncrypted;
    if (storageKey == null) return null;
    return _secureStorage.read(key: storageKey);
  }

  /// Returns a masked representation of the sensitive value.
  ///
  /// For card numbers: shows last 4 digits preceded by "••••••••" if available.
  /// For other sensitive fields: returns "••••••••".
  ///
  /// Parameters:
  /// - [accountId]: UUID of the parent account.
  /// - [detailKey]: The detail key string.
  Future<String> maskedValue(String accountId, String detailKey) async {
    final storageKey = _storageKey(accountId, detailKey);
    final plaintext = await _secureStorage.read(key: storageKey);
    if (plaintext == null || plaintext.isEmpty) return '••••••••';

    if (detailKey == 'card_number' && plaintext.length >= 4) {
      final last4 = plaintext.substring(plaintext.length - 4);
      return '•••• •••• •••• $last4';
    }
    return '••••••••';
  }

  /// Deletes the secure-storage entry for a sensitive detail field.
  ///
  /// Should be called when an account is soft-deleted or a detail is removed.
  ///
  /// Parameters:
  /// - [accountId]: UUID of the parent account.
  /// - [detailKey]: The detail key string to delete.
  Future<void> deleteEncryptedValue(String accountId, String detailKey) async {
    await _secureStorage.delete(
      key: _storageKey(accountId, detailKey),
    );
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  /// Constructs the composite secure-storage key for [accountId] + [detailKey].
  String _storageKey(String accountId, String detailKey) =>
      'account_detail_${accountId}_$detailKey';
}
