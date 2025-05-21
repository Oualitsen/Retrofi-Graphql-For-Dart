import 'dart:io';

import 'package:test/test.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  test("type_looks_like_test", () {
    final text = File("test/base_types_and_unions/base_types.graphql")
        .readAsStringSync();
    var g = GQGrammar(generateAllFieldsFragments: true);
    var parser = g.buildFrom(g.fullGrammar().end());
    var parsed = parser.parse(text);
    expect(parsed is Success, true);
    expect(g.projectedTypes.keys,
        containsAll(["Cat", "Dog_age_ownerName", "Animal"]));
  });
}
