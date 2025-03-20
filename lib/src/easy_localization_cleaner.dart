import 'dart:io';

import 'package:args/args.dart';
import 'package:easy_localization_cleaner/src/cli/arguments.dart';
import 'package:easy_localization_cleaner/src/cli/options.dart';
import 'package:easy_localization_cleaner/src/helpers/helpers.dart';
import 'package:easy_localization_cleaner/src/utils/logger.dart';
import 'package:yaml/yaml.dart';

/// A Dart CLI package designed to remove unused locale keys from JSON files
/// used with the `easy_localization` package.
class EasyLocalizationCleaner {
  /// An instance of [LocalizationHelpers]
  /// to perform localization-related operations.
  static final helpers = LocalizationHelpers();

  /// The main entry point for the CLI tool.
  ///
  /// [args] are the command-line arguments passed to the tool.
  static void run(List<String> args) {
    final argParser = ArgParser();
    defineOptions(argParser);

    late final CliArguments parsedArgs;

    try {
      parsedArgs = parseArgsAndConfig(argParser, args);
    } on CliArgumentException catch (e) {
      _usageError(argParser, e.message);
    } on CliHelpException {
      _printHelp(argParser);
    } on YamlException catch (e) {
      logger.e(e.toString());
      exit(66);
    }

    try {
      _run(parsedArgs);
    } on Object catch (e) {
      logger.e(e.toString());
      exit(65);
    }
  }

  static Future<void> _run(CliArguments parsedArgs) async {
    final stopwatch = Stopwatch()..start();

    final isVerbose = parsedArgs.verbose ?? kDefaultVerbose;

    if (isVerbose) {
      logger.filterLevel = Level.trace;
    }

    try {
      final currentPath = parsedArgs.currentPath ?? kDefaultCurrentPath;
      final generatedClassKey =
          parsedArgs.generatedClassKey ?? kDefaultGeneratedClassKey;
      final assetsDir = parsedArgs.assetsDir ?? kDefaultAssetsDir;

      var jsonIndent = parsedArgs.jsonIndent;
      if (jsonIndent == r'\t' || jsonIndent == 't') {
        jsonIndent = '\t';
      } else {
        final spaces = int.tryParse(jsonIndent ?? '2');
        jsonIndent = spaces != null ? ' ' * spaces : '  ';
      }

      final generatedClassPath = helpers.generatedClassPath(generatedClassKey);

      final localeKeysData =
          helpers.extractLocaleKeys(currentPath, generatedClassPath);

      final localeKeys = localeKeysData.keys.toSet();

      final usedKeys = helpers.usedKeys(currentPath, generatedClassKey);
      final baseKeys = helpers.extractBaseKeys(currentPath, generatedClassPath);
      final unusedKeys = localeKeys.difference(usedKeys);

      final totalKeys = localeKeys.length;
      final usedKeysCount = localeKeys.length - unusedKeys.length;
      final baseKeysCount = baseKeys.length;

      logger.i(
        'Found total locale keys: $totalKeys, '
        'used keys: $usedKeysCount, '
        'base keys: $baseKeysCount',
      );

      if (totalKeys == usedKeysCount) {
        logger.i('All LocaleKeys are used.');
        return;
      } else {
        logger.i('Found ${unusedKeys.length} unused keys');
      }

      final autoRemoveKeys =
          parsedArgs.autoRemoveKeys ?? kDefaultAutoRemoveKeys;

      final removeKeys = parsedArgs.removeKeys ?? [];

      if (!autoRemoveKeys) {
        if (removeKeys.isNotEmpty) {
          logger.i('Keys to remove: $removeKeys');

          final invalidKeys =
              removeKeys.where((key) => !unusedKeys.contains(key));
          if (invalidKeys.isNotEmpty) {
            logger.e('Invalid keys: ${invalidKeys.toList()}');
          }

          final validKeys = removeKeys.toSet().difference(invalidKeys.toSet());
          if (validKeys.isNotEmpty) {
            helpers.removeUnusedKeysFromJson(
              currentPath,
              localeKeysData,
              validKeys.toSet(),
              baseKeys,
              assetsDir,
              jsonIndent,
            );
          }
        } else {
          logger.i('Keys to remove: ${unusedKeys.toList()}');

          stdout.write(
            'Do you want to remove these keys from JSON files? (y/n): ',
          );
          final input = stdin.readLineSync()?.trim().toLowerCase();

          if (input != 'y') {
            logger.i('Skipping removal of unused keys.');
            return;
          } else {
            stdout.write('Do you remove specific keys? (y/n): ');
            final input = stdin.readLineSync()?.trim().toLowerCase();

            if (input == 'y') {
              stdout.write('Enter keys to remove separated by commas: ');
              final keys = stdin
                  .readLineSync()
                  ?.trim()
                  .split(',')
                  .map((key) => key.trim())
                  .toList();

              if (keys != null) {
                final validKeys = keys.toSet().intersection(unusedKeys);
                if (validKeys.isNotEmpty) {
                  helpers.removeUnusedKeysFromJson(
                    currentPath,
                    localeKeysData,
                    validKeys,
                    baseKeys,
                    assetsDir,
                    jsonIndent,
                  );
                } else {
                  logger.e('No valid keys to remove.');
                }
              }
            } else {
              helpers.removeUnusedKeysFromJson(
                currentPath,
                localeKeysData,
                unusedKeys,
                baseKeys,
                assetsDir,
                jsonIndent,
              );
            }
          }
        }
      } else {
        helpers.removeUnusedKeysFromJson(
          currentPath,
          localeKeysData,
          unusedKeys,
          baseKeys,
          assetsDir,
          jsonIndent,
        );
      }

      if (parsedArgs.exportLog ?? kDefaultExportLog) {
        logger.i('Exporting unused keys to log file...');
        helpers.exportLog(
          parsedArgs.currentPath ?? kDefaultCurrentPath,
          'easy_localization_cleaner.log',
          unusedKeys,
        );
      }
    } on Object catch (e) {
      logger.e(e.toString());
      exit(1);
    }

    logger.i('Generated in ${stopwatch.elapsedMilliseconds}ms');
  }

  static void _usageError(ArgParser argParser, String error) {
    _printUsage(argParser, error);
    exit(64);
  }

  static void _printHelp(ArgParser argParser) {
    _printUsage(argParser);
    exit(exitCode);
  }

  static void _printUsage(ArgParser argParser, [String? error]) {
    final message = error ?? _kAbout;

    stdout.write('''
$message

$_kUsage
${argParser.usage}
''');
    exit(64);
  }

  static const _kAbout =
      'A Dart CLI package designed to remove unused locale keys '
      'from JSON files used with the `easy_localization` package.';

  static const _kUsage = 'Usage: easy_localization_cleaner [options]';
}
