import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';

import 'string_visitor.dart';

class AstParser {
  final AnalysisContextCollection _collection;

  AstParser(List<String> allPaths)
      : _collection = AnalysisContextCollection(
          includedPaths: allPaths,
        );

  Set<String> extractStrings(String filePath) {
    final context = _collection.contextFor(filePath);
    final session = context.currentSession;

    final result = session.getParsedUnit(filePath);

    if (result is! ParsedUnitResult) {
      return {};
    }

    final visitor = StringVisitor();
    result.unit.visitChildren(visitor);

    return visitor.texts;
  }
}
