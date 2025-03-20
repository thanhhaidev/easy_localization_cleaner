import 'dart:io';

import 'package:args/args.dart';
import 'package:easy_localization_cleaner/src/cli/formatter.dart';
import 'package:easy_localization_cleaner/src/utils/enum_class.dart';
import 'package:easy_localization_cleaner/src/utils/logger.dart';
import 'package:yaml/yaml.dart';

const _kDefaultConfigPathList = [
  'pubspec.yaml',
  'easy_localization_cleaner.yaml',
];

const _kArgAllowedTypes = <CliArgument, List<Type>>{
  CliArgument.currentPath: [String],
  CliArgument.generatedClassKey: [String],
  CliArgument.assetsDir: [String],
  CliArgument.exportLog: [bool],
  CliArgument.jsonIndent: [String],
  CliArgument.autoRemoveKeys: [bool],
  CliArgument.removeKeys: [List<String>],
  CliArgument.verbose: [bool],
  CliArgument.help: [bool],
};

/// Default value for the verbose flag.
/// Indicates whether detailed logging is enabled.
const kDefaultVerbose = false;

/// Default value for the format flag.
/// Indicates whether formatting is enabled.
const kDefaultFormat = false;

/// Default value for the current path of the project.
/// Uses the current working directory as the default.
String kDefaultCurrentPath = Directory.current.path;

/// Default value for the generated class key.
/// Specifies the name of the generated class key.
const kDefaultGeneratedClassKey = 'LocaleKeys';

/// Default value for the assets directory.
/// Specifies the directory where the JSON files are located.
const kDefaultAssetsDir = 'assets/translations';

/// Default value for the export log flag.
/// Indicates whether unused keys should be saved as a `.log` file.
const kDefaultExportLog = false;

/// Default value for the JSON indentation format.
/// Specifies the default indentation as 2 spaces.
const kDefaultJsonIndent = '  ';

/// Default value for the auto-remove-keys flag.
/// Indicates whether unused keys should be automatically removed.
const kDefaultAutoRemoveKeys = true;

/// Default value for the list of keys to remove.
/// Specifies an empty list as the default.
const kDefaultRemoveKeys = <String>[];

/// Maps CLI arguments to their corresponding option names.
///
/// This map defines the string identifiers for each CLI argument
/// that can be passed via the command line.
const kOptionNames = EnumClass<CliArgument, String>({
  CliArgument.configFile: 'config-file',
  CliArgument.currentPath: 'current-path',
  CliArgument.generatedClassKey: 'generated-class-key',
  CliArgument.assetsDir: 'assets-dir',
  CliArgument.exportLog: 'export-log',
  CliArgument.jsonIndent: 'json-indent',
  CliArgument.autoRemoveKeys: 'auto-remove-keys',
  CliArgument.removeKeys: 'remove-keys',
  CliArgument.help: 'help',
  CliArgument.verbose: 'verbose',
});

/// Maps CLI arguments to their corresponding configuration keys.
///
/// This map defines the string identifiers for each CLI argument
/// that can be used in configuration files (e.g., YAML).
const kConfigKeys = EnumClass<CliArgument, String>({
  CliArgument.currentPath: 'current_path',
  CliArgument.generatedClassKey: 'generated_class_key',
  CliArgument.assetsDir: 'assets_dir',
  CliArgument.exportLog: 'export_log',
  CliArgument.jsonIndent: 'json_indent',
  CliArgument.autoRemoveKeys: 'auto_remove_keys',
  CliArgument.removeKeys: 'remove_keys',
  CliArgument.verbose: 'verbose',
});

final Map<CliArgument, String> _argumentNames = {
  ...kConfigKeys.map,
  ...kOptionNames.map,
};

/// Enum for CLI arguments.
enum CliArgument {
  /// The path to the config file.
  configFile,

  /// Current path of the project.
  currentPath,

  /// The name of the generated class key.
  generatedClassKey,

  /// The directory where the JSON files are located.
  assetsDir,

  /// Save unused keys as a .log file in the path provided.
  exportLog,

  /// Specify the JSON indentation format.
  jsonIndent,

  /// Automatically removes unused keys from JSON files.
  autoRemoveKeys,

  /// List of keys to remove by key.
  removeKeys,

  /// Shows this usage information.
  help,

  /// Enables verbose logging for detailed output.
  verbose,
}

/// Contains all the parsed data for the application.
class CliArguments {
  /// Creates an instance of [CliArguments].
  CliArguments({
    this.configFile,
    this.currentPath,
    this.generatedClassKey,
    this.assetsDir,
    this.exportLog,
    this.jsonIndent,
    this.autoRemoveKeys,
    this.removeKeys,
    this.verbose,
  });

  /// Creates [CliArguments] for a map of raw values.
  ///
  /// Validates type of each argument and formats them.
  ///
  /// Throws [CliArgumentException], if there is an error in arg parsing
  /// or if argument has wrong type.
  factory CliArguments.fromMap(Map<CliArgument, Object?> map) {
    return CliArguments(
      configFile: map[CliArgument.configFile] as File?,
      currentPath: map[CliArgument.currentPath] as String?,
      generatedClassKey: map[CliArgument.generatedClassKey] as String?,
      assetsDir: map[CliArgument.assetsDir] as String?,
      exportLog: map[CliArgument.exportLog] as bool?,
      jsonIndent: map[CliArgument.jsonIndent] as String?,
      autoRemoveKeys: map[CliArgument.autoRemoveKeys] as bool?,
      removeKeys: map[CliArgument.removeKeys] as List<String>?,
      verbose: map[CliArgument.verbose] as bool?,
    );
  }

  /// The current path of the project.
  final File? configFile;

  /// The current path of the project.
  final String? currentPath;

