// import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer/dart/ast/visitor.dart';
// import 'package:flutter_i18n_extractor/utils/key_generator.dart';

// class ReplaceCandidate {
//   final int offset;
//   final int length;
//   final String key;

//   ReplaceCandidate({
//     required this.offset,
//     required this.length,
//     required this.key,
//   });
// }




// class ReplaceVisitor extends RecursiveAstVisitor<void> {
//   final List<ReplaceCandidate> candidates = [];

//   @override
//   void visitInstanceCreationExpression(
//       InstanceCreationExpression node) {
//     final type = node.constructorName.type.name.lexeme;

//     if (type != 'Text') return;

//     final args = node.argumentList.arguments;
//     if (args.isEmpty) return;

//     final firstArg = args.first;
//     if (firstArg is! StringLiteral) return;

//     final text = firstArg.stringValue;
//     if (text == null) return;

//     final key = KeyGenerator.generate(text);

//     candidates.add(
//       ReplaceCandidate(
//         offset: firstArg.offset,
//         length: firstArg.length,
//         key: key,
//       ),
//     );
//   }
// }
