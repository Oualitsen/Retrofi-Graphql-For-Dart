import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/debug.dart';

void main() {
  test("Fragment value test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.fragmentBlock().end());
    var result = parser.parse('''
        {
          ...name ... dob ... on merde
         }
    ''');
    print("parser value = '${result.value}'");
    expect(result.isSuccess, true);
  });

  test("Plain fragment field test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.fragmentBlock().end());
    var result = trace(parser).parse('''
        {
          name 
         }
    ''');
    print("parser value = '${result.value}'");
    expect(result.isSuccess, true);
  });
}
