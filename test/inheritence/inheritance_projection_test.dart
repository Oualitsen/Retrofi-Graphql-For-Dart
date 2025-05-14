import 'dart:io';

import 'package:test/test.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() async {
  test("inheritence test", () {
    final GQGrammar g = GQGrammar();

    var parser = g.buildFrom(g.fullGrammar().end());

    final text = File("test/inheritence/inheritance_projection_test.graphql").readAsStringSync();
    parser.parse(text);

    //expect(result is Success, true);
    //print("g ==> ${g.generateClient()}");
  });
}

enum Gender { male, femal }
