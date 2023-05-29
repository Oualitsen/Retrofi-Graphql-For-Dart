import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:parser/graphql_parser/model/dart_serializable.dart';
import 'package:parser/graphql_parser/model/gq_directive.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';

class GQInterfaceDefinition extends GQTokenWithFields
    implements DartSerializable {
  final Set<GQInterfaceDefinition> parents = <GQInterfaceDefinition>{};
  final Set<String> parentNames;
  final Set<GQDirectiveValue> directives;

  GQInterfaceDefinition({
    required String name,
    required List<GQField> fields,
    required this.parentNames,
    required this.directives,
  }) : super(name, fields);

  @override
  String toString() {
    return 'GraphQLInterface{name: $token, fields: $fields, parenNames:$parentNames}';
  }

  @override
  String serialize() {
    throw UnimplementedError();
  }

  @override
  String toDart(GraphQlGrammar grammar) {
    final buffer = StringBuffer();

    buffer.write("abstract class $token");
    if (parents.isNotEmpty) {
      buffer.write(" extends ");

      for (var p in parents) {
        buffer.write(p.token);
        if (p != parents.last) {
          buffer.write(", ");
        }
      }
    }
    buffer.writeln("{");
    for (var element in fields) {
      buffer.writeln(element.toDart(grammar));
    }

    buffer.write("$token({");
    for (int i = 0; i < fields.length; i++) {
      final element = fields[i];
      buffer.write("required this.${element.name}, ");
    }
    buffer.writeln("});");

    buffer.writeln("}");

    return buffer.toString();
  }
}
