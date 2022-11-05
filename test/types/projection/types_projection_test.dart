import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  test("Types test", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.build(start: () => g.fullGrammar().end());

    var parsed = parser.parse(File(
            "test/types/projection/types_projection_simple_case_schema.graphql")
        .readAsStringSync());
    expect(parsed.isSuccess, true);
    expect(g.types.length, greaterThanOrEqualTo(1));
    final db = g.getType("DataBase");
    final fragment = g.getFragment("DataBaseFragment");
    final projectedType = g.defineTypeWithFragment(db, fragment);
    expect(projectedType.fieldNames, isNot(contains("firstReleaseYear")));
  });

  test("Types test case 2", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.build(start: () => g.fullGrammar().end());

    var parsed = parser.parse(File(
            "test/types/projection/types_projection_simple_case_schema.graphql")
        .readAsStringSync());
    expect(parsed.isSuccess, true);

    final user = g.defineTypeWithFragment(
        g.getType("User"), g.getFragment("UserFragment"));
    expect(user.fieldNames, isNot(contains("lastName")));
  });
}
