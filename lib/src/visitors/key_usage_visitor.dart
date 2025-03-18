import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:easy_localization_cleaner/easy_localization_cleaner.dart';

/// A visitor class to extract localization keys used in Dart files.
///
/// This class identifies keys used in method invocations such as:
/// - `'key'.tr()`
/// - `tr('key')`
/// - `'key'.plural(1)`
/// - `plural('key', 1)`
/// - `LocaleKeys.key.tr()`
/// - `Text('key').tr()`
class KeyUsageVisitor extends GeneralizingAstVisitor<void> {
  /// A set to store the extracted localization keys.
  final Set<String> usedKeys = <String>{};

  /// Visits method invocations to extract localization keys.
  ///
  /// This method checks for method names like `tr` or `plural` and extracts
  /// keys from the target or arguments of the method invocation.
  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;
    if (methodName == 'tr' || methodName == 'plural') {
      _extractKeyFromTarget(node.target);
      _extractKeyFromArgument(node.argumentList);
    }
    super.visitMethodInvocation(node);
  }

  /// Extracts a key from the target of a method invocation.
  ///
  /// Handles cases like:
  /// - `'key'.tr()`
  /// - `Text('key').tr()`
  /// - `LocaleKeys.key.tr()`
  void _extractKeyFromTarget(Expression? target) {
    if (target is SimpleStringLiteral) {
      // Extract key from the target of a method invocation (e.g., 'key'.tr()).
      usedKeys.add(target.value);
    } else if (target is MethodInvocation) {
      if (target.methodName.name == 'Text') {
        // Handle nested method invocations like Text('key').tr().
        _extractKeyFromArgument(target.argumentList);
      }
    } else if (target is PrefixedIdentifier) {
      if (target.prefix.name == EasyLocalizationCleaner.generatedClassKey) {
        // Handle cases like LocaleKeys.key.tr() or LocaleKeys.key.plural(1).
        usedKeys.add(target.identifier.name);
      }
    }
  }

  /// Extracts a key from the arguments of a method invocation.
  ///
  /// Handles cases like:
  /// - `tr('key')`
  /// - `plural('key', 1)`
  /// - `Text('key').tr()`
  /// - `Text(LocaleKeys.key).tr()`
  void _extractKeyFromArgument(ArgumentList argumentList) {
    for (final argument in argumentList.arguments) {
      if (argument is SimpleStringLiteral) {
        // Handle cases like tr('key') or plural('key', 1).
        usedKeys.add(argument.value);
      } else if (argument is PrefixedIdentifier &&
          argument.prefix.name == EasyLocalizationCleaner.generatedClassKey) {
        // Handle cases like Text(LocaleKeys.key).tr().
        usedKeys.add(argument.identifier.name);
      }
    }
  }
}
