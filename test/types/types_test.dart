import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() async {
  test("Types test", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.buildFrom(g.fullGrammar().end());

    var parsed = parser
        .parse(File("test/types/types_schema.graphql").readAsStringSync());
    expect(parsed.isSuccess, true);
    expect(g.types.length, greaterThanOrEqualTo(2));
    final db = g.types["DataBase"]!;
    expect(db.fieldNames, containsAll(["firstReleaseYear", "name", "noSQL"]));
    g.types.forEach((key, value) {
      print("${value.toDart(g)}");
    });
  });
}
