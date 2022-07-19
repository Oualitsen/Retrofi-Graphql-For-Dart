import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/grammar.dart';
import 'package:parser/graphql_parser/model/gq_union.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  test("Union serialization", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var union = GQDefinition("type", ["User"]);
    expect(union.serialize(), "union type = User");
  });

  test("Union serialization with multiple types", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var union = GQDefinition("type", ["User", "Client"]);
    expect(union.serialize(), "union type = User | Client");
  });

  test("Parse union", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build<GQDefinition>(start: () => g.parseUnion().end());
    var result = parser.parse('''
    union type = User | Client
    ''');
    expect(result.isSuccess, true);
    expect(result.value.name, "type");
    expect(result.value.typeNames.length, 2);
  });

  test("Parse union", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build<GQDefinition>(start: () => g.parseUnion().end());
    var result = parser.parse('''
    union type = User
    ''');
    expect(result.isSuccess, true);
    expect(result.value.name, "type");
    expect(result.value.typeNames.length, 1);
  });
}
