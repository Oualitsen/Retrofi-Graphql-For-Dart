import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:parser/graphql_parser/model/dart_serializable.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';
import 'package:parser/graphql_parser/utils.dart';

class GQInputDefinition extends GQTokenWithFields implements DartSerializable {
  GQInputDefinition({required String name, required List<GQField> fields})
      : super(name, fields);

  @override
  String toString() {
    return 'InputType{fields: $fields, name: $name}';
  }

  @override
  String serialize() {
    return """
      input $name {
      
      }
    """;
  }

  @override
  String toDart(GraphQlGrammar grammar) {
    final buffer = StringBuffer();
    buffer.writeln("@JsonSerializable()");
    buffer.writeln("class $name {");
    // declare fields

    for (var element in fields) {
      buffer.writeln(element.toDart(grammar));
    }

    // declare the constuctor

    buffer.write("$name({");
    for (int i = 0; i < fields.length; i++) {
      final element = fields[i];
      buffer.write("required this.${element.name}, ");
    }
    buffer.writeln("});");

    buffer.writeln(
        "factory $name.fromJson(Map<String, dynamic> json) => _\$${name}FromJson(json);");
    buffer.writeln("Map<String, dynamic> toJson() => _\$${name}ToJson(this);");

    buffer.writeln("}");

    return buffer.toString();
  }
}

class GQTypeDefinition extends GQTokenWithFields implements DartSerializable {
  final Set<String> interfaceNames;

  GQTypeDefinition({
    required String name,
    required List<GQField> fields,
    required this.interfaceNames,
  }) : super(name, fields);

  @override
  String toString() {
    return 'GraphqlType{name: $name, fields: $fields, interfaceNames: $interfaceNames}';
  }

  @override
  String toDart(GraphQlGrammar grammar) {
    return """
      
      class $name ${interfaceNames.isEmpty ? '' : 'extends '} ${interfaceNames.join(" ")} {
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
    );
  }
}
