import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

final GraphQlGrammar g = GraphQlGrammar();

void main() {
  test("Type test", () {
    var parser = g.build(start: () => g.typeDefinition().end());
    var result = parser.parse('''
      type Test2 implements Test {
        name: String!
        test: Boolean
        next: Test2
      }
    ''');
    expect(result.isSuccess, true);

    result = parser.parse('''
      type Test2  {
        name: String!
        test: Boolean
        next: Test2
      }
    ''');
    expect(result.isSuccess, true);

    result = parser.parse('''
      type Test2 @test(if: true) {
        name: String!
        test(test: Int!): [Boolean!]!
        next: [Test2!]
      }
    ''');
    expect(result.isSuccess, true);
  });

  test("Type test with arguments", () {
    var parser = g.build(start: () => g.typeDefinition().end());
    var result = parser.parse('''
      type Test2 implements Test {
        name(test: String!): String!
        test: Boolean
        next: Test2
      }
    ''');
    expect(result.isSuccess, true);
  });
}
