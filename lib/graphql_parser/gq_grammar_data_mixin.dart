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
  static const __typename = "__typename";
  final Set<String> scalars = {
    "ID",
    "Boolean",
    "Int",
    "Float",
    "String",
    "null"
  };
  final Map<String, GQFragmentDefinitionBase> fragments = {};
  final Map<String, GQTypedFragment> typedFragments = {};
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
    checkSacalarDefinition(scalar);
    scalars.add(scalar);
  }

  void checkSacalarDefinition(String scalar) {
    if (scalars.contains(scalar)) {
      throw ParseException("Scalar $scalar has already been declared");
    }
  }

  void addFragmentDefinition(GQFragmentDefinitionBase fragment) {
    checkFragmentDefinition(fragment);
    fragments[fragment.token] = fragment;
  }

  void addUnionDefinition(GQUnionDefinition union) {
    checkUnitionDefinition(union);
    unions[union.token] = union;
  }

  void addInputDefinition(GQInputDefinition input) {
    checkInputDefinition(input);
    inputs[input.token] = input;
  }

  void addTypeDefinition(GQTypeDefinition type) {
    checkTypeDefinition(type);
    types[type.token] = type;
  }

  void addInterfaceDefinition(GQInterfaceDefinition interface) {
    checkInterfaceDefinition(interface);
    interfaces[interface.token] = interface;
  }

  void addEnumDefinition(GQEnumDefinition enumDefinition) {
    checmEnumDefinition(enumDefinition);
    enums[enumDefinition.token] = enumDefinition;
  }

  void addQueryDefinition(GQDefinition definition) {
    checkQueryDefinition(definition.token, definition.type);
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

    map[definition.token] = definition;
  }

  void checmEnumDefinition(GQEnumDefinition enumDefinition) {
    if (enums.containsKey(enumDefinition.token)) {
      throw ParseException(
          "Enum ${enumDefinition.token} has already been declared");
    }
  }

  void checkInterfaceDefinition(GQInterfaceDefinition interface) {
    if (interfaces.containsKey(interface.token)) {
      throw ParseException(
          "Interface ${interface.token} has already been declared");
    }
  }

  void checkTypeDefinition(GQTypeDefinition type) {
    if (types.containsKey(type.token)) {
      throw ParseException("Type ${type.token} has already been declared");
    }
  }

  void checkIfDefined(String typeName) {
    if (types.containsKey(typeName) ||
        enums.containsKey(typeName) ||
        scalars.contains(typeName)) {
      return;
    }
    throw ParseException("Type $typeName is not defined");
  }

  void checkInputDefinition(GQInputDefinition input) {
    if (inputs.containsKey(input.token)) {
      throw ParseException("Input ${input.token} has already been declared");
    }
  }

  void checkUnitionDefinition(GQUnionDefinition union) {
    if (unions.containsKey(union.token)) {
      throw ParseException("Union ${union.token} has already been declared");
    }
  }

  void checkFragmentDefinition(GQFragmentDefinitionBase fragment) {
    if (fragments.containsKey(fragment.token)) {
      throw ParseException(
          "Fragment ${fragment.token} has already been declared");
    }
  }

  void checkQueryDefinition(String token, GQQueryType type) {
    switch (type) {
      case GQQueryType.query:
        if (queries.containsKey(token)) {
          throw ParseException("Query $token has already been declared");
        }
        break;
      case GQQueryType.mutation:
        if (mutations.containsKey(token)) {
          throw ParseException("Mutation $token has already been declared");
        }
        break;
      case GQQueryType.subscription:
        if (subscriptions.containsKey(token)) {
          throw ParseException("subscription $token has already been declared");
        }
        break;
    }
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

  GQTypeDefinition getType(String name) {
    final type = types[name];
    if (type == null) {
      throw ParseException("Type $name has was not found");
    }
    return type;
  }

  GQFragmentDefinitionBase getFragment(String name) {
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

  void fillTypedFragments() {
    fragments.forEach((key, fragment) {
      checkIfDefined(fragment.onTypeName);
      typedFragments[key] =
          GQTypedFragment(fragment, types[fragment.onTypeName]!);
    });
  }

  void createProjectedTypes() {
    print("####### typedFagments = (${typedFragments.length})");

    typedFragments.forEach((key, value) {
      createprojectedType(value.fragment, value.onType);
    });
    print("Created types = ${projectedTypes.keys}");
  }

  void createprojectedType(
      GQFragmentDefinitionBase fragment, GQTypeDefinition onType) {
    var name = "${fragment.token}_on_${onType.token}";

    var newType = GQTypeDefinition(
        name: name,
        fields: applyProjection(onType.fields, fragment.block.projections),
        interfaceNames: onType.interfaceNames,
        directives: onType.directives);

    projectedTypes[name] = newType;
  }

  GQTypeDefinition createProjectedTypeWithProjectionBlock(
      GQTypeDefinition nonProjectedType, GQFragmentBlockDefinition block) {
    print("Creating a type using a projection block");
    var name = generateName(nonProjectedType.token, block);
    var result = GQTypeDefinition(
        name: name,
        fields: applyProjection(nonProjectedType.fields, block.projections),
        interfaceNames: {},
        directives: []);

    projectedTypes[name] = result;
    return result;
  }

  String generateName(String originalName, GQFragmentBlockDefinition block) {
    var name = "${originalName}_${block.uniqueName}";
    String? indexedName;
    int nameIndex = 0;
    while (projectedTypes.containsKey(name)) {
      indexedName = "${name}_${++nameIndex}";
    }
    return indexedName ?? name;
  }

  List<GQField> applyProjection(
      List<GQField> src, Map<String, GQProjection> projections) {
    var result = <GQField>[];
    for (var field in src) {
      var projection = projections[field.name];
      if (projection != null) {
        result.add(applyProjectionToField(field, projection));
      }
    }

    return result;
  }

  GQField applyProjectionToField(GQField field, GQProjection projection) {
    final String fieldName = projection.alias ?? field.name;
    if (projection.isFragmentReference) {
      print("fragment reference fragment name is ${projection.fragmentName}");
      /**
       * @TODO we should first create another type using the fragment name before
       */
    }

    if (projection.block != null) {
      print("@@@@@@@@@@@@@@@ block not null");
      //we should create another type here ...
      var generatedType = createProjectedTypeWithProjectionBlock(
          getType(field.type.token), projection.block!);
      return GQField(
        name: fieldName,
        type: GQType(generatedType.token, field.type.nullable, isScalar: false),
        arguments: field.arguments,
      );
    }

    return GQField(
      name: fieldName,
      type: field.type,
      arguments: field.arguments,
    );
  }

  GQTokenWithFields? getTypeOrInterfaceDefinition(String name) {
    return types[name] ?? interfaces[name];
  }
}
