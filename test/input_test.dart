import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  test("Input  test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.inputDefinition().end());
    var result = parser.parse('''
      input Test {
        "Sample documentation"
        test: boolean! = true
        """
        Block Documentation
        """
        test2: Int
      }
    ''');
    expect(result.isSuccess, true);

    // print((result.value as GraphqlTypeDefinition).toDart());

    result = parser.parse('''
      input Test2 @skip(if: true){
        test: boolean! = true @test(if: true) @test(if: true)
        object: User! = {
          firstName: "Oualitsen"
          lastName: "Ramdane"
        }
      }
    ''');
    expect(result.isSuccess, true);
  });

  test("Field test with init", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(
        start: () =>
            g.field(canBeInitialized: true, acceptsArguments: false).end());
    var result = parser.parse('''
      fieldName: String! = "Azul fellawen" @skip(if: true)
    ''') as Result<GQField>;
    expect(result.isSuccess, true);
    expect(result.value.type.nullable, false);
    print("result.value = ${result.value}");
  });

  test("Field test without init", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(
        start: () =>
            g.field(canBeInitialized: false, acceptsArguments: false).end());
    var result = parser.parse('''
      fieldName: String! = "Azul fellawen" @skip(if: true)
    ''');

    result = parser.parse('''
      fieldName: String!  @skip(if: true)
    ''');
    expect(result.isSuccess, true);
  });
}
