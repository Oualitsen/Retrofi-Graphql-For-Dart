import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

final GraphQlGrammar g = GraphQlGrammar();

void main() {
  test("Directive value  test", () {
    var parser = g.build(start: () => g.directiveValue().end());
    var result = parser.parse('''
      @skip(if: true)
    ''');
    expect(result.isSuccess, true);

    result = parser.parse('''
      @skip(if: [1 2, {name:"ramdane", age: 33}])
    ''');
    expect(result.isSuccess, true);

    result = parser.parse('''@azul''');
    expect(result.isSuccess, true);
  });

  test("Directive scopes test", () {
    var parser = g.build(start: () => g.directiveScopes().end());
    var result = parser.parse('''
    SCALAR|OBJECT|INTERFACE | ARGUMENT_DEFINITION
    ''');
    expect(result.isSuccess, true);
  });

  test("Directive definition test", () {
    var parser = g.build(start: () => g.directiveDefinition().end());
    var result = parser.parse('''
    directive @test(test: String! = "Azul fellawen") on INTERFACE | ARGUMENT_DEFINITION
    ''');
    expect(result.isSuccess, true);
  });
}
