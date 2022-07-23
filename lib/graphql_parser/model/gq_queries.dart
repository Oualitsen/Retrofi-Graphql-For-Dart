import 'package:parser/graphql_parser/model/gq_directive.dart';
import 'package:parser/graphql_parser/model/gq_argument.dart';
import 'package:parser/graphql_parser/model/gq_fragment.dart';
import 'package:parser/graphql_parser/excpetions/parse_error.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';
import 'package:parser/graphql_parser/utils.dart';

enum GQQueryType { query, mutation, subscription }

class GQDefinition extends GQTokenWithDirectives {
  final List<GQDirectiveValue> list;
  final List<GQArgumentDefinition> arguments;
  final List<GQQueryElement> elements;
  final GQQueryType type;

  GQDefinition(String name, this.list, this.arguments, this.elements, this.type)
      : super(name) {
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
          throw ParseError("Argument ${arg.value} was not declared");
        }
      }
    }
  }

  bool checkValue(String value) {
    for (var arg in arguments) {
      if (arg.name == value) {
        return true;
      }
    }
    return false;
  }

  @override
  List<GQDirectiveValue> get directives => list;

  @override
  String serialize() {
    return """${type.name} $name ${serializeList(arguments)} ${serializeList(list)} {
        ${serializeList(elements, join: "\n\r", withParenthesis: false)}
      }
    """;
  }
}

class GQQueryElement extends GQTokenWithDirectives {
  final List<GQDirectiveValue> list;
  final GQFragmentBlock? block;
  final List<GQArgumentValue> arguments;

  GQQueryElement(String name, this.list, this.block, this.arguments)
      : super(name);

  @override
  List<GQDirectiveValue> get directives => list;

  @override
  String serialize() {
    return """$name ${serializeList(arguments, join: ", ")} ${serializeList(directives, join: " ")}
      ${block != null ? block!.serialize() : ''}""";
  }
}
