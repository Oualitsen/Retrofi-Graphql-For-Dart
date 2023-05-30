import 'package:parser/graphql_parser/model/gq_directive.dart';
import 'package:parser/graphql_parser/model/gq_argument.dart';
import 'package:parser/graphql_parser/model/gq_fragment.dart';
import 'package:parser/graphql_parser/excpetions/parse_exception.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';
import 'package:parser/graphql_parser/utils.dart';

enum GQQueryType { query, mutation, subscription }

class GQDefinition extends GQToken {
  final List<GQDirectiveValue> directives;
  final List<GQArgumentDefinition> arguments;
  final List<GQQueryElement> elements;
  final GQQueryType type;

  GQDefinition(
      super.token, this.directives, this.arguments, this.elements, this.type) {
    checkVariables();
  }

  void checkVariables() {
    for (var elem in elements) {
      checkElement(elem);
    }
  }

  void checkElement(GQQueryElement element) {
    var list = element.arguments;

    for (var arg in list) {
      if ("${arg.value}".startsWith("\$")) {
        var check = checkValue("${arg.value}");
        if (!check) {
          throw ParseException("Argument ${arg.value} was not declared");
        }
      }
    }
  }

  bool checkValue(String value) {
    for (var arg in arguments) {
      if (arg.token == value) {
        return true;
      }
    }
    return false;
  }

  @override
  String serialize() {
    return """${type.name} $token ${serializeList(arguments)} ${serializeList(directives)} {
        ${serializeList(elements, join: "\n\r", withParenthesis: false)}
      }
    """;
  }
}

class GQQueryElement extends GQToken {
  final List<GQDirectiveValue> list;
  final GQFragmentBlockDefinition? block;
  final List<GQArgumentValue> arguments;

  GQQueryElement(super.token, this.list, this.block, this.arguments);

  List<GQDirectiveValue> get directives => list;

  @override
  String serialize() {
    return """$token ${serializeList(arguments, join: ", ")} ${serializeList(directives, join: " ")}
      ${block != null ? block!.serialize() : ''}""";
  }
}
