import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/grammar.dart';
import 'package:petitparser/petitparser.dart';

final GraphQlGrammar g = GraphQlGrammar();

void main() {
  test("Implements fields", () {
    var parser = g.build(start: () => g.implementsToken().end());
    var result = parser.parse('''
      implements UserBase & BasicEntity
    ''');
    expect(result.isSuccess, true);
  });

  test("Interface  test", () {
    var parser = g.build(start: () => g.interfaceDefinition().end());
    var result = parser.parse('''
      interface Test implements BasicEntity & UserBase & UserBase2 @skip(if: true) {
        test: boolean! 
        test: boolean! 
        test: boolean! 
        test: boolean! 
      }
    ''');
    expect(result.isSuccess, true);
  });
}
