import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/grammar.dart';
import 'package:petitparser/core.dart';
import 'package:petitparser/petitparser.dart';

final GraphQlGrammar g = GraphQlGrammar();

void main() {
  test("Enum  test", () {
    var parser = g.build(start: () => g.enumDefinition().end());
    var result = parser.parse('''
      
      enum Gender @sikp(if: true) {
        "Documenation 1"
        Male 
        """ 
        Documenation 1
        
        """
        Female
      }
    
    ''');
    expect(result.isSuccess, true);
  });
}
