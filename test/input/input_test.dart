import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() async {
  test("Input transformation", () {
    final GraphQlGrammar g = GraphQlGrammar();
    print("________________________________________init______________________");

    var parser = g.buildFrom(g.fullGrammar().end());
    print("reading file");

    final text = File("test/input/input_schema.graphql").readAsStringSync();
    print("file read $test");
    var parsed = parser.parse(text);
    expect(parsed.isSuccess, true);
    expect(g.inputs.length, greaterThanOrEqualTo(1));
  });
}
