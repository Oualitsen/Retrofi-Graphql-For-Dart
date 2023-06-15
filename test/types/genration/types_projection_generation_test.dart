import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/excpetions/parse_exception.dart';
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

  test("All Fields fragment generation", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.start());

    var parsed = parser.parse(File(
            "test/types/genration/types_all_fields_fragments_generation.graphql")
        .readAsStringSync());
    print("g.projectedTypes.length = ${g.projectedTypes.length}");
    expect(parsed.isSuccess, true);
    expect(g.allFieldsFragments.isEmpty, false);
    print("""
    _______________ projected types _________________
    ${g.allFieldsFragments.values.map((e) => e.fragment.serialize()).toList()}
    _________________________________________________

""");
  });

  test("test add all fields fragments to fragment depencies", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.start());

    var parsed = parser.parse(File(
            "test/types/genration/types_all_fields_fragments_dependecies.graphql")
        .readAsStringSync());
    expect(parsed.isSuccess, true);
    expect(
        g
            .getFragment("UserFields")
            .dependecies
            .map((e) => e.token)
            .contains("AddressFields"),
        true);
  });

  test("test projection validation", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.start());
    expect(
        () => parser.parse(
            File("test/types/genration/types_projection_validation.graphql")
                .readAsStringSync()),
        throwsA(isA<ParseException>()));
  });
}
