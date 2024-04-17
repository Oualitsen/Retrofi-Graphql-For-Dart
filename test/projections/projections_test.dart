import 'dart:io';

import 'package:test/test.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() async {
  test("projections_test", () {
    final GQGrammar g = GQGrammar(generateAllFieldsFragments: true);

    var parser = g.buildFrom(g.fullGrammar().end());

    final text = File("test/projections/projections_test.graphql").readAsStringSync();
    var parsed = parser.parse(text);
    expect(parsed.isSuccess, true);
    var user = g.projectedTypes["User"];
    var address = g.projectedTypes["Address"];
    var state = g.projectedTypes["State"];

    //should generate User and Address instead of User_*_* and Address_all_types_fragmentAddress
    expect(user != null, true);
    expect(address != null, true);
    expect(state != null, true);
  });
}
