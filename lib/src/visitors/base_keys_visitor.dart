import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// A visitor class to extract base keys from variable declarations
/// in Dart files.
///
/// Base keys are extracted from variable names that follow a specific pattern,
/// such as `currencies_usd`, where `currencies` is considered the base key.
class BaseKeysVisitor extends GeneralizingAstVisitor<void> {
  /// A set to store the extracted base keys.
  final Set<String> baseKeys = <String>{};

  /// Visits variable declarations to extract base keys.
  ///
  /// For example, a variable named `currencies_usd` with an initializer
  /// containing a dot (e.g., `currencies.usd`) will result in extracting
  /// `currencies` as the base key.
  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final name = node.name.lexeme;
    final parts = name.split('_');
    if (parts.length > 1 && node.initializer.toString().contains('.')) {
      baseKeys.add(parts[0]);
    }
    super.visitVariableDeclaration(node);
  }
}
