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

  /// The JSON indentation format.
  /// Defaults to 2 spaces.
  static String jsonIndent = '  ';

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

    final totalKeys = localeKeys.length;
    final usedKeysCount = localeKeys.length - unusedKeys.length;
    final baseKeysCount = baseKeys.length;

    writeInfo(
      'Found total locale keys: $totalKeys, '
      'used keys: $usedKeysCount, '
      'base keys: $baseKeysCount',
    );

    if (totalKeys == usedKeysCount) {
      writeSuccess('All LocaleKeys are used.');
      return;
    } else {
      writeError('Found ${unusedKeys.length - baseKeys.length} unused keys');
    }

    if (isExportCommand(args)) {
      helpers.exportLog(
        currentPath,
        logFilePath,
        unusedKeys,
      );
    }

    helpers.removeUnusedKeysFromJson(
      currentPath,
      localeKeysData,
      unusedKeys,
      baseKeys,
      assetsDir,
      jsonIndent,
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
      ..addFlag(
        'export',
        abbr: 'e',
        help: 'Save unused keys as a .log file in the path provided.',
      )
      ..addOption(
        'json-indent',
        abbr: 'j',
        help: 'Specify the JSON indentation format. '
            r'Use "\t" for tabs or a number (e.g., 4) for spaces.',
        defaultsTo: '  ',
        callback: (value) {
          print(value);
          if (value == r'\t' || value == 't') {
            jsonIndent = '\t';
          } else {
            final spaces = int.tryParse(value ?? '2');
            jsonIndent = spaces != null ? ' ' * spaces : '  ';
          }
        },
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

  /// Checks if the provided arguments contain an export command.
  ///
  /// [args] are the command-line arguments passed to the tool.
  /// Returns `true` if the export command is found, otherwise `false`.
  static bool isExportCommand(List<String> args) {
    return args.contains('--export') || args.contains('-e');
  }

  /// Displays the help message for the CLI tool.
  static void help() {
    print('Usage: easy_localization_cleaner [options]\n');
    print('Options:');
    print(
      '--current-path, -c\t\tThe current path of the project. '
      'Defaults to the current directory.',
    );
    print(
      '--generated-class-key, -g\tThe name of the generated class key. '
      'Defaults to `LocaleKeys`.',
    );
    print(
      '--assets-dir\t\t\tThe directory where the JSON files are located. '
      'Defaults to `assets/translations`.',
    );
    print(
      '--[no-]export, -e\t\tSave unused keys as a .log file '
      'in the path provided.',
    );
    print(
      '--json-indent, -j\t\tSpecify the JSON indentation format. '
      r'Use "\t" for tabs or a number (e.g., 4) for spaces.',
    );
    print(
      '--help, -h\t\t\tDisplay this help message.',
    );
  }
}
