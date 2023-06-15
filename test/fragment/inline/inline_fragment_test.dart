import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() async {
  const folderPath = "test/fragment/inline";
  test("Simple projection", () {
    final GraphQlGrammar g = GraphQlGrammar();

    final text =
        File("$folderPath/inline_fragment_test.graphql").readAsStringSync();

    final parser = g.buildFrom(g.fullGrammar().end());
    final parsed = parser.parse(text);

    expect(parsed.isSuccess, true);
  });
}
