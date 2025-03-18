import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// A visitor class to extract locale keys and their values from variable
/// declarations in Dart files.
///
/// For example, it can extract `currencies_usd` as the key and `currencies.usd`
/// as the value from a declaration like:
/// `static const currencies_usd = 'currencies.usd';`
class LocaleKeysVisitor extends GeneralizingAstVisitor<void> {
  /// A map to store the extracted keys and their corresponding values.
  final Map<String, String> keysAndValues = <String, String>{};

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final key = node.name.lexeme;

    // Check if the variable has an initializer and if it's a string literal.
    final initializer = node.initializer;
    if (initializer is SimpleStringLiteral) {
      final value = initializer.value;
      keysAndValues[key] = value;
    }

    super.visitVariableDeclaration(node);
  }
}
