import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  test("Object value test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.scalarDefinition().end());
    var result = parser.parse("""
      scalar Date 
    """);
    expect(result.isSuccess, true);
    expect(result.value, "Date");
  });

  test("Object value test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.scalarDefinition().end());
    var result = parser.parse("""
      scalar Date @skip(if: true) @skip2(ifNot: 12
      )
    """);
    expect(result.isSuccess, true);
    expect(result.value, "Date");
  });
}
