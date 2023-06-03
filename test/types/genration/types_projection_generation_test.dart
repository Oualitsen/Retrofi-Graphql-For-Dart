import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  test("Types test case 2", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.fullGrammar().end());

    var parsed = parser.parse(File(
            "test/types/genration/types_projection_generation_simple_case_schema.graphql")
        .readAsStringSync());
    print("g.projectedTypes.length = ${g.projectedTypes.length}");
    expect(parsed.isSuccess, true);
    print("""
    _______________ projected types _________________
    ${g.projectedTypes.values.map((e) => e.toDart(g))}
    _________________________________________________


    _____________________ types ______________________
      ${g.types.values.map((e) => e.toDart(g))}
    __________________________________________________

""");
  });
}
