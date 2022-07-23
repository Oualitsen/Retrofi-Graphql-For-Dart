import 'package:parser/graphql_parser/excpetions/parse_error.dart';
import 'package:parser/graphql_parser/model/gq_schema.dart';
import 'package:parser/graphql_parser/model/gq_enum_definition.dart';
import 'package:parser/graphql_parser/model/gq_fragment.dart';
import 'package:parser/graphql_parser/model/gq_input_type.dart';
import 'package:parser/graphql_parser/model/gq_interface.dart';
import 'package:parser/graphql_parser/model/gq_union.dart';
import 'package:parser/graphql_parser/model/gq_queries.dart';

mixin GrammarDataMixin {
  final Set<String> scalars = {
    "ID",
    "Boolean",
    "Int",
    "Float",
    "String",
    "null"
  };
  final Map<String, GQFragmentDefinition> fragments = {};
  final Map<String, GQUnionDefinition> unions = {};
  final Map<String, GQInputDefinition> inputs = {};
  final Map<String, GQTypeDefinition> types = {};
  final Map<String, GQInterfaceDefinition> interfaces = {};
  final Map<String, GQDefinition> queries = {};
  final Map<String, GQDefinition> mutations = {};
  final Map<String, GQDefinition> subscriptions = {};
  final Map<String, GQEnumDefinition> enums = {};

  GQSchema schema = GQSchema();
  bool schemaInitialized = false;

  void addScalarDefinition(String scalar) {
    if (scalars.contains(scalar)) {
      throw "Scalar $scalar has already been declared";
    }

    scalars.add(scalar);
  }

  void addFragmentDefinition(GQFragmentDefinition fragment) {
    if (fragments.containsKey(fragment.name)) {
      throw ParseError("Fragment ${fragment.name} has already been declared");
    }
    fragments[fragment.name] = fragment;
  }

  void addUnionDefinition(GQUnionDefinition union) {
    if (unions.containsKey(union.name)) {
      throw ParseError("Union ${union.name} has already been declared");
    }
    unions[union.name] = union;
  }

  void addInputDefinition(GQInputDefinition input) {
    if (inputs.containsKey(input.name)) {
      throw ParseError("Input ${input.name} has already been declared");
    }
    inputs[input.name] = input;
  }

  void addTypeDefinition(GQTypeDefinition type) {
    if (types.containsKey(type.name)) {
      throw ParseError("Type ${type.name} has already been declared");
    }
    types[type.name] = type;
  }

  void addInterfaceDefinition(GQInterfaceDefinition interface) {
    if (interfaces.containsKey(interface.name)) {
      throw ParseError("Interface ${interface.name} has already been declared");
    }
    interfaces[interface.name] = interface;
  }

  void addEnumDefinition(GQEnumDefinition enumDefinition) {
    if (enums.containsKey(enumDefinition.name)) {
      throw ParseError("Enum ${enumDefinition.name} has already been declared");
    }
    enums[enumDefinition.name] = enumDefinition;
  }

  void addQueryDefinition(GQDefinition definition) {
    Map<String, GQDefinition> map;
    switch (definition.type) {
      case GQQueryType.query:
        map = queries;
        break;
      case GQQueryType.mutation:
        map = mutations;
        break;
      case GQQueryType.subscription:
        map = subscriptions;
        break;
    }
    if (map.containsKey(definition.name)) {
      throw ParseError(
          "${definition.type.name} ${definition.name} has already been declared");
    }
    map[definition.name] = definition;
  }

  void checkType(String name) {
    bool b = scalars.contains(name) ||
        unions.containsKey(name) ||
        types.containsKey(name) ||
        inputs.containsKey(name) ||
        interfaces.containsKey(name) ||
        enums.containsKey(name);
    if (!b) {
      throw ParseError("Type $name undefined");
    }
  }

  void checkInput(String inputName) {
    if (!inputs.containsKey(inputName)) {
      throw ParseError("Input $inputName undefined");
    }
  }

  void checkInterface(String interface) {
    if (!interfaces.containsKey(interface)) {
      throw ParseError("Interface $interface undefined");
    }
  }

  void defineSchema(GQSchema schema) {
    if (schemaInitialized) {
      throw ParseError("A schema has already been defined");
    }
    schemaInitialized = true;
    this.schema = schema;
  }

  void checkScalar(String scalarName) {
    if (!scalars.contains(scalarName)) {
      throw ParseError("Scalar $scalarName was not declared");
    }
  }

  void updateFragmentDependencies() {
    fragments.forEach((key, value) {
      value.updateDepencies(fragments);
    });
  }
}
