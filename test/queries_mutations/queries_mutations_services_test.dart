import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/excpetions/parse_exception.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() async {
  test("querries and mutations generation test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.fullGrammar().end());

    final text = File("test/queries_mutations/simple_queries_test.graphql")
        .readAsStringSync();
    var parsed = parser.parse(text);
    expect(parsed.isSuccess, true);
    expect(g.inputs.length, greaterThanOrEqualTo(1));
    expect(g.types.length, greaterThanOrEqualTo(1));
    expect(g.queries.length, greaterThanOrEqualTo(1));
    expect(g.mutations.length, greaterThanOrEqualTo(1));
  });

  test("fail when projected field is not found in query projections", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.fullGrammar().end());

    final text =
        File("test/queries_mutations/fail_on_bad_query_projection.graphql")
            .readAsStringSync();

    expect(() => parser.parse(text), throwsA(isA<ParseException>()));
  });

  test("fail_on_query_projection_over_simple_type", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.fullGrammar().end());

    final text = File(
            "test/queries_mutations/fail_on_query_projection_over_simple_type.graphql")
        .readAsStringSync();

    expect(() => parser.parse(text), throwsA(isA<ParseException>()));
  });

  test("fail_on_absence_of_query_projection_over_type", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.fullGrammar().end());

    final text = File(
            "test/queries_mutations/fail_on_absence_of_query_projection_over_type.graphql")
        .readAsStringSync();

    expect(() => parser.parse(text), throwsA(isA<ParseException>()));
  });
}
