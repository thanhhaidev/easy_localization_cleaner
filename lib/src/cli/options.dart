import 'package:args/args.dart';

import 'package:easy_localization_cleaner/src/cli/arguments.dart';

/// Define the options for the CLI tool.
void defineOptions(ArgParser argParser) {
  argParser
    ..addSeparator('Required options:')
    ..addOption(
      kOptionNames[CliArgument.currentPath]!,
      abbr: 'p',
      help: 'The current path of the project.',
      valueHelp: '.',
      defaultsTo: kDefaultCurrentPath,
    )
    ..addOption(
      kOptionNames[CliArgument.generatedClassKey]!,
      abbr: 'g',
      help: 'The name of the generated class key.',
      valueHelp: 'LocaleKeys',
      defaultsTo: kDefaultGeneratedClassKey,
    )
    ..addOption(
      kOptionNames[CliArgument.assetsDir]!,
      abbr: 'a',
      help: 'The directory where the JSON files are located.',
      valueHelp: 'assets/translations',
      defaultsTo: kDefaultAssetsDir,
    )
    ..addSeparator('Other options:')
    ..addOption(
      kOptionNames[CliArgument.configFile]!,
      abbr: 'z',
      help: 'Path to easy_translation_cleaner yaml configuration file.',
      valueHelp: 'easy_translation_cleaner.yaml',
    )
    ..addFlag(
      kOptionNames[CliArgument.autoRemoveKeys]!,
      abbr: 'r',
      help: 'Automatically remove unused keys from JSON files.',
      defaultsTo: kDefaultAutoRemoveKeys,
    )
    ..addOption(
      kOptionNames[CliArgument.removeKeys]!,
      abbr: 'k',
      help: 'Manually remove unused keys from JSON files.',
      valueHelp: 'key1,key2,key3',
    )
    ..addOption(
      kOptionNames[CliArgument.jsonIndent]!,
      abbr: 'j',
      help: 'The number of spaces to use for JSON indentation.',
      valueHelp: '2',
      defaultsTo: kDefaultJsonIndent,
    )
    ..addFlag(
      kOptionNames[CliArgument.exportLog]!,
      abbr: 'l',
      help: 'Save unused keys as a .log file in the path provided.',
    )
    ..addFlag(
      kOptionNames[CliArgument.verbose]!,
      abbr: 'v',
      help: 'Display every logging message.',
      negatable: false,
    )
    ..addFlag(
      kOptionNames[CliArgument.help]!,
      abbr: 'h',
      help: 'Shows this usage information.',
      negatable: false,
    );
}
