import 'package:parser/graphql_parser/model/gq_argument.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';

class GQDirectiveDefinition {
  final String name;
  final List<GQArgumentDefinition> arguments;

  GQDirectiveDefinition(this.name, this.arguments);
}

enum GQDirectiveLocation {
  QUERY,
  MUTATION,
  SUBSCRIPTION,
  FIELD,
  FRAGMENT_DEFINITION,
  FRAGMENT_SPREAD,
  INLINE_FRAGMENT,
  SCHEMA,
  SCALAR,
  OBJECT,
  FIELD_DEFINITION,
  ARGUMENT_DEFINITION,
  INTERFACE,
  UNION,
  ENUM,
  ENUM_VALUE,
  INPUT_OBJECT,
  INPUT_FIELD_DEFINITION,
  VARIABLE_DEFINITION
}

class GQDirectiveValue extends GQToken {
  final List<GQDirectiveLocation> locations;
  final List<GQArgumentValue> arguments;

  GQDirectiveValue(String name, this.locations, this.arguments) : super(name);

  @override
  String serialize() {
    return "$token ${arguments.isEmpty ? '' : (arguments.map((e) => e.serialize()).join(", "))}";
  }
}
