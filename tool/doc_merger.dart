import 'dart:io';
import 'package:path/path.dart' as p;

/// Configuration
const String sourceDir = 'doc/temp';
const String targetDir = 'doc/api_reference';
const Set<String> ignoredDirs = {
  'database.g',
  'database_test',
  'widget_test',
  'test',
  'native', // Assuming we just want pure Dart logic or specific features
};

void main() async {
  final source = Directory(sourceDir);
  final target = Directory(targetDir);

  if (!await source.exists()) {
    print('Error: Source directory $sourceDir does not exist.');
    exit(1);
  }

  // Clean target
  if (await target.exists()) {
    await target.delete(recursive: true);
  }
  await target.create(recursive: true);

  print('Scanning $sourceDir...');

  // Map to hold files for each target output file
  // Key: Target filename relative to doc/api, Value: List of source file contents
  final Map<String, List<String>> fileAggregator = {};

  final entities = source.listSync(recursive: true);

  for (var entity in entities) {
    if (entity is! File || !entity.path.endsWith('.md')) continue;

    // Check path segments to determine grouping
    // Path usually looks like: doc/temp/feature_name/ClassName/overview.md
    // OR doc/temp/feature_name/library_name.md

    final relativePath = p.relative(entity.path, from: sourceDir);
    final segments = p.split(relativePath);

    // Top-level files usually map to 'lib.md' or similar if we want them grouped
    // But let's look at the segments.
    // segment[0] is often the library name or folder name from lib/

    if (segments.isEmpty) continue;

    final topFolder = segments.first;

    if (ignoredDirs.contains(topFolder)) continue;

    // We want one markdown file per top-level folder in lib/
    // e.g. lib/features/accounts -> doc/api/features_accounts.md
    // BUT the generator outputs flat library names usually like 'account_repository', 'app_utils'
    // Let's assume the generator uses the library name.

    String targetName;

    // Simple heuristic: group by the first directory in the output
    // The generator outputs:
    //  account_repository/AccountRepository/overview.md
    //  account_repository/AccountRepository/methods/getAccount.md
    // Target -> account_repository.md

    targetName = '$topFolder.md';

    fileAggregator.putIfAbsent(targetName, () => []);

    // Pre-process content to fix headers
    String content = await entity.readAsString();
    content = _adjustHeaders(content, entity.path);

    fileAggregator[targetName]!.add(content);
  }

  // Write aggregated files
  for (var entry in fileAggregator.entries) {
    final File outFile = File(p.join(targetDir, entry.key));
    await outFile.writeAsString(
      "# ${p.basenameWithoutExtension(entry.key)}\n\n",
    );

    // Sort contents to have 'Overview' first if possible, or alphabetical
    // Simple sort for now
    entry.value.sort((a, b) {
      if (a.contains('# Overview')) return -1;
      if (b.contains('# Overview')) return 1;
      return 0;
    });

    for (var content in entry.value) {
      await outFile.writeAsString(content, mode: FileMode.append);
      await outFile.writeAsString('\n---\n\n', mode: FileMode.append);
    }
    print('Generated: ${outFile.path}');
  }

  print('Done! Documentation generated in $targetDir');
}

String _adjustHeaders(String content, String filepath) {
  // Logic to bump headers down so they fit under the main file header
  // Also maybe add the filename or class name as a sub-header if missing

  final lines = content.split('\n');
  final buffer = StringBuffer();

  // If it's a method file, it often starts with # methodName
  // We want that to be ## methodName

  // If it is inside a Class folder, we might want to mention the class

  for (var line in lines) {
    if (line.startsWith('#')) {
      buffer.writeln('#$line'); // Add one level
    } else {
      buffer.writeln(line);
    }
  }

  return buffer.toString();
}
