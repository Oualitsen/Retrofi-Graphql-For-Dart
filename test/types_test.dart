import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/grammar.dart';
import 'package:petitparser/petitparser.dart';

final GraphQlGrammar g = GraphQlGrammar();

void main() {
  test("identifier test", () {
    var parser = g.build(start: () => g.identifier().end());
    var result = parser.parse(''' test12 ''');
    expect(result.isSuccess, true);
    result = parser.parse(''' 1test ''');
    expect(result.isSuccess, false);
  });

  test("simple type test", () {
    var parser = g.build(start: () => g.simpleTypeToken().end());
    var result = parser.parse(''' test12 ''');
    expect(result.isSuccess, true);
    result = parser.parse(''' 1test ''');
    expect(result.isSuccess, false);

    result = parser.parse(''' test! ''');
    expect(result.isSuccess, true);
  });

  test("list type test", () {
    var parser = g.build(start: () => g.listType().end());
    var result = parser.parse(''' [test12] ''');
    expect(result.isSuccess, true);
    result = parser.parse(''' 1test ''');
    expect(result.isSuccess, false);

    result = parser.parse(''' [test]! ''');
    expect(result.isSuccess, true);

    result = parser.parse(''' [test!]! ''');
    expect(result.isSuccess, true);
  });

  test(" type test", () {
    var parser = g.build(start: () => g.typeToken().end());
    var result = parser.parse(''' [test12] ''');
    expect(result.isSuccess, true);
    result = parser.parse(''' 1test ''');
    expect(result.isSuccess, false);

    result = parser.parse(''' [test]! ''');
    expect(result.isSuccess, true);

    result = parser.parse(''' [test!]! ''');
    expect(result.isSuccess, true);

    result = parser.parse(''' test! ''');
    expect(result.isSuccess, true);

    result = parser.parse(''' test ''');
    expect(result.isSuccess, true);
  });
}
