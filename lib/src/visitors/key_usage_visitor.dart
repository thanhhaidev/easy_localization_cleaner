import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// A visitor class to extract localization keys used in Dart files.
///
/// This class identifies keys used in method invocations such as:
/// - `'key'.tr()`
/// - `tr('key')`
/// - `'key'.plural(1)`
/// - `plural('key', 1)`
/// - `LocaleKeys.key.tr()`
/// - `Text('key').tr()`
/// - `LocaleKeys.key`
class KeyUsageVisitor extends GeneralizingAstVisitor<void> {
  /// Creates a new instance of [KeyUsageVisitor].
  KeyUsageVisitor(this.generatedClassKey);

  /// A set to store the extracted localization keys.
  final Set<String> usedKeys = <String>{};

  /// The name of the generated class key.
  final String generatedClassKey;

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
  /// - `LocaleKeys.key`
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
      if (target.prefix.name == generatedClassKey) {
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
          argument.prefix.name == generatedClassKey) {
        // Handle cases like Text(LocaleKeys.key).tr().
        usedKeys.add(argument.identifier.name);
      }
    }
  }

  /// Visits prefixed identifiers to extract localization keys.
  ///
  /// Handles cases like:
  /// - `LocaleKeys.key`
  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.prefix.name == generatedClassKey) {
      // Handle cases like LocaleKeys.key used directly.
      usedKeys.add(node.identifier.name);
    }
    super.visitPrefixedIdentifier(node);
  }
}
