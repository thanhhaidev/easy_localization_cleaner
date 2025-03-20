# easy_localization_cleaner

[![pub package](https://img.shields.io/pub/v/easy_localization_cleaner.svg)](https://pub.dartlang.org/packages/easy_localization_cleaner)

`easy_localization_cleaner` is a Dart CLI tool designed to clean up unused localization keys from JSON files used with the `easy_localization` package. It helps developers maintain clean and organized localization files by identifying and removing unused keys.

## Features

- **Extract Localization Keys**: Scans your Dart files for localization keys.
- **Identify Unused Keys**: Compares the keys in your JSON files with the ones used in your code.
- **Remove Unused Keys**: Safely removes unused keys from your JSON files while preserving base keys.
- **Manually Remove Keys**: Specify keys to remove using the `--remove-keys` option.
- **Export Logs**: Generates a log file listing unused keys for review.
- **Format JSON Files**: Allows you to specify the indentation format for JSON files (e.g., tabs or spaces).
- **Configuration Support**: Supports configuration via `easy_localization_cleaner.yaml` or `pubspec.yaml`.

## Installation 💻

### Install via dev dependency

```shell
$ flutter pub add --dev easy_localization_cleaner

# And it's ready to go:
$ dart run easy_localization_cleaner [options]
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

| Option                        | Description                                                                                | Default Value           |
| ----------------------------- | ------------------------------------------------------------------------------------------ | ----------------------- |
| `--current-path` , `-p`       | The current path of the project.                                                           | Current directory (`.`) |
| `--generated-class-key`, `-g` | The name of the generated class key.                                                       | `LocaleKeys`            |
| `--assets-dir`, `-a`          | The directory where the JSON files are located.                                            | `assets/translations`   |
| `--remove-keys`, `-k`         | Manually specify keys to remove from JSON files (comma-separated).                         | None                    |
| `--[no-]export`, `-e`         | Save unused keys as a .log file in the path provided.                                      | false                   |
| `--json-indent`, `-j`         | Specify the JSON indentation format. Use `\t` for tabs or a number (e.g., `4`) for spaces. | 2 spaces                |
| `--auto-remove-keys`, `-r`    | Automatically remove unused keys without confirmation.                                     | true                    |
| `--help`, `-h`                | Display the help message.                                                                  |

### Examples

1. **Default Usage**:

   ```shell
   $ easy_localization_cleaner
   ```

2. **Specify JSON Indentation with Tabs**:

   ```shell
   $ easy_localization_cleaner --json-indent=\t
   ```

3. **Specify JSON Indentation with 4 Spaces**:

   ```shell
   $ easy_localization_cleaner --json-indent=4
   ```

4. **Manually Remove Specific Keys**:

   ```shell
   $ easy_localization_cleaner --remove-keys=key1,key2,key3
   ```

5. **Run with All Options**:

   ```shell
   $ easy_localization_cleaner --current-path=/path/to/project --assets-dir=assets/translations --json-indent=4 --export --remove-keys=key1,key2
   ```

## Configuration 📄

You can configure `easy_localization_cleaner` using either `easy_localization_cleaner.yaml` or the `easy_localization_cleaner` section in `pubspec.yaml`. Below is an example configuration:

```yaml
easy_localization_cleaner:
  current_path: .
  remove_keys:
    - "key1"
    - "key2"
  auto_remove_keys: false
  export_log: true
  assets_dir: assets/translations
  json_indent: 2
```

### Configuration Options

- `current_path`: Specifies the current project path for locating files and resources.
- `remove_keys`: A list of keys to remove from JSON files.
- `auto_remove_keys`: A flag to enable or disable automatic removal of unused keys.
- `export_log`: A flag to enable or disable exporting unused keys to a log file.
- `assets_dir`: Specifies the directory where the JSON files are located.
- `json_indent`: Specifies the number of spaces or tab character for JSON indentation.

## Contributing 🤝

Contributions are welcome! Please open an issue or submit a pull request.

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
