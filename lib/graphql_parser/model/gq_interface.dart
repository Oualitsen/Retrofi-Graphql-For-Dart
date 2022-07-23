import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:parser/graphql_parser/model/dart_serializable.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';

class GQInterfaceDefinition extends GQTokenWithFields
    implements DartSerializable {
  final Set<GQInterfaceDefinition> parents = <GQInterfaceDefinition>{};
  final Set<String> parenNames;

  GQInterfaceDefinition({
    required String name,
    required List<GQField> fields,
    required this.parenNames,
  }) : super(name, fields);

  @override
  String toString() {
    return 'GraphQLInterface{name: $name, fields: $fields, parenNames:$parenNames}';
  }

  @override
  String serialize() {
    throw UnimplementedError();
  }

  @override
  String toDart(GraphQlGrammar grammar) {
    final buffer = StringBuffer();

    buffer.write("abstract class $name");
    if (parents.isNotEmpty) {
      buffer.write(" extends ");

      for (var p in parents) {
        buffer.write(p.name);
        if (p != parents.last) {
          buffer.write(", ");
        }
      }
    }
    buffer.writeln("{");
    for (var element in fields) {
      buffer.writeln(element.toDart(grammar));
    }

    buffer.write("$name({");
    for (int i = 0; i < fields.length; i++) {
      final element = fields[i];
      buffer.write("required this.${element.name}, ");
    }
    buffer.writeln("});");

    buffer.writeln("}");

    return buffer.toString();
  }
}
