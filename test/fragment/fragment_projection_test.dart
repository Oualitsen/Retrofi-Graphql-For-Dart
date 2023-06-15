import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/excpetions/parse_exception.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

final GraphQlGrammar g = GraphQlGrammar();

void main() async {
  test("fragment projection test", () {
    final text = File("test/fragment/fragment_projection_test.graphql")
        .readAsStringSync();

    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.fullGrammar().end());
    var parsed = parser.parse(text);

    expect(parsed.isSuccess, true);
  });

  test("fragment projection test", () {
    final text =
        File("test/fragment/fragment_projection_mismatch_fragment_type.graphql")
            .readAsStringSync();

    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.fullGrammar().end());
    expect(() => parser.parse(text), throwsA(isA<ParseException>()));
  });
}
