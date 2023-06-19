import 'package:parser/graphql_parser/model/gq_type.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';

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
    return 'Argument{name: $token, type: $type}';
  }

  String get dartArgumentName => token.substring(1);

  @override
  String serialize() {
    var r = "$token: ${type.serialize()}";
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
  //this is not know at parse type, it must be set only once the grammer parsing is done.
  late final GQType type;
  GQArgumentValue(String name, this.value) : super(name);

  @override
  String serialize() {
    return "$token: $value";
  }

  @override
  String toString() {
    return 'GraphqlArgumentValue{value: $value name: $token}';
  }
}
