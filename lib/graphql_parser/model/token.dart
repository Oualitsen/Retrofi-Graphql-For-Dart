import 'package:parser/graphql_parser/model/gq_directive.dart';

abstract class GQToken {
  final String name;

  GQToken(this.name);

  String serialize();
}

abstract class GQTokenWithDirectives extends GQToken {
  GQTokenWithDirectives(String name) : super(name);

  List<GQDirective> get directives;
}
