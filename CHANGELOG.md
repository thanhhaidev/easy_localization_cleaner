# 0.0.6

- Added support for the `--remove-keys` (`-k`) command to manually specify keys to remove from JSON files.
  - Accepts a comma-separated list of keys (e.g., `--remove-keys=key1,key2`).
- Added support for the `--auto-remove-keys` (`-r`) flag to allow user confirmation before removing unused keys when set to `false`.
- Added support for reading configuration from `easy_localization_cleaner.yaml` or `pubspec.yaml`.
  - The `easy_localization_cleaner` section can now be defined in either file.
  - Supported configuration options:
    - `current_path`: Specifies the current project path for locating files and resources.
    - `remove_keys`: A list of keys to remove from JSON files.
    - `auto_remove_keys`: A flag to enable or disable automatic removal of unused keys.
    - `export_log`: A flag to enable or disable exporting unused keys to a log file.
    - `assets_dir`: Specifies the directory where the JSON files are located.
    - `json_indent`: Specifies the number of spaces or tab character for JSON indentation.

# 0.0.5

- Remove log and update README

# 0.0.4

- Fixed an issue where the `--json-indent=\t` command was not correctly interpreted as a tab character.
  - Now supports both `--json-indent=\t` and `--json-indent=t` for specifying tab indentation.
- Improved the `--json-indent` option to handle edge cases and ensure proper fallback to default values.

# 0.0.3

- Added support for the `--json-indent` (`-j`) command to specify JSON indentation format.
  - Use `\t` for tabs or a number (e.g., `4`) for spaces.
  - Default indentation is 2 spaces.
- Updated the `removeUnusedKeysFromJson` method to dynamically handle JSON indentation based on the provided command-line argument.
- Updated the README with examples and documentation for the `--json-indent` command.

# 0.0.2

- Added support for short commands (e.g., `-c` for `--current-path`, `-g` for `--generated-class-key`).
- Improved handling of `LocaleKeys.key` in the `KeyUsageVisitor` to support direct usage without method invocations.
- Fixed lint issues by ensuring all lines are within the 80-character limit.

# 0.0.1

- Initial version.
