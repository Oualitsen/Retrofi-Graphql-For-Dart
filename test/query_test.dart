import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:parser/graphql_parser/model/gq_queries.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  test("Query  element", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.queryElement().end());
    var result = parser.parse(''' 
    adType(id: \$id) @test {
    ...adTypeFields
    }
     ''');
    // print("result.message = ${result.message}");
    expect(result.isSuccess, true);
  });

  test("Query definition test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.queryDefinition(GQQueryType.query).end());
    var result = parser.parse('''
      
      query AdType(\$id: String!) {
        adType(id: \$id) {
            ...adTypeFields
        }
    }
    
    ''');
    expect(result.isSuccess, true);
  });

  test("Query definition test 2", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.queryDefinition(GQQueryType.mutation).end());
    var result = parser.parse('''
      
      mutation AdType(\$id: String!) {
        adType(id: \$id, name: "Ramdane") {
            ...adTypeFields
        }
      }
    
    ''');
    expect(result.isSuccess, true);
  });

  test("Query definition test 3", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.queryDefinition(GQQueryType.query).end());
    var result = parser.parse('''
      
      query AdType(\$id: String!) {
        adType(id: \$id, name: "Ramdane") {
            ...adTypeFields
        }
      }
    
    ''');
    expect(result.isSuccess, true);
    print((result.value).serialize());
  });

  test("Query definition test 4", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.queryDefinition(GQQueryType.subscription).end());
    var result = parser.parse('''
      subscription AdType(\$id: String!) {
        adType(id: \$id, name: "Ramdane") {
            ...adTypeFields
        }
      }
    
    ''');
    expect(result.isSuccess, true);
    print((result.value).serialize());
  });

  test("subscription test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.buildFrom(g.queryDefinition(GQQueryType.subscription).end());
    var result = parser.parse('''
      subscription AdType(\$id: String!) {
        adType(id: \$id, name: "Ramdane") {
            ...adTypeFields
        }
         adType(id: \$id, name: "Ramdane") {
            ...adTypeFields
        }
      }
    
    ''');
    expect(result.isSuccess, false);
  });
}
