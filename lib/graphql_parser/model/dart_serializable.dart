import 'package:parser/graphql_parser/gq_grammar.dart';

abstract class DartSerializable {
  String toDart(GraphQlGrammar grammar);
}
