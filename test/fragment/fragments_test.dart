import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

final GraphQlGrammar g = GraphQlGrammar();

void main() async {
  late final text;

  setUp(() {
    text = File("test/fragment/fragments.graphql").readAsStringSync();
  });
  group("Fragment tests", () {
    test("Fragments test", () async {
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
