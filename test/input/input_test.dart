import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() async {
  test("Input transformation", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.build(start: () => g.fullGrammar().end());

    final text = File("test/input/input_schema.graphql").readAsStringSync();

    var parsed = parser.parse(text);
    expect(parsed.isSuccess, true);
    expect(g.inputs.length, greaterThanOrEqualTo(1));

    g.inputs.forEach((key, value) {
      print("${value.toDart(g)}");
    });
  });
}
