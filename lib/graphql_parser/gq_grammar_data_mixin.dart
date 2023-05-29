import 'package:parser/graphql_parser/excpetions/parse_exception.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';
import 'package:parser/graphql_parser/model/gq_schema.dart';
import 'package:parser/graphql_parser/model/gq_enum_definition.dart';
import 'package:parser/graphql_parser/model/gq_fragment.dart';
import 'package:parser/graphql_parser/model/gq_input_type.dart';
import 'package:parser/graphql_parser/model/gq_interface.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';
import 'package:parser/graphql_parser/model/gq_type.dart';
import 'package:parser/graphql_parser/model/gq_union.dart';
import 'package:parser/graphql_parser/model/gq_queries.dart';

mixin GrammarDataMixin {
  static const typename = "__typename";
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

  final Map<String, GQTypeDefinition> projectedTypes = {};

  GQSchema schema = GQSchema();
  bool schemaInitialized = false;

  void addScalarDefinition(String scalar) {
    if (scalars.contains(scalar)) {
      throw ParseException("Scalar $scalar has already been declared");
    }

    scalars.add(scalar);
  }

  void addFragmentDefinition(GQFragmentDefinition fragment) {
    if (fragments.containsKey(fragment.fragmentName)) {
      throw ParseException(
          "Fragment ${fragment.fragmentName} has already been declared");
    }
    fragments[fragment.fragmentName] = fragment;
  }

  void addUnionDefinition(GQUnionDefinition union) {
    if (unions.containsKey(union.token)) {
      throw ParseException("Union ${union.token} has already been declared");
    }
    unions[union.token] = union;
  }

  void addInputDefinition(GQInputDefinition input) {
    if (inputs.containsKey(input.token)) {
      throw ParseException("Input ${input.token} has already been declared");
    }
    inputs[input.token] = input;
  }

  void addTypeDefinition(GQTypeDefinition type) {
    if (types.containsKey(type.token)) {
      throw ParseException("Type ${type.token} has already been declared");
    }
    types[type.token] = type;
  }

  void addInterfaceDefinition(GQInterfaceDefinition interface) {
    if (interfaces.containsKey(interface.token)) {
      throw ParseException(
          "Interface ${interface.token} has already been declared");
    }
    interfaces[interface.token] = interface;
  }

  void addEnumDefinition(GQEnumDefinition enumDefinition) {
    if (enums.containsKey(enumDefinition.token)) {
      throw ParseException(
          "Enum ${enumDefinition.token} has already been declared");
    }
    enums[enumDefinition.token] = enumDefinition;
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
      throw ParseException(
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
      throw ParseException("Type $name undefined");
    }
  }

  void checkInput(String inputName) {
    if (!inputs.containsKey(inputName)) {
      throw ParseException("Input $inputName undefined");
    }
  }

  void checkInterface(String interface) {
    if (!interfaces.containsKey(interface)) {
      throw ParseException("Interface $interface undefined");
    }
  }

  void defineSchema(GQSchema schema) {
    if (schemaInitialized) {
      throw ParseException("A schema has already been defined");
    }
    schemaInitialized = true;
    this.schema = schema;
  }

  void checkScalar(String scalarName) {
    if (!scalars.contains(scalarName)) {
      throw ParseException("Scalar $scalarName was not declared");
    }
  }

  void updateFragmentDependencies() {
    fragments.forEach((key, value) {
      value.updateDepencies(fragments);
    });
  }

  GQTypeDefinition defineTypeWithFragment(
      GQTypeDefinition type, GQFragmentDefinition fragment) {
    /**
     * Check if fragment applies to this type
     */

    if (fragment.onTypeName != type.token) {
      throw ParseException(
          "Fragment $fragment does not apply to $type. It applies to ${fragment.onTypeName}");
    }
    final children = fragment.block.projections;
    final fields = <GQField>[];
    for (var field in type.fields) {
      var projection = children[field.name];
      if (projection != null) {
        fields.add(applyProjection(field, projection));
      }
    }

    type.fields.clear();
    type.fields.addAll(fields);

    return type;
  }

  GQField applyProjection(GQField field, GQProjection projection) {
    final String fieldName = projection.alias ?? field.name;
    if (projection.isFragmentReference) {}
    return GQField(
      name: fieldName,
      type: field.type,
      arguments: field.arguments,
    );
  }

  GQTypeDefinition getType(String name) {
    final type = types[name];
    if (type == null) {
      throw ParseException("Type $name has was not found");
    }
    return type;
  }

  GQFragmentDefinition getFragment(String name) {
    final type = fragments[name];
    if (type == null) {
      throw ParseException("Fragment $name has was not found");
    }
    return type;
  }

  GQInterfaceDefinition getInterface(String name) {
    final type = interfaces[name];
    if (type == null) {
      throw ParseException("Interface $name has was not found");
    }
    return type;
  }

  void updateDirectives() {
    /**
     * @TODO
     */
  }

  void fillProjectedTypes() {
    print("filling projected types");
    fragments.forEach((key, fragment) {
      createProjectedType(
          fragment.onTypeName, fragment.fragmentName, fragment.block);
    });
  }

  GQTypeDefinition createProjectedType(
      String typeName, String? fragmentName, GQFragmentBlockDefinition block) {
    final type = getTypeOrInterfaceDefinition(typeName);

    if (type == null) {
      throw ParseException("Type or interface $typeName is not defined");
    }

    final newName = "${type.token}_${fragmentName ?? ''}";

    if (types[newName] != null) {
      //already defined
      return types[newName]!;
    }

    ///
    ///Let's create a new type based on the type name
    ///
    List<GQField> fields = [];
    final newType = GQTypeDefinition(
        name: newName, fields: fields, interfaceNames: {}, directives: []);
    print("new type name = ${newType.token}");

    ///
    ///let's get the fields
    ///
    print("_________________ $typeName");
    block.projections.forEach((key, value) {
      print("projection = $value key = ${key}");
      fields.addAll(createFragmentField(type, value));
    });
    addTypeDefinition(newType);
    return newType;
  }

  List<GQField> createFragmentField(
      GQTokenWithFields type, GQProjection projection) {
    print("projection name = ${projection.actualName}");

    if (projection.isFragmentReference) {
      //this is a fragment reference ...

      var result = <GQField>[];
      final frag = getFragment(projection.token);
      frag.block.projections.forEach((key, value) {
        result.addAll(createFragmentField(type, value));
      });
      return result;
    }
    if (projection.block != null) {
      print("##################### block is not null ${type.token}");

      return [];
    }

    if (projection.token == typename) {
      /**
       * __typename case
       */
      return [
        GQField(name: typename, type: GQType("String", false), arguments: [])
      ];
    }

    var list = type.fields.where((element) => element.name == projection.token);

    if (list.isEmpty) {
      throw ParseException(
          "${type.token} does not define a field with name ${projection.token}");
    }
    final field = list.first;
    return [
      GQField(
          name: projection.actualName,
          type: field.type,
          arguments: field.arguments)
    ];
  }

  GQTokenWithFields? getTypeOrInterfaceDefinition(String name) {
    return types[name] ?? interfaces[name];
  }
}