  /// The name of the generated class key.
  final String? generatedClassKey;

  /// The directory where the JSON files are located.
  final String? assetsDir;

  /// Whether to save unused keys as a `.log` file in the path provided.
  final bool? exportLog;

  /// The JSON indentation format (e.g., `\t` for tabs or a number for spaces).
  final String? jsonIndent;

  /// Whether to automatically remove unused keys from JSON files.
  final bool? autoRemoveKeys;

  /// A list of keys to remove by key.
  ///
  /// This allows users to specify specific keys
  /// to be removed from the JSON files.
  final List<String>? removeKeys;

  /// Whether verbose logging is enabled for detailed output.
  final bool? verbose;
}

/// Parses argument list.
///
/// Throws [CliHelpException], if 'help' option is present.
///
/// Returns an instance of [CliArguments] containing all parsed data.
Map<CliArgument, Object?> parseArguments(
  ArgParser argParser,
  List<String> args,
) {
  late final ArgResults argResults;
  try {
    argResults = argParser.parse(args);
  } on FormatException catch (err) {
    throw CliArgumentException(err.message);
  }

  if (argResults['help'] as bool) {
    throw CliHelpException();
  }
  final rawArgMap = <CliArgument, Object?>{
    for (final e in kOptionNames.entries) e.key: argResults[e.value] as Object?,
  };

  if (rawArgMap[CliArgument.removeKeys] is String) {
    final keys = (rawArgMap[CliArgument.removeKeys]! as String)
        .split(',')
        .map((key) => key.trim())
        .toList();
    rawArgMap[CliArgument.removeKeys] = keys;
  }

  return rawArgMap;
}

MapEntry<CliArgument, Object?>? _mapConfigKeyEntry(
  MapEntry<dynamic, dynamic> e,
) {
  final dynamic rawKey = e.key;
  void logUnknown() => logger.w('Unknown config parameter "$rawKey"');

  if (rawKey is! String) {
    logUnknown();
    return null;
  }

  final key = kConfigKeys.getKeyForValue(rawKey);
  if (key == null) {
    logUnknown();
    return null;
  }

  // Handle `remove_keys` specifically to support both YamlList and List<String>
  if (key == CliArgument.removeKeys) {
    final value = e.value;
    if (value is YamlList) {
      return MapEntry<CliArgument, Object?>(key, List<String>.from(value));
    } else if (value is List) {
      return MapEntry<CliArgument, Object?>(key, value.cast<String>());
    } else {
      logger.w('Invalid type for "remove_keys". Expected a list of strings.');
      return null;
    }
  }

  if (key == CliArgument.jsonIndent && e.value is int) {
    return MapEntry<CliArgument, Object?>(key, e.value.toString());
  }

  return MapEntry<CliArgument, Object?>(key, e.value);
}

/// Parses config file.
///
/// Returns an instance of [CliArguments] containing all parsed data or null,
/// if 'easy_localization_cleaner' key is not present in config file.
Map<CliArgument, Object?>? parseConfig(String config) {
  final yamlMap = loadYaml(config) as Object?;

  if (yamlMap is! YamlMap) {
    return null;
  }

  final easyTranslationCleanerYamlMap =
      yamlMap['easy_localization_cleaner'] as Object?;
  if (easyTranslationCleanerYamlMap is! YamlMap) {
    return null;
  }

  final entries =
      easyTranslationCleanerYamlMap.entries.map(_mapConfigKeyEntry).nonNulls;

  return Map<CliArgument, Object?>.fromEntries(entries);
}

/// Parses argument list and config file, validates parsed data.
/// Config is used, if it contains 'easy_localization_cleaner' section.
///
/// Throws [CliHelpException], if 'help' option is present.
/// Throws [CliArgumentException], if there is an error in arg parsing.
CliArguments parseArgsAndConfig(ArgParser argParser, List<String> args) {
  var parsedArgs = parseArguments(argParser, args);
  final dynamic configFile = parsedArgs[CliArgument.configFile];

  final configList = <String>[
    if (configFile is String) configFile,
    ..._kDefaultConfigPathList,
  ].map(File.new);

  for (final configFile in configList) {
    if (configFile.existsSync()) {
      final parsedConfig = parseConfig(configFile.readAsStringSync());

      if (parsedConfig != null) {
        logger.i('Using config ${configFile.path}');
        parsedArgs = parsedConfig;
        break;
      }
    }
  }

  return CliArguments.fromMap(parsedArgs.validateAndFormat());
}

/// Exception for argument parsing.
class CliArgumentException implements Exception {
  /// Creates an instance of [CliArgumentException].
  CliArgumentException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => message;
}

/// Exception for help command.
class CliHelpException implements Exception {}

/// Extension for [Map] of [CliArgument] to validate and format arguments.
extension CliArgumentMapExtension on Map<CliArgument, Object?> {
  /// Validates raw CLI arguments.
  ///
  /// Throws [CliArgumentException], if argument is not valid.
  void _validateRaw() {
    // Validating types
    for (final e in _kArgAllowedTypes.entries) {
      final arg = e.key;
      final argType = this[arg].runtimeType;
      final allowedTypes = e.value;

      if (argType != Null && !allowedTypes.contains(argType)) {
        throw CliArgumentException("'${_argumentNames[arg]}' argument's type "
            'must be one of following: $allowedTypes, '
            "instead got '$argType'.");
      }
    }
  }

  /// Validates formatted CLI arguments.
  ///
  /// Throws [CliArgumentException], if argument is not valid.
  void _validateFormatted() {}

  /// Validates and formats CLI arguments.
  ///
  /// Throws [CliArgumentException], if argument is not valid.
  Map<CliArgument, Object?> validateAndFormat() {
    _validateRaw();
    return formatArguments(this).._validateFormatted();
  }
}
