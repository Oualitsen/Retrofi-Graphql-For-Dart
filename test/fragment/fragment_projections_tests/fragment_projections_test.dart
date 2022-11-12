import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

final GraphQlGrammar g = GraphQlGrammar();

void main() async {
  group("projected types test", () {
    const folderPath = "test/fragment/fragment_projections_tests";

    test("Simple projection", () {
      final _text = File("$folderPath/simple_projection_schema.graphql")
          .readAsStringSync();

      final GraphQlGrammar g = GraphQlGrammar();
      final parser = g.build(start: () => g.fullGrammar().end());
      final parsed = parser.parse(_text);

      expect(parsed.isSuccess, true);
      var type = g.getType("Person_PersonFragment");
      expect(type.fieldNames,
          containsAll(["firstName", "lastName", "middleName"]));
      expect(type.fieldNames, isNot(containsAll(["age"])));
    });

    test("Block test", () {
      final _text = File("$folderPath/block_schema.graphql").readAsStringSync();

      final GraphQlGrammar g = GraphQlGrammar();
      final parser = g.build(start: () => g.fullGrammar().end());
      final parsed = parser.parse(_text);
      expect(parsed.isSuccess, true);

      g.types.forEach((key, value) {
        //print("######## key = $key ===> ${value.toDart(g)}");
      });
    });

    test("Fragment reference", () {
      final _text = File("$folderPath/fragment_reference_schema.graphql")
          .readAsStringSync();

      final GraphQlGrammar g = GraphQlGrammar();
      final parser = g.build(start: () => g.fullGrammar().end());
      final parsed = parser.parse(_text);
      expect(parsed.isSuccess, true);

      g.types.forEach((key, value) {
        print("######## key = $key ===> ${value.toDart(g)}");
      });
    });
  });
  group("Fragment tests", () {
    test("Fragments test", () async {
      final text = File("test/fragment/fragments.graphql").readAsStringSync();
      final GraphQlGrammar g = GraphQlGrammar();
      var parser = g.build(start: () => g.fullGrammar().end());

      var parsed = parser.parse(text);

      expect(parsed.isSuccess, true);
      expect(g.fragments.length, greaterThanOrEqualTo(4));
      g.fragments.forEach((key, value) {
        print(value);
      });
    });

    test("Fragemnt Dependecies Test", () {
      final GraphQlGrammar g = GraphQlGrammar();
      var parser = g.build(start: () => g.fullGrammar().end());

      var parsed = parser.parse(
          File("test/fragment/fragment_dependecy.graphql").readAsStringSync());
      expect(parsed.isSuccess, true);

      final frag = g.fragments["AddressFragment"]!;
      expect(
          frag.dependecies.map((e) => e.name), containsAll(["StateFragment"]));
      expect(g.fragments.length, greaterThanOrEqualTo(2));
    });
  });
}
