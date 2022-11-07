import 'package:parser/graphql_parser/excpetions/parse_exception.dart';
import 'package:parser/graphql_parser/model/gq_directive.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';
import 'package:parser/graphql_parser/utils.dart';

class GQFragmentDefinition extends GQTokenWithDirectives {
  /// can be an interface or a type
  final String onTypeName;

  final GQFragmentBlockDefinition block;
  final List<GQDirectiveValue> directiveList;

  final Set<GQFragmentDefinition> dependecies = {};

  GQFragmentDefinition(
      String name, this.onTypeName, this.block, this.directiveList)
      : super(name);

  @override
  String toString() {
    //return 'Fragment{name: $name, onTypeName: $onTypeName, block: $block}';
    return serialize();
  }

  @override
  List<GQDirectiveValue> get directives => directiveList;

  @override
  String serialize() {
    return """
      fragment $name on $onTypeName ${directiveList.map((e) => e.serialize()).join(" ")} ${block.serialize()} 
    """;
  }

  void updateDepencies(Map<String, GQFragmentDefinition> map) {
    final Set<String> dependecyNames = block.getDependecies(map);
    for (var name in dependecyNames) {
      final def = map[name];
      if (def == null) {
        print("Fragment is not defined");
        throw ParseException("Fragment $name is not defined");
      }
      dependecies.add(def);
    }
  }
}

class GQProjection extends GQTokenWithDirectives {
  final String? alias;

  ///
  ///  something like  ... fragmentName
  ///
  final bool isFragmentReference;

  ///
  ///  something like
  ///  ... on Entity {
  ///   id creationDate ...
  ///  }
  ///

  final GQFragmentBlockDefinition? block;

  final List<GQDirectiveValue> directiveList;

  GQProjection({
    required String name,
    required this.alias,
    required this.isFragmentReference,
    required this.block,
    required this.directiveList,
  }) : super(name);

  @override
  String toString() {
    //return 'FragmentField{fieldName: $name, alias: $alias}';
    return serialize();
  }

  @override
  List<GQDirectiveValue> get directives => directiveList;

  String get uniqueName {
    return "${actualName}_";
  }

  String get actualName => alias ?? name;

  @override
  String serialize() {
    String result = "";
    if (isFragmentReference) {
      result = "... ";
    }
    if (alias != null) {
      result += "$alias: $name";
    } else {
      result += name;
    }
    result +=
        " ${serializeList(directives, join: " ", withParenthesis: false)}";

    result += block?.serialize() ?? '';

    return result;
  }

  Set<String> getDependecies(Map<String, GQFragmentDefinition> map) {
    final result = <String>{};
    if (isFragmentReference) {
      if (block == null) {
        result.add(name);

        var frag = map[name];
        if (frag == null) {
          throw ParseException("Fragment $name is not defined");
        } else {
          result.addAll(frag.block.getDependecies(map));
        }
      } else {
        ///
        ///This should be an inline fragment
        ///

        var inlineFrag = this as GQInlineFragmentDefinition;
        var block = inlineFrag.block;
        if (block == null) {
          throw ParseException("Inline Fragment must have a body");
        }
        result.addAll(block.getDependecies(map));
      }
    }
    if (block != null) {
      var children = block!.projections.values;
      for (var element in children) {
        result.addAll(element.getDependecies(map));
      }
    }

    return result;
  }
}

class GQInlineFragmentDefinition extends GQProjection {
  final String typeName;
  GQInlineFragmentDefinition(this.typeName, GQFragmentBlockDefinition block,
      List<GQDirectiveValue> directives)
      : super(
          name: "",
          isFragmentReference: true,
          block: block,
          alias: null,
          directiveList: directives,
        );

  @override
  String get name => "${typeName}_${block.uniqueName}";

  @override
  GQFragmentBlockDefinition get block => super.block!;
}

class GQFragmentBlockDefinition {
  final Map<String, GQProjection> projections = {};

  GQFragmentBlockDefinition(List<GQProjection> projections) {
    for (var element in projections) {
      this.projections[element.name] = element;
    }
  }

  GQProjection getProjection(String name) {
    final p = projections[name];
    if (p == null) {
      throw ParseException("Could not find projection with name is $name");
    }
    return p;
  }

  String serialize() {
    return """{
      ${serializeList(projections.values.toList(), join: " ", withParenthesis: false)}
    }""";
  }

  @override
  String toString() {
    return serialize();
  }

  Set<String> getDependecies(Map<String, GQFragmentDefinition> map) {
    var result = <String>{};
    var _projections = projections.values;
    for (var v in _projections) {
      result.addAll(v.getDependecies(map));
    }
    return result;
  }

  String get uniqueName {
    final keys = projections.keys.toList();
    keys.sort();
    return keys.join("_");
  }
}
