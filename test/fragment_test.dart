import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/model/gq_fragments.dart';
import 'package:parser/graphql_parser/grammar.dart';
import 'package:petitparser/petitparser.dart';

final GraphQlGrammar g = GraphQlGrammar();

void main() {
  test("Fragment field test", () {
    var parser = g.build(start: () => g.plainFragmentField().end());
    var result = parser.parse('''
      
      name
    
    ''');
    expect(result.isSuccess, true);
    var value = result.value as GQFragmentField;
    expect(value.name, "name");
    expect(value.alias, null);
  });

  test("Fragment field with alias test", () {
    var parser = g.build(start: () => g.plainFragmentField().end());
    var result = parser.parse('''
      
      alias: name
    
    ''');
    expect(result.isSuccess, true);
    var value = result.value as GQFragmentField;
    expect(value.name, "name");
    expect(value.alias, "alias");
  });

  test("Fragment field with alias test", () {
    var parser = g.build(start: () => g.plainFragmentField().end());
    var result = parser.parse('''
      
      alias: name {
        id lastUpdate
      }
    
    ''');
    expect(result.isSuccess, true);
    var value = result.value as GQFragmentField;
    expect(value.name, "name");
    expect(value.alias, "alias");
    expect(value.block == null, false);
  });

  test("inline Fragment ", () {
    var parser = g.build(start: () => g.inlineFragment().end());
    var result = parser.parse('''
       ... on BasicEntity {
        id lastUpdate
       }
      
    
    ''');
    expect(result.isSuccess, true);
  });

  test("Fragment Value", () {
    var parser = g.build(start: () => g.fragmentNameValue().end());
    var result = parser.parse('''
       ... fragmentName
    ''');
    expect(result.isSuccess, true);
  });

  test("Inline fragment or fragment value", () {
    var parser = g.build(start: () => g.fragmentValue().end());
    var result = parser.parse('''
       ... fragmentName
    ''');
    expect(result.isSuccess, true);
    print("type = ${result.value.runtimeType}");

    result = parser.parse('''
        ... on BasicEntity {
        id lastUpdate
       }
      
    ''');
    expect(result.isSuccess, true);
    print("type = ${result.value.runtimeType}");
  });

  test("fragmentField test", () {
    var parser = g.build(start: () => g.fragmentField().end());
    var result = parser.parse('''
       ... fragmentName
    ''');
    expect(result.isSuccess, true);

    result = parser.parse('''
        ... on BasicEntity {
        id lastUpdate
       }
      
    ''');
    expect(result.isSuccess, true);

    result = parser.parse('''
       alias:name {
       id lastUpdate
       }
      
    ''');
    expect(result.isSuccess, true);
  });

  test("Fragment Definitions", () {
    var parser = g.build(start: () => g.fragmentDefinition().end());
    var result = parser.parse('''
       fragment productFields  on Product @skip(if: true) @include(if: false) {
          id @skip(if: true)  name {
            id
          }
          
          ...frag2
          ... on BasicEntity {
            lastUpdate @skip(if: true)
          }
      }
    ''');
    expect(result.isSuccess, true);
    print(result.value);
  });
}
