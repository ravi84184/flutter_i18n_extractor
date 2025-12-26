import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class StringVisitor extends RecursiveAstVisitor<void> {
  final Set<String> texts = {};

  // List of UI widget constructors to extract strings from
  static const _uiWidgets = {
    'Text',
    'AppBar',
    'SnackBar',
    'ElevatedButton',
    'TextButton',
    'OutlinedButton',
    'FloatingActionButton',
    'Dialog',
    'AlertDialog',
    'SimpleDialog',
    'Tooltip',
    'Chip',
    'ListTile',
    'Card',
    'CheckboxListTile',
    'RadioListTile',
    'SwitchListTile',
    'TextField',
    'TextFormField',
    'DropdownButton',
    'DropdownMenuItem',
    'Tab',
    'BottomNavigationBarItem',
    'Drawer',
    'DrawerHeader',
    'AboutListTile',
    'PopupMenuItem',
    'MenuItemButton',
  };

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    super.visitSimpleStringLiteral(node);

    if (_shouldIgnore(node)) return;

    // Check if this string is in a UI widget
    if (!_isInUIWidget(node)) return;

    final value = node.value.trim();
    if (_isValid(value)) {
      texts.add(value);
    }
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    // Always call super first to ensure recursive traversal
    super.visitStringInterpolation(node);

    if (_shouldIgnoreInterpolation(node)) return;
    if (!_isInUIWidget(node)) return;

    // Extract the full interpolated string value
    final buffer = StringBuffer();
    for (final element in node.elements) {
      if (element is InterpolationString) {
        buffer.write(element.value);
      } else if (element is InterpolationExpression) {
        // Replace interpolation with placeholder
        buffer.write('%a');
      }
    }

    final value = buffer.toString().trim();
    if (_isValid(value)) {
      texts.add(value);
    }
  }

  bool _shouldIgnore(SimpleStringLiteral node) {
    final parent = node.parent;
    // Ignore imports/exports

    if (parent is ImportDirective || parent is ExportDirective) {
      return true;
    }

    // Ignore variable declarations/assignments (non-UI contexts)
    if (parent is VariableDeclaration) {
      return true;
    }

    if (parent is AssignmentExpression) {
      return true;
    }

    // Ignore string interpolation in non-UI contexts
    if (parent is InterpolationExpression) {
      return true;
    }

    // Ignore method/function parameters that are not widget-related
    if (parent is FormalParameter) {
      return true;
    }
    return false;
  }

  bool _shouldIgnoreInterpolation(StringInterpolation node) {
    final parent = node.parent;
    // Ignore imports/exports
    if (parent is ImportDirective || parent is ExportDirective) {
      return true;
    }

    // Ignore variable declarations/assignments (non-UI contexts)
    if (parent is VariableDeclaration) {
      return true;
    }

    if (parent is AssignmentExpression) {
      return true;
    }

    // Ignore method/function parameters that are not widget-related
    if (parent is FormalParameter) {
      return true;
    }

    return false;
  }

  bool _isInUIWidget(AstNode node) {
    // Walk up the AST to find if this string is used in a widget constructor
    // Start from parent since node itself is the string literal/interpolation
    AstNode? current = node.parent;
    int depth = 0;
    const maxDepth = 30;

    while (current != null && depth < maxDepth) {
      depth++;
      // FIRST: Check if current is an ArgumentList and its parent is a widget
      // This is the most common case: Text("Login") -> ArgumentList -> InstanceCreationExpression(Text)
      if (current is ArgumentList) {
        final parent = current.parent;
        if (parent is MethodInvocation) {
          // final type = parent.methodName;
          String typeName = parent.methodName.name;
          print(typeName);
          if (_uiWidgets.contains(typeName)) {
            return true;
          }
        }
      }

      // // Check if it's an argument to a widget constructor
      // if (current is InstanceCreationExpression) {
      //   final type = current.constructorName.type;
      //   String? typeName;

      //   if (type is NamedType) {
      //     typeName = type.name2.lexeme;
      //   }

      //   if (typeName != null && _uiWidgets.contains(typeName)) {
      //     return true;
      //   }
      // }

      // // Check if it's in a named expression (like title: Text("..."))
      // if (current is NamedExpression) {
      //   final expression = current.expression;
      //   if (expression is InstanceCreationExpression) {
      //     final type = expression.constructorName.type;
      //     String? typeName;

      //     if (type is NamedType) {
      //       typeName = type.name2.lexeme;
      //     }

      //     if (typeName != null && _uiWidgets.contains(typeName)) {
      //       return true;
      //     }
      //   }
      //   // Also check if the named expression itself is for a widget parameter
      //   // like AppBar(title: "Home")
      //   final parent = current.parent;
      //   if (parent is ArgumentList) {
      //     final grandParent = parent.parent;
      //     if (grandParent is InstanceCreationExpression) {
      //       final type = grandParent.constructorName.type;
      //       String? typeName;

      //       if (type is NamedType) {
      //         typeName = type.name2.lexeme;
      //       }

      //       if (typeName != null && _uiWidgets.contains(typeName)) {
      //         return true;
      //       }
      //     }
      //   }
      // }

      // // Check if it's in a list literal - check if any element is a widget
      // // This handles cases like children: [Text("Login")]
      // if (current is ListLiteral) {
      //   // Check if any element in the list is a widget
      //   for (final element in current.elements) {
      //     if (element is InstanceCreationExpression) {
      //       final type = element.constructorName.type;
      //       String? elementType;

      //       if (type is NamedType) {
      //         elementType = type.name2.lexeme;
      //       }

      //       if (elementType != null && _uiWidgets.contains(elementType)) {
      //         return true;
      //       }
      //     }
      //   }
      // }

      // // Also check if we're inside a widget that's an element of a list
      // // Walk up to see if we eventually reach a ListLiteral with widget elements
      // if (current is InstanceCreationExpression) {
      //   final type = current.constructorName.type;
      //   String? typeName;

      //   if (type is NamedType) {
      //     typeName = type.name2.lexeme;
      //   }

      //   if (typeName != null && _uiWidgets.contains(typeName)) {
      //     // We're inside a widget, check if it's in a list or return true anyway
      //     AstNode? checkNode = current.parent;
      //     for (int i = 0; i < 10 && checkNode != null; i++) {
      //       if (checkNode is ListLiteral) {
      //         // Found list, check if it contains widgets
      //         for (final element in checkNode.elements) {
      //           if (element is InstanceCreationExpression) {
      //             final elementTypeNode = element.constructorName.type;
      //             String? elementType;

      //             if (elementTypeNode is NamedType) {
      //               elementType = elementTypeNode.name2.lexeme;
      //             }

      //             if (elementType != null && _uiWidgets.contains(elementType)) {
      //               return true;
      //             }
      //           }
      //         }
      //       }
      //       checkNode = checkNode.parent;
      //     }
      //     // Even if not in a list, if we're directly in a widget, it's UI
      //     return true;
      //   }
      // }

      // // Stop if we've gone too far up (reached top-level or method declaration)
      // if (current is MethodDeclaration ||
      //     current is FunctionDeclaration ||
      //     current is ClassDeclaration ||
      //     current is CompilationUnit) {
      //   break;
      // }

      current = current.parent;
    }

    return false;
  }

  String? _extractTypeName(String typeString) {
    // Extract the type name from strings like "Text", "const Text", "Text?", etc.
    // Remove common prefixes and suffixes
    var cleaned = typeString.trim();

    // Remove const keyword (with or without leading whitespace)
    cleaned = cleaned.replaceFirst(RegExp(r'^\s*const\s+'), '');

    // Remove nullable marker
    cleaned = cleaned.replaceFirst(RegExp(r'\?$'), '');

    // Remove package prefix - handle various formats
    // e.g., "package:flutter/material.dart.Text" -> "Text"
    // e.g., "material.Text" -> "Text"
    cleaned = cleaned.replaceFirst(RegExp(r'^[a-zA-Z0-9_]+\.'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'^[A-Z][a-zA-Z0-9]*\.'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'^[a-z][a-zA-Z0-9_]*\.'), '');

    // Handle cases like "package:flutter/material.dart.Text" by removing everything before last dot
    final lastDot = cleaned.lastIndexOf('.');
    if (lastDot != -1) {
      cleaned = cleaned.substring(lastDot + 1);
    }

    // Extract the first capitalized word (widget names start with capital letter)
    final match = RegExp(r'^([A-Z][a-zA-Z0-9]*)').firstMatch(cleaned);
    final result = match?.group(1);

    return result;
  }

  bool _isValid(String value) {
    if (value.isEmpty) return false;
    if (value.length < 2) return false;

    final lower = value.toLowerCase();

    if (lower.startsWith('package:')) return false;
    if (lower.startsWith('dart:')) return false;
    if (lower.startsWith('http')) return false;
    if (value.contains(RegExp(r'[\\/]'))) return false; // paths
    if (value.contains(RegExp(r'[\[\]\^\$]')))
      return false; // regex (but allow $ for interpolation)

    return true;
  }
}
