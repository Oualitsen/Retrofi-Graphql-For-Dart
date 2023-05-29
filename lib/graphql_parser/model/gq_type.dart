import 'package:parser/graphql_parser/model/gq_token.dart';

class GQType extends GQToken {
  final bool nullable;

  ///
  ///used to check if the type is a scalar or an object
  ///This is mainly used for fragments and queries
  ///
  bool isScalar;

  GQType(super.name, this.nullable, {this.isScalar = true});

  @override
  String toString() {
    return '';
  }

  String toDartType(Map<String, String> typeMapping) {
    var dartTpe = typeMapping[token] ?? token;
    return "$dartTpe$nullableTextDart";
  }

  @override
  String serialize() {
    return "$token$nullableText";
  }

  String get nullableText => nullable ? "" : "!";
  String get nullableTextDart => nullable ? "?" : "";
}

class GQListType extends GQType {
  final GQType type;
  GQListType(this.type, bool nullable) : super("", nullable);

  @override
  String serialize() {
    return "[${type.serialize()}]$nullableText";
  }

  @override
  String toDartType(Map<String, String> typeMapping) {
    return "List<${type.toDartType(typeMapping)}>$nullableTextDart";
  }
}
