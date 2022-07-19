import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/grammar.dart';
import 'package:petitparser/petitparser.dart';

final GraphQlGrammar g = GraphQlGrammar();

void main() {
  test("Empty Array value test", () {
    var parser = g.build(start: () => g.arrayValue().end());
    var result = parser.parse("""[]""");
    expect(result.isSuccess, true);
  });

  test("One element Array value test", () {
    var parser = g.build(start: () => g.arrayValue().end());
    var result = parser.parse("""[1]""");
    expect(result.isSuccess, true);
  });

  test("Array values test", () {
    var parser = g.build(start: () => g.arrayValue().end());
    var result = parser.parse("""[]""");
    expect(result.isSuccess, true);

    result = parser.parse("""[{
      test: "hello"
      azul: 12
    }]""");
    expect(result.isSuccess, true);

    result = parser.parse("""[1,2,3,4]""");
    expect(result.isSuccess, true);

    result = parser.parse("""[{
      test: "hello"
      azul: 12
      fast: true
      object: {
        azul: 12
        fast: true
      }
    }, "Azul", "Fellawen"]""");
    expect(result.isSuccess, true);
  });

  test("Object value test", () {
    var parser = g.build(start: () => g.objectValue().end());
    var result = parser.parse("""{
      
    }""");
    expect(result.isSuccess, true);

    result = parser.parse("""{
      test: "hello"
      azul: 12
    }""");
    expect(result.isSuccess, true);

    result = parser.parse("""{
      test: "hello"
      azul: 12
      fast: true
    }""");
    expect(result.isSuccess, true);

    result = parser.parse("""{
      test: "hello"
      azul: 12
      fast: true
      object: {
        azul: 12
        fast: true
      }
    }""");
    expect(result.isSuccess, true);
  });

  test("Argument test", () {
    var parser = g.build(start: () => g.oneArgumentDefinition().end());
    var result = parser.parse("izan: int hello () ");
    expect(result.isSuccess, false);
    result = parser.parse("izan: int!");
    expect(result.isSuccess, true);

    result = parser.parse("izan: int! = 12");
    expect(result.isSuccess, true);
  });

  test("Comment test", () {
    var parser = g.build(start: g.singleLineComment);
    var result = parser.parse('''#Comment
    ''');
    print("parser value = '${result.value}'");
    expect(result.isSuccess, true);
  });

  test("identifier test", () {
    var parser = g.build(start: g.identifier);
    var result = parser.parse(''' test12 ''');
    print("parser value = '${result.value}'");
    expect(result.isSuccess, true);
    result = parser.parse(''' 1test ''');
    expect(result.isSuccess, false);
  });

  test("initialValue", () {
    var parser = g.build(start: () => g.initialValue().end());
    var result = parser.parse('''12''');

    expect(result.isSuccess, true);

    result = parser.parse('''12.12''');
    expect(result.isSuccess, true);

    result = parser.parse('''"String value"''');
    expect(result.isSuccess, true);

    result = parser.parse(''' true ''');
    expect(result.isSuccess, true);

    result = parser.parse('''false''');
    expect(result.isSuccess, true);

    result = parser.parse('''
    """
      Block
      String
       """
       ''');
    expect(result.isSuccess, true);
  });

  test("initialize Value", () {
    var parser = g.build(start: () => g.initialization().end());
    var result = parser.parse('''=12''');

    expect(result.isSuccess, true);

    result = parser.parse(''' = 12.12''');
    expect(result.isSuccess, true);

    result = parser.parse('''
     = "String value" #test
     ''');
    expect(result.isSuccess, true);

    result = parser.parse(''' = true ''');
    expect(result.isSuccess, true);

    result = parser.parse(''' = false''');
    expect(result.isSuccess, true);

    result = parser.parse('''=
    """
      Block
      String
       """
       ''');
    expect(result.isSuccess, true);
  });

  test("arguments Value", () {
    var parser = g.build(start: () => g.arguments().end());
    var result = parser.parse('''
    (test: String! = "hello", test2: Int = 3)
       ''');
    expect(result.isSuccess, true);
  });

  test("argumentValues Test", () {
    var parser = g.build(start: () => g.argumentValues().end());
    var result = parser.parse('''
    (test:  "hello", test2:  3)
       ''');
    expect(result.isSuccess, true);
  });

  test("Parametrized argument Test", () {
    var parser = g.build(start: () => g.parametrizedArgument().end());
    var result = parser.parse('''\$azul''');
    expect(result.isSuccess, true);

    result = parser.parse('''azul''');
    expect(result.isSuccess, false);
  });
}
