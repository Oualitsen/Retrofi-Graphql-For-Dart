import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:parser/graphql_parser/model/dart_serializable.dart';
import 'package:parser/graphql_parser/model/gq_directive.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';
import 'package:parser/graphql_parser/utils.dart';

class GQInputDefinition extends GQTokenWithFields implements DartSerializable {
  GQInputDefinition({required String name, required List<GQField> fields})
      : super(name, fields);

  @override
  String toString() {
    return 'InputType{fields: $fields, name: $token}';
  }

  @override
  String serialize() {
    return """
      input $token {
      
      }
    """;
  }

  @override
  String toDart(GraphQlGrammar grammar) {
    final buffer = StringBuffer();
    buffer.writeln("@JsonSerializable()");
    buffer.writeln("class $token {");
    // declare fields

    for (var element in fields) {
      buffer.writeln(element.toDart(grammar));
    }

    // declare the constuctor

    buffer.write("$token({");
    for (int i = 0; i < fields.length; i++) {
      final element = fields[i];
      buffer.write("required this.${element.name}, ");
    }
    buffer.writeln("});");

    buffer.writeln(
        "factory $token.fromJson(Map<String, dynamic> json) => _\$${token}FromJson(json);");
    buffer.writeln("Map<String, dynamic> toJson() => _\$${token}ToJson(this);");

    buffer.writeln("}");

    return buffer.toString();
  }
}

class GQTypeDefinition extends GQTokenWithFields implements DartSerializable {
  final Set<String> interfaceNames;
  final List<GQDirectiveValue> directives;

  GQTypeDefinition({
    required String name,
    required List<GQField> fields,
    required this.interfaceNames,
    required this.directives,
  }) : super(name, fields);

  @override
  String toString() {
    return 'GraphqlType{name: $token, fields: $fields, interfaceNames: $interfaceNames}';
  }

  @override
  String toDart(GraphQlGrammar grammar) {
    return """
      
      class $token ${interfaceNames.isEmpty ? '' : 'extends '} ${interfaceNames.join(" ")} {
          ${serializeListText(fields.map((e) => e.toDart(grammar)).toList(), join: "\n\r", withParenthesis: false)}
      }
      
    """;
  }

  @override
  String serialize() {
    throw UnimplementedError();
  }

  GQTypeDefinition clone(String newName) {
    return GQTypeDefinition(
      name: newName,
      fields: fields.toList(),
      interfaceNames: interfaceNames,
      directives: [],
    );
  }
}
