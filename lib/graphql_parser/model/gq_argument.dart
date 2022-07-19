import 'package:parser/graphql_parser/model/gq_type.dart';
import 'package:parser/graphql_parser/model/token.dart';

///
///  some thing like function(if: Boolean = true, name: String! = "Ahmed" ...)
///

class GQArgumentDefinition extends GQToken {
  final GQType type;
  final Object? initialValue;
  GQArgumentDefinition(String name, this.type, {this.initialValue})
      : super(name);

  @override
  String toString() {
    return 'Argument{name: $name, type: $type}';
  }

  @override
  String serialize() {
    var r = "$name: ${type.serialize()}";
    if (initialValue != null) {
      r += " = $initialValue";
    }
    return r;
  }
}

///
///  some thing like function(if: true, name: "Ahmed" ...)
///

class GQArgumentValue extends GQToken {
  Object? value;

  GQArgumentValue(String name, this.value) : super(name);

  @override
  String serialize() {
    return "$name: $value";
  }

  @override
  String toString() {
    return 'GraphqlArgumentValue{value: $value name: $name}';
  }
}
