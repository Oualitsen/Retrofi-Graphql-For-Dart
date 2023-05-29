import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() async {
  test("Types test", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.fullGrammar().end());

    var parsed = parser
        .parse(File("test/types/types_schema.graphql").readAsStringSync());
    expect(parsed.isSuccess, true);
    expect(g.types.length, greaterThanOrEqualTo(2));
    final db = g.types["DataBase"]!;
    expect(db.fieldNames, containsAll(["firstReleaseYear", "name", "noSQL"]));
    g.types.forEach((key, value) {
      print("${value.toDart(g)}");
    });
  });

  test("Fragment Projected types (Simple Types)", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.fullGrammar().end());

    var parsed = parser.parse(
        File("test/types/types_with_fragment_schema.graphql")
            .readAsStringSync());
    expect(parsed.isSuccess, true);

    final type = g.getType("DataBase");
    final fragment = g.getFragment("DataBaseFragment");
    final fragmentedType = g.defineTypeWithFragment(type, fragment);
    expect(fragmentedType.fields.map((e) => e.name),
        isNot(containsAll(["firstReleaseYear"])));
  });

  test("Fragment Projected types (With Alias)", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.fullGrammar().end());

    var parsed = parser.parse(
        File("test/types/types_with_fragment_schema_alias.graphql")
            .readAsStringSync());
    expect(parsed.isSuccess, true);
    final type = g.getType("DataBase");
    final fragment = g.getFragment("DataBaseFragment");
    final fragmentedType = g.defineTypeWithFragment(type, fragment);
    expect(fragmentedType.fields.map((e) => e.name),
        isNot(containsAll(["firstReleaseYear"])));
  });
}
