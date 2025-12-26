import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class StringVisitor extends RecursiveAstVisitor<void> {
  final Set<String> texts = {};

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (_shouldIgnore(node)) return;
    final value = node.value.trim();
    if (_isValid(value)) {
      texts.add(value);
    }
    super.visitSimpleStringLiteral(node);
  }

  bool _shouldIgnore(SimpleStringLiteral node) {
    final parent = node.parent;
    // Ignore imports/exports
    if (parent is ImportDirective || parent is ExportDirective) {
      return true;
    }
    return false;
  }

  bool _isValid(String value) {
    if (value.isEmpty) return false;
    if (value.length < 2) return false;

    final lower = value.toLowerCase();

    if (lower.startsWith('package:')) return false;
    if (lower.startsWith('dart:')) return false;
    if (lower.startsWith('http')) return false;
    if (value.contains(RegExp(r'[\\/]'))) return false; // paths
    if (value.contains(RegExp(r'[\[\]\^\$]'))) return false; // regex

    return true;
  }
}
