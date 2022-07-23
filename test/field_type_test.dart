import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:parser/graphql_parser/model/gq_type.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  test("non nullable type test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(start: () => g.typeTokenDefinition().end());
    var result = parser.parse('''
      String!
    ''') as Result<GQType>;
    expect(result.isSuccess, true);
    expect(result.value.nullable, false);
    expect(result.value.toDartType({}), "String");
  });

  test("nullable type test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(start: () => g.simpleTypeTokenDefinition().end());
    var result = parser.parse('''
      String
    ''') as Result<GQType>;
    expect(result.isSuccess, true);
    expect(result.value.nullable, true);
    expect(result.value.toDartType({}), "String?");
  });
}
