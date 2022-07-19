import 'package:parser/graphql_parser/model/gq_directive.dart';
import 'package:parser/graphql_parser/model/token.dart';

class GQEnumDefinition extends GQTokenWithDirectives {
  List<GQEnumValue> values;
  List<GQDirective> list;

  GQEnumDefinition(
      {required String name, required this.values, required this.list})
      : super(name);

  @override
  String serialize() {
    throw UnimplementedError();
  }

  @override
  List<GQDirective> get directives => list;
}

class GQEnumValue {
  final String value;
  final String? comment;

  GQEnumValue({required this.value, required this.comment});
}
