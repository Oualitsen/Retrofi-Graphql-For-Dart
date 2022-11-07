import 'package:parser/graphql_parser/excpetions/parse_exception.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';
import 'package:parser/graphql_parser/model/gq_schema.dart';
import 'package:parser/graphql_parser/model/gq_enum_definition.dart';
import 'package:parser/graphql_parser/model/gq_fragment.dart';
import 'package:parser/graphql_parser/model/gq_input_type.dart';
import 'package:parser/graphql_parser/model/gq_interface.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';
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
  final Map<String, GQInlineFragmentDefinition> inlineFragments = {};
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
    if (fragments.containsKey(fragment.name)) {
      throw ParseException(
          "Fragment ${fragment.name} has already been declared");
    }
    fragments[fragment.name] = fragment;
  }

  void addUnionDefinition(GQUnionDefinition union) {
    if (unions.containsKey(union.name)) {
      throw ParseException("Union ${union.name} has already been declared");
    }
    unions[union.name] = union;
  }

  void addInputDefinition(GQInputDefinition input) {
    if (inputs.containsKey(input.name)) {
      throw ParseException("Input ${input.name} has already been declared");
    }
    inputs[input.name] = input;
  }

  void addTypeDefinition(GQTypeDefinition type) {
    if (types.containsKey(type.name)) {
      throw ParseException("Type ${type.name} has already been declared");
    }
    types[type.name] = type;
  }

  void addInterfaceDefinition(GQInterfaceDefinition interface) {
    if (interfaces.containsKey(interface.name)) {
      throw ParseException(
          "Interface ${interface.name} has already been declared");
    }
    interfaces[interface.name] = interface;
  }

  void addEnumDefinition(GQEnumDefinition enumDefinition) {
    if (enums.containsKey(enumDefinition.name)) {
      throw ParseException(
          "Enum ${enumDefinition.name} has already been declared");
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

    if (fragment.onTypeName != type.name) {
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
      createProjectedType(fragment.onTypeName, fragment.name, fragment.block);
    });
  }

  GQTypeDefinition createProjectedType(
      String typeName, String? fragmentName, GQFragmentBlockDefinition block) {
    final type = getTypeOrInterfaceDefinition(typeName);

    if (type == null) {
      throw ParseException("Type or interface $typeName is not defined");
    }

    final newName = "${type.name}_${fragmentName ?? ''}";

    if (types[newName] != null) {
      //already defined
      return types[newName]!;
    }

    ///
    ///Let's create a new type based on the type name
    ///
    List<GQField> fields = [];
    final newType =
        GQTypeDefinition(name: newName, fields: fields, interfaceNames: {});
    print("new type name = ${newType.name}");

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

    if (projection is GQInlineFragmentDefinition) {
      print("handle inline fragment definition");

      final _type = createProjectedType(
          projection.typeName, projection.name, projection.block);
      print("_type = ${_type.name} has been created ...${projection.name}");
      return [];
    }

    if (projection.isFragmentReference) {
      //this is a fragment reference ...

      var result = <GQField>[];
      final frag = getFragment(projection.name);
      frag.block.projections.forEach((key, value) {
        result.addAll(createFragmentField(type, value));
      });
      return result;
    }
    if (projection.block != null) {
      // do something else here
      print("#####################  ");
    }
    var list = type.fields.where((element) => element.name == projection.name);

    if (list.isEmpty) {
      throw ParseException(
          "${type.name} does not define a field with name ${projection.name}");
    }
    final _field = list.first;
    final result = GQField(
        name: projection.actualName,
        type: _field.type,
        arguments: _field.arguments);
    return [result];
  }

  GQTokenWithFields? getTypeOrInterfaceDefinition(String name) {
    return types[name] ?? interfaces[name];
  }
}
