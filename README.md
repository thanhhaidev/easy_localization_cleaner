# easy_localization_cleaner

[![pub package](https://img.shields.io/pub/v/easy_localization_cleaner.svg)](https://pub.dartlang.org/packages/easy_localization_cleaner)

`easy_localization_cleaner` is a Dart CLI tool designed to clean up unused localization keys from JSON files used with the `easy_localization` package. It helps developers maintain clean and organized localization files by identifying and removing unused keys.

## Features

- **Extract Localization Keys**: Scans your Dart files for localization keys.
- **Identify Unused Keys**: Compares the keys in your JSON files with the ones used in your code.
- **Remove Unused Keys**: Safely removes unused keys from your JSON files while preserving base keys.
- **Export Logs**: Generates a log file listing unused keys for review.

## Installation 💻

### Install via dev dependency

```shell
$ flutter pub add --dev easy_localization_cleaner

# And it's ready to go:
$ dart run easy_localization_cleaner:main [options]
```

### or [Globally activate][] the package:

[globally activate]: https://dart.dev/tools/pub/cmd/pub-global

```shell
$ dart pub global activate easy_localization_cleaner

# And it's ready to go:
$ easy_localization_cleaner [options]
```

## Usage 🚀

To use `easy_localization_cleaner`, run the following command:

```shell
$ easy_localization_cleaner --current-path=/path/to/project --assets-dir=assets/translations
```

### Options

| Option                  | Description                                     | Default Value                   |
| ----------------------- | ----------------------------------------------- | ------------------------------- |
| `--current-path`        | The current path of the project.                | Current directory (`.`)         |
| `--generated-class-key` | The name of the generated class key.            | `LocaleKeys`                    |
| `--assets-dir`          | The directory where the JSON files are located. | `assets/translations`           |
| `--export-log-file`     | The path to export the log file.                | `easy_localization_cleaner.log` |
| `--help`, `-h`          | Display the help message.                       |

## Contributing 🤝

Contributions are welcome! Please open an issue or submit a pull request.

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
