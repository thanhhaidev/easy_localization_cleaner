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
