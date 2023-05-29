import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() async {
  test("inline reference", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.fullGrammar().end());

    final text =
        File("test/fragment/inline_reference/inline_reference_test.graphql")
            .readAsStringSync();

    var parsed = parser.parse(text);
    expect(parsed.isSuccess, true);
  });
}
