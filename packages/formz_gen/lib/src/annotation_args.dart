import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

class AnnotationArgs {
  const AnnotationArgs({required this.positional, required this.named});

  factory AnnotationArgs.parse(String annotationSource) {
    final expression = annotationSource.substring(1);
    final unit = parseString(content: 'const _ = $expression;').unit;
    final declaration = unit.declarations.single as TopLevelVariableDeclaration;
    final initializer = declaration.variables.variables.single.initializer;
    final arguments = initializer == null
        ? const <Argument>[]
        : initializer.childEntities
              .whereType<ArgumentList>()
              .expand((list) => list.arguments)
              .toList();
    return AnnotationArgs(
      positional: [
        for (final a in arguments)
          if (a is! NamedArgument) a.toSource(),
      ],
      named: {
        for (final a in arguments.whereType<NamedArgument>())
          a.name.lexeme: a.argumentExpression.toSource(),
      },
    );
  }

  final List<String> positional;
  final Map<String, String> named;
}
