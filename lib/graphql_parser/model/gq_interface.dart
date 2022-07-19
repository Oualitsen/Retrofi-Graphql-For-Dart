import 'package:parser/graphql_parser/model/dart_serializable.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';
import 'package:parser/graphql_parser/model/token.dart';

class GQInterfaceDefinition extends GQToken implements DartSerializable {
  final List<GQField> fields;
  final List<GQInterfaceDefinition> parents = [];
  final List<String> parenNames;

  GQInterfaceDefinition({
    required String name,
    required this.fields,
    required this.parenNames,
  }) : super(name);

  @override
  String toString() {
    return 'GraphQLInterface{name: $name, fields: $fields, parenNames:$parenNames}';
  }

  @override
  String serialize() {
    throw UnimplementedError();
  }

  @override
  String toDart() {
    /**
     * @TODO create an abstract class here
     */
    throw UnimplementedError();
  }
}
