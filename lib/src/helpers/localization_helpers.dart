import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:easy_localization_cleaner/src/utils/logger.dart';
import 'package:easy_localization_cleaner/src/visitors/visitors.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

/// A helper class for managing localization keys and JSON files.
final class LocalizationHelpers {
  /// Converts a given [generatedClassKey] to its snake_case equivalent.
  String generatedClassPath(String generatedClassKey) {
    return convertToSnakeCase(generatedClassKey);
  }

  /// Converts a given [input] string to snake_case.
  String convertToSnakeCase(String input) {
    final regex = RegExp('(?<!^)(?=[A-Z])');
    return input.replaceAll(regex, '_').toLowerCase();
  }

  /// Extracts locale keys from generated `.g.dart` files
  /// in the specified [currentPath].
  /// The [generatedClassPath] is used to locate the files.
  Map<String, String> extractLocaleKeys(
    String currentPath,
    String generatedClassPath,
  ) {
    final localeKeys = <String, String>{};
    final glob = Glob('$currentPath/lib/**/$generatedClassPath.g.dart');

    for (final file in glob.listSync()) {
      if (file is File) {
        final content = File(file.path).readAsStringSync();
        final result = parseString(content: content);
        final visitor = LocaleKeysVisitor();
        result.unit.visitChildren(visitor);
        localeKeys.addAll(visitor.keysAndValues);
      }
    }

    return localeKeys;
  }

  /// Extracts base keys from generated `.g.dart` files
  /// in the specified [currentPath].
  /// The [generatedClassPath] is used to locate the files.
  Set<String> extractBaseKeys(String currentPath, String generatedClassPath) {
    final baseKeys = <String>{};
    final visitor = BaseKeysVisitor();

    final dartFiles =
        Glob('$currentPath/lib/**/$generatedClassPath.g.dart').listSync();
    for (final file in dartFiles) {
      if (file is File) {
        final content = File(file.path).readAsStringSync();
        final result = parseString(content: content);
        result.unit.visitChildren(visitor);
      }
    }

    baseKeys.addAll(visitor.baseKeys);
    return baseKeys;
  }

  /// Extracts all used localization keys from `.dart` files
  /// in the specified [currentPath].
  Set<String> usedKeys(String currentPath, String generatedClassKey) {
    final usedKeys = <String>{};
    final visitor = KeyUsageVisitor(generatedClassKey);

    final dartFiles = Glob('$currentPath/lib/**.dart').listSync();
    for (final file in dartFiles) {
      if (file is File) {
        final content = File(file.path).readAsStringSync();
        final result = parseString(content: content);
        result.unit.visitChildren(visitor);
      }
    }

    usedKeys.addAll(visitor.usedKeys);
    return usedKeys;
  }

  /// Removes unused localization keys from JSON files in the [assetsDir].
  /// The [unusedKeys] and [baseKeys] are used to determine which keys to remove
  void removeUnusedKeysFromJson(
    String currentPath,
    Map<String, String> localeKeys,
    Set<String> unusedKeys,
    Set<String> baseKeys,
    String assetsDir,
    String jsonIndent,
  ) {
    logger.i('Removing unused keys from JSON files...');

    final jsonFiles = Glob('$currentPath/$assetsDir/**.json').listSync();

    for (final file in jsonFiles) {
      if (file is File) {
        final jsonString = File(file.path).readAsStringSync();
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

        for (final key in unusedKeys) {
          if (baseKeys.contains(key)) continue;
          if (localeKeys.containsKey(key)) {
            removeKey(jsonMap, localeKeys[key]!);
          }
        }

        final updatedJsonString =
            JsonEncoder.withIndent(jsonIndent).convert(jsonMap);
        File(file.path).writeAsStringSync(updatedJsonString);

        logger.i('Updated ${file.path}');
      }
    }
  }

  /// Removes a specific [key] from the given [map].
  void removeKey(Map<String, dynamic> map, String key) {
    final keyParts = key.split('.');
    removeNestedKey(map, keyParts);
  }

  /// Recursively removes a nested key from the given [map]
  /// using the [keys] list.
  void removeNestedKey(Map<String, dynamic> map, List<String> keys) {
    if (keys.isEmpty) return;
    final key = keys.removeAt(0);

    if (keys.isEmpty) {
      map.remove(key);
    } else {
      final nestedMap = map[key];
      if (nestedMap is Map<String, dynamic>) {
        removeNestedKey(nestedMap, keys);
        if (nestedMap.isEmpty) {
          map.remove(key);
        }
      }
    }
  }

  /// Exports the log file containing the unused keys to the [currentPath].
  void exportLog(String currentPath, String logFile, Set<String> keys) {
    final file = File('$currentPath/$logFile');
    if (!file.existsSync()) {
      file.createSync();
    }

    final content = keys.join('\n');
    file.writeAsStringSync(content);

    logger.i('Exported log file to ${file.path}');
  }
}
