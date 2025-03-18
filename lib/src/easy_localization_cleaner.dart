import 'dart:io';

import 'package:args/args.dart';
import 'package:easy_localization_cleaner/src/helpers/helpers.dart';

/// A Dart CLI package designed to remove unused locale keys from JSON files
/// used with the `easy_localization` package.
class EasyLocalizationCleaner {
  /// The current path of the project.
  /// Defaults to the current directory.
  static String currentPath = Directory.current.path;

  /// The name of the generated class key.
  /// Defaults to `LocaleKeys`.
  static String generatedClassKey = 'LocaleKeys';

  /// The directory where the JSON files are located.
  /// Defaults to `assets/translations`.
  static String assetsDir = 'assets/translations';

  /// An instance of [LocalizationHelpers]
  /// to perform localization-related operations.
  static final helpers = LocalizationHelpers();

  /// The path to export the log file.
  /// Defaults to `easy_localization_cleaner.log`.
  static String logFilePath = 'easy_localization_cleaner.log';

  /// The main entry point for the CLI tool.
  ///
  /// [args] are the command-line arguments passed to the tool.
  static void run(List<String> args) {
    if (isHelpCommand(args)) {
      help();
      return;
    }

    writeInfo('Checking for used keys in $currentPath');

    init(args);

    final generatedClassPath = helpers.generatedClassPath(generatedClassKey);

    final localeKeysData =
        helpers.extractLocaleKeys(currentPath, generatedClassPath);

    final localeKeys = localeKeysData.keys.toSet();

    final usedKeys = helpers.usedKeys(currentPath);
    final baseKeys = helpers.extractBaseKeys(currentPath, generatedClassPath);

    final unusedKeys = localeKeys.difference(usedKeys);

    final totalKeys = localeKeys.length - baseKeys.length;
    final usedKeysCount = localeKeys.length - unusedKeys.length;
    final baseKeysCount = baseKeys.length;

    writeInfo(
      'Found total locale keys: $totalKeys, '
      'used keys: $usedKeysCount, '
      'base keys: $baseKeysCount',
    );

    if (unusedKeys.length == baseKeys.length) {
      writeSuccess('All LocaleKeys are used.');
      return;
    } else {
      writeError('Found ${unusedKeys.length - baseKeys.length} unused keys');
    }

    helpers
      ..exportLog(
        currentPath,
        logFilePath,
        unusedKeys,
      )
      ..removeUnusedKeysFromJson(
        currentPath,
        localeKeysData,
        unusedKeys,
        baseKeys,
        assetsDir,
      );
  }

  /// Initializes the CLI tool by parsing command-line arguments.
  ///
  /// [args] are the command-line arguments passed to the tool.
  static void init(List<String> args) {
    ArgParser()
      ..addOption(
        'current-path',
        abbr: 'c', // Short command for --current-path
        help: 'The current path of the project. '
            'Defaults to the current directory.',
        defaultsTo: Directory.current.path,
        callback: (value) {
          currentPath = value ?? Directory.current.path;
        },
      )
      ..addOption(
        'generated-class-key',
        abbr: 'g',
        help: 'The name of the generated class key. '
            'Defaults to `LocaleKeys`.',
        callback: (value) {
          generatedClassKey = value ?? 'LocaleKeys';
        },
      )
      ..addOption(
        'assets-dir',
        abbr: 'a',
        help: 'The directory where the JSON files are located. '
            'Defaults to `assets/translations`.',
        defaultsTo: 'assets/translations',
        callback: (value) {
          assetsDir = value ?? 'assets/translations';
        },
      )
      ..addOption(
        'export-log-file',
        abbr: 'e',
        help: 'The path to export the log file. '
            'Defaults to `easy_localization_cleaner.log`.',
        defaultsTo: 'easy_localization_cleaner.log',
      )
      ..parse(args);
  }

  /// Checks if the provided arguments contain a help command.
  ///
  /// [args] are the command-line arguments passed to the tool.
  /// Returns `true` if the help command is found, otherwise `false`.
  static bool isHelpCommand(List<String> args) {
    return args.contains('--help') || args.contains('-h');
  }

  /// Displays the help message for the CLI tool.
  static void help() {
    print('Usage: easy_localization_cleaner [options]\n');
    print('Options:');
    print(
      '--current-path\t\tThe current path of the project. '
      'Defaults to the current directory.',
    );
    print(
      '--generated-class-key\tThe name of the generated class key. '
      'Defaults to `LocaleKeys`.',
    );
    print(
      '--assets-dir\t\tThe directory where the JSON files are located. '
      'Defaults to `assets/translations`.',
    );
    print(
      '--export-log-file\tThe path to export the log file. '
      'Defaults to `easy_localization_cleaner.log`.',
    );
    print(
      '--help, -h\t\tDisplay this help message.',
    );
  }
}
