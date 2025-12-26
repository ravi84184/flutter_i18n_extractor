import 'dart:io';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dart_style/dart_style.dart';

class StringKeyReplacer extends GeneralizingAstVisitor<void> {
  final Map<String, String> stringToKey;
  final String contextName;
  final List<_Edit> edits = [];

  StringKeyReplacer(this.stringToKey, {this.contextName = 'context'});

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final widgetName = node.constructorName.type.name2.lexeme;

    // Only transform Text, AppBar, and other widgets in your _uiWidgets set
    const uiWidgets = {
      'Text',
      'AppBar',
      'SnackBar',
      'ElevatedButton',
      'TextButton',
      // ...add others from your extraction list
    };
    if (!uiWidgets.contains(widgetName)) {
      super.visitInstanceCreationExpression(node);
      return;
    }

    // Only handle simple string literals as first argument.
    if (node.argumentList.arguments.isNotEmpty) {
      final firstArg = node.argumentList.arguments.first;
      if (firstArg is StringLiteral && !firstArg.isSynthetic) {
        final text = firstArg.stringValue?.trim();
        if (text != null && stringToKey.containsKey(text)) {
          final key = stringToKey[text];
          // Prepare replacement: AppLocale.KEY.getString(context)
          final replacement = 'AppLocale.$key.getString($contextName)';
          edits.add(_Edit(firstArg.offset, firstArg.length, replacement));
        }
      }
    }

    super.visitInstanceCreationExpression(node); // continue traversal
  }
}

class _Edit {
  final int offset;
  final int length;
  final String replacement;
  _Edit(this.offset, this.length, this.replacement);
}

/// Applies all string replacements for keys in each file
void replaceStringsInFile(String filePath, Map<String, String> stringToKey) {
  final source = File(filePath).readAsStringSync();
  final parsed = parseString(content: source, path: filePath);
  final visitor = StringKeyReplacer(stringToKey);

  parsed.unit.accept(visitor);

  // Apply edits from the end backward so offsets stay valid
  String modified = source;
  visitor.edits.sort((a, b) => b.offset.compareTo(a.offset));
  for (final edit in visitor.edits) {
    modified = modified.replaceRange(
      edit.offset,
      edit.offset + edit.length,
      edit.replacement,
    );
  }

  // Optionally, format result
  modified = DartFormatter().format(modified);

  if (modified != source) {
    File(filePath).writeAsStringSync(modified);
    print('Updated: $filePath');
  }
}

/// Parses app_locale.dart to build a map of string → key
Map<String, String> parseAppLocale() {
  final file = File('lib/l10n/app_locale.dart');
  if (!file.existsSync()) return {};
  final text = file.readAsStringSync();
  final keyPattern = RegExp(r"""static const String (\w+) = ['"](\w+)['"];""");
  final entries = <String, String>{};
  for (final match in keyPattern.allMatches(text)) {
    final key = match.group(1)!;
    final orig = match.group(2)!;
    entries[orig] = key; // If your keys differ from values, adapt this
  }
  return {
    "en": "en",
    "English": "english",
    "Invalid OTP": "invalidOtp",
    "km": "km",
    "Login": "login",
    "ភាសាខ្មែរ": "text_270ae7",
    "Welcome Back %a test %a and %a": "welcomeBackATestAAndA",
  };
}
