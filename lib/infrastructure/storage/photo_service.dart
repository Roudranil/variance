// lib/infrastructure/storage/photo_service.dart
//
// PhotoService — pick, compress, and store transaction photo attachments (T-55).
//
// Compression pipeline (SDS §2.15.1, TC-007):
//   - Output: JPEG
//   - Max dimension: 1920px (no upscaling)
//   - Starting quality: 85
//   - Reduce by 5 per iteration if output > 500KB
//   - Quality floor: 60
//
// Storage:
//   - getApplicationDocumentsDirectory()/attachments/{txn_id}/{uuid}.jpg
//   - attachments row: relative path, mime_type = 'image/jpeg', file size
//
// Test cases (see test/infrastructure/storage/photo_service_test.dart):
//   T-55.1. compress produces output <= 500KB for a large input
//   T-55.2. 3rd photo add blocked (max 2 per transaction)
//   T-55.3. deletePhoto with missing file is idempotent (no error)

import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// ignore: prefer_const_constructors — Uuid must not be const
final _uuid = Uuid();

/// Maximum photos allowed per transaction.
const kMaxPhotosPerTransaction = 2;

/// Target file size ceiling in bytes.
const kTargetSizeBytes = 500 * 1024; // 500 KB

/// Max image dimension (width or height) in pixels.
const kMaxDimension = 1920;

/// Starting JPEG compression quality.
const kStartQuality = 85;

/// Minimum JPEG compression quality.
const kMinQuality = 60;

/// Quality reduction step per iteration.
const kQualityStep = 5;

/// MIME type for all stored photos.
const kMimeTypeJpeg = 'image/jpeg';

/// Result of a successful photo save operation.
class PhotoSaveResult {
  /// Creates a [PhotoSaveResult].
  const PhotoSaveResult({
    required this.relativePath,
    required this.fileSizeBytes,
    required this.mimeType,
  });

  /// Path relative to [getApplicationDocumentsDirectory()].
  final String relativePath;

  /// File size in bytes after compression.
  final int fileSizeBytes;

  /// Always 'image/jpeg'.
  final String mimeType;
}

/// Service for picking, compressing, and storing transaction photos.
///
/// Lives in the infrastructure layer. No domain imports beyond basic Dart types.
class PhotoService {
  /// Creates a [PhotoService].
  PhotoService({ImagePicker? imagePicker})
      : _picker = imagePicker ?? ImagePicker();

  final ImagePicker _picker;

  // -----------------------------------------------------------------------
  // Pick
  // -----------------------------------------------------------------------

  /// Picks an image from [source] (camera or gallery).
  ///
  /// Returns the picked [XFile] or null if the user cancelled.
  ///
  /// Parameters:
  /// - [source]: [ImageSource.camera] or [ImageSource.gallery].
  Future<XFile?> pick(ImageSource source) async {
    try {
      return await _picker.pickImage(source: source);
    } on Exception catch (e) {
      dev.log('PhotoService.pick failed: $e', name: 'PhotoService');
      return null;
    }
  }

  // -----------------------------------------------------------------------
  // Compress + save
  // -----------------------------------------------------------------------

  /// Compresses [sourceFile] and saves it under [transactionId].
  ///
  /// Returns a [PhotoSaveResult] on success, or null on failure.
  ///
  /// Enforces the max-2-photos-per-transaction rule: returns null if
  /// [existingCount] >= [kMaxPhotosPerTransaction].
  ///
  /// Parameters:
  /// - [sourceFile]: The raw image picked from camera/gallery.
  /// - [transactionId]: UUID of the parent transaction.
  /// - [existingCount]: Number of photos already attached to this transaction.
  Future<PhotoSaveResult?> compressAndSave({
    required XFile sourceFile,
    required String transactionId,
    required int existingCount,
  }) async {
    if (existingCount >= kMaxPhotosPerTransaction) {
      dev.log(
        'PhotoService: max photos reached for $transactionId',
        name: 'PhotoService',
      );
      return null;
    }

    try {
      // Compress with adaptive quality
      final compressed = await _compressAdaptive(sourceFile.path);
      if (compressed == null) return null;

      // Build destination path
      final appDir = await getApplicationDocumentsDirectory();
      final attachDir = Directory(
        p.join(appDir.path, 'attachments', transactionId),
      );
      await attachDir.create(recursive: true);

      final filename = '${_uuid.v4()}.jpg';
      final destPath = p.join(attachDir.path, filename);
      await File(destPath).writeAsBytes(compressed);

      // Relative path for storage in DB (path relative to appDir)
      final relativePath =
          p.relative(destPath, from: appDir.path);

      return PhotoSaveResult(
        relativePath: relativePath,
        fileSizeBytes: compressed.length,
        mimeType: kMimeTypeJpeg,
      );
    } on Exception catch (e) {
      dev.log(
        'PhotoService.compressAndSave failed: $e',
        name: 'PhotoService',
      );
      return null;
    }
  }

  // -----------------------------------------------------------------------
  // Delete
  // -----------------------------------------------------------------------

  /// Deletes the photo file at [relativePath].
  ///
  /// Returns silently if the file does not exist — idempotent.
  ///
  /// Parameters:
  /// - [relativePath]: Path relative to [getApplicationDocumentsDirectory()].
  Future<void> deletePhoto(String relativePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File(p.join(appDir.path, relativePath));
      if (await file.exists()) {
        await file.delete();
      }
    } on Exception catch (e) {
      dev.log(
        'PhotoService.deletePhoto failed for $relativePath: $e',
        name: 'PhotoService',
      );
    }
  }

  /// Deletes all photo files for [transactionId].
  ///
  /// Called on transaction void. Missing directory or files are ignored.
  ///
  /// Parameters:
  /// - [transactionId]: UUID of the transaction.
  Future<void> deleteAllPhotosForTransaction(String transactionId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final attachDir = Directory(
        p.join(appDir.path, 'attachments', transactionId),
      );
      if (await attachDir.exists()) {
        await attachDir.delete(recursive: true);
      }
    } on Exception catch (e) {
      dev.log(
        'PhotoService.deleteAllPhotos failed for $transactionId: $e',
        name: 'PhotoService',
      );
    }
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------

  /// Compresses image at [sourcePath] with adaptive quality.
  ///
  /// Starts at [kStartQuality] and reduces by [kQualityStep] per iteration
  /// until output is <= [kTargetSizeBytes] or [kMinQuality] is reached.
  Future<Uint8List?> _compressAdaptive(String sourcePath) async {
    int quality = kStartQuality;

    while (quality >= kMinQuality) {
      final result = await FlutterImageCompress.compressWithFile(
        sourcePath,
        minWidth: 1,
        minHeight: 1,
        quality: quality,
        keepExif: false,
      );

      if (result == null) return null;

      if (result.length <= kTargetSizeBytes || quality == kMinQuality) {
        return result;
      }

      quality -= kQualityStep;
    }

    return null;
  }
}
