import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/grammar.dart';
import 'package:parser/graphql_parser/model/gq_queries.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  test("Query  element", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(start: () => g.queryElement().end());
    var result = parser.parse(''' 
    adType(id: \$id) @test {
    ...adTypeFields
    }
     ''');
    // print("result.message = ${result.message}");
    expect(result.isSuccess, true);
  });

  test("Query  test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser =
        g.build(start: () => g.queryDefinition(GQQueryType.query).end());
    var result = parser.parse('''
      
      query AdType(\$id: String!) {
        adType(id: \$id) {
            ...adTypeFields
        }
    }
    
    ''');
    expect(result.isSuccess, true);
  });

  test("Query  test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser =
        g.build(start: () => g.queryDefinition(GQQueryType.mutation).end());
    var result = parser.parse('''
      
      mutation AdType(\$id: String!) {
        adType(id: \$id, name: "Ramdane") {
            ...adTypeFields
        }
      }
    
    ''');
    expect(result.isSuccess, true);
  });

  test("Query  test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser =
        g.build(start: () => g.queryDefinition(GQQueryType.query).end());
    var result = parser.parse('''
      
      query AdType(\$id: String!) {
        adType(id: \$id, name: "Ramdane") {
            ...adTypeFields
        }
      }
    
    ''');
    expect(result.isSuccess, true);
    print((result.value as GQDefinition).serialize());
  });

  test("Query  test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser =
        g.build(start: () => g.queryDefinition(GQQueryType.subscription).end());
    var result = parser.parse('''
      subscription AdType(\$id: String!) {
        adType(id: \$id, name: "Ramdane") {
            ...adTypeFields
        }
      }
    
    ''');
    expect(result.isSuccess, true);
    print((result.value as GQDefinition).serialize());
  });

  test("subscription test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser =
        g.build(start: () => g.queryDefinition(GQQueryType.subscription).end());
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
