import 'package:parser/graphql_parser/model/dart_serializable.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';
import 'package:parser/graphql_parser/model/token.dart';
import 'package:parser/graphql_parser/utils.dart';

class GQInputDefinition extends GQToken implements DartSerializable {
  final List<GQField> fields;

  GQInputDefinition({required String name, required this.fields}) : super(name);

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
  String toDart() {
    return """
      input $name {
      
      }
    """;
  }
}

class GQTypeDefinition extends GQToken implements DartSerializable {
  final List<GQField> fields;
  final List<String> interfaceNames;

  GQTypeDefinition({
    required String name,
    required this.fields,
    required this.interfaceNames,
  }) : super(name);

  @override
  String toString() {
    return 'GraphqlType{name: $name, fields: $fields, interfaceNames: $interfaceNames}';
  }

  @override
  String toDart() {
    return """
      
      class $name ${interfaceNames.isEmpty ? '' : 'extends '} ${interfaceNames.join(" ")} {
          ${serializeListText(fields.map((e) => e.toDart()).toList(), join: "\r", withParenthesis: false)}
      }
      
    """;
  }

  @override
  String serialize() {
    throw UnimplementedError();
  }
}
