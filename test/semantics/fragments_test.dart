import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

final GraphQlGrammar g = GraphQlGrammar();

void main() async {
  test("Fragments test", () async {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.build(start: () => g.fullGrammar().end());
    var file = File("test/semantics/fragments.graphql");

    var text = file.readAsStringSync();
    var parsed = parser.parse(text);

    expect(parsed.isSuccess, true);

    g.fragments.forEach((key, value) {
      print(value);
    });
    g.updateFragmentDependencies();
  });
}
