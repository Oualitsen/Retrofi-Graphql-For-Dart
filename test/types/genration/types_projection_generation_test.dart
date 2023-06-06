import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';

void main() {
  test("generate projection", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.start());

    var parsed = parser.parse(File(
            "test/types/genration/types_projection_generation_simple_case_schema.graphql")
        .readAsStringSync());
    print("g.projectedTypes.length = ${g.projectedTypes.length}");
    expect(parsed.isSuccess, true);
    print("""
    _______________ projected types _________________
    ${g.projectedTypes.values.map((e) => e.toDart(g)).toList()}
    _________________________________________________

    _______________ inputs types _________________
    ${g.inputs.values.map((e) => e.toDart(g)).toList()}
    _________________________________________________


""");
  });

  test("projection fragment reference", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.start());

    var parsed = parser.parse(File(
            "test/types/genration/types_projection_generation_frag_ref.graphql")
        .readAsStringSync());
    print("g.projectedTypes.length = ${g.projectedTypes.length}");
    expect(parsed.isSuccess, true);
    print("""
    _______________ projected types _________________
    ${g.projectedTypes.values.map((e) => e.toDart(g)).toList()}
    _________________________________________________

""");
  });
}
