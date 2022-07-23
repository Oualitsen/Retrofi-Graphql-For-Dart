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
  final Set<String> fieldNames = {};

  GQTokenWithFields(String name, this.fields) : super(name) {
    fieldNames.addAll(fields.map((e) => e.name));
  }

  bool hasField(String name) {
    return fieldNames.contains(name);
  }
}
