import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';

abstract class DartSerializable {
  String toDart(GraphQlGrammar grammar);
}
