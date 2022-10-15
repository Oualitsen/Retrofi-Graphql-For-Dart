import 'package:parser/graphql_parser/model/gq_directive.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';

abstract class GQToken {
  final String name;

  GQToken(this.name);

  String serialize();
}

abstract class GQTokenWithDirectives extends GQToken {
  GQTokenWithDirectives(String name) : super(name);

  List<GQDirectiveValue> get directives;
}

abstract class GQTokenWithFields extends GQToken {
  final List<GQField> fields;

  GQTokenWithFields(String name, this.fields) : super(name);

  bool hasField(String name) {
    return fields.map((e) => e.name).contains(name);
  }

  Set<String> get fieldNames => fields.map((e) => e.name).toSet();
}
