import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:parser/graphql_parser/model/gq_argument.dart';
import 'package:parser/graphql_parser/model/dart_serializable.dart';
import 'package:parser/graphql_parser/model/gq_type.dart';

class GQField extends DartSerializable {
  final String name;
  final GQType type;
  final Object? initialValue;
  final String? documentation;
  final List<GQArgumentDefinition> arguments;

  GQField({
    required this.name,
    required this.type,
    required this.arguments,
    this.initialValue,
    this.documentation,
  });

  @override
  String toString() {
    return 'GraphqlField{name: $name, type: $type, initialValue: $initialValue, documentation: $documentation, arguments: $arguments}';
  }

  @override
  String toDart(GraphQlGrammar g) {
    return "final ${type.toDartType(g.typeMap)} $name;";
  }
}
