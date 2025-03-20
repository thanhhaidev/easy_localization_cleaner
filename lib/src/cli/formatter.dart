import 'dart:io';

import 'package:easy_localization_cleaner/src/cli/arguments.dart';

/// A helper class for managing localization keys and JSON files.
typedef CliArgumentFormatter = Object Function(String arg);

const _kArgumentFormatters = <CliArgument, CliArgumentFormatter>{
  CliArgument.configFile: File.new,
};

/// Formats arguments.
Map<CliArgument, Object?> formatArguments(Map<CliArgument, Object?> args) {
  return args.map<CliArgument, Object?>((k, v) {
    final formatter = _kArgumentFormatters[k];

    if (formatter == null || v == null) {
      return MapEntry<CliArgument, Object?>(k, v);
    }

    return MapEntry<CliArgument, Object?>(k, formatter(v.toString()));
  });
}
