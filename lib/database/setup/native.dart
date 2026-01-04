import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Opens a connection to the local SQLite database.
///
/// Returns a [LazyDatabase] that constructs the [NativeDatabase] in a
/// background isolate.
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'variance_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
