import 'dart:io';

import 'package:easy_localization_cleaner/easy_localization_cleaner.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:test/test.dart';

void main() {
  test('Show help message', () {
    EasyLocalizationCleaner.run(['--help']);
  });

  test('Remove unused keys', () {
    EasyLocalizationCleaner.run(
      ['--current-path', 'example'],
    );
    final totalLines = Glob('example/assets/translations/en-US.json')
        .listSync()
        .map((file) => File(file.path).readAsLinesSync().length)
        .reduce((value, element) => value + element);

    expect(totalLines, 47);
  });

  test('All keys are used', () async {
    const scriptPath = './generate_locale_keys.sh';
    await Process.run('chmod', ['+x', scriptPath]);

    final result = await Process.run('sh', [scriptPath]);

    expect(result.exitCode, 0);

    final totalLines = Glob('example/assets/translations/en-US.json')
        .listSync()
        .map((file) => File(file.path).readAsLinesSync().length)
        .reduce((value, element) => value + element);

    EasyLocalizationCleaner.run([]);

    expect(totalLines, 47);
  });
}
