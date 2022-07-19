import 'package:parser/graphql_parser/model/token.dart';
import 'package:parser/graphql_parser/utils.dart';

class GQDefinition extends GQToken {
  final List<String> typeNames;
  GQDefinition(String name, this.typeNames) : super(name);

  @override
  String serialize() {
    return "union $name = ${serializeListText(typeNames, withParenthesis: false, join: " | ")}";
  }
}
