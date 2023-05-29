import 'package:parser/graphql_parser/excpetions/parse_exception.dart';
import 'package:parser/graphql_parser/model/gq_directive.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';
import 'package:parser/graphql_parser/utils.dart';

class GQFragmentDefinition extends GQToken {
  /// can be an interface or a type
  final String onTypeName;

  final GQFragmentBlockDefinition block;
  final List<GQDirectiveValue> directiveList;

  final Set<GQFragmentDefinition> dependecies = {};
  final String fragmentName;

  GQFragmentDefinition(
      this.fragmentName, this.onTypeName, this.block, this.directiveList)
      : super(fragmentName);

  @override
  String toString() {
    return serialize();
  }

  @override
  String serialize() {
    return """
      fragment $fragmentName on $onTypeName ${directiveList.map((e) => e.serialize()).join(" ")} ${block.serialize()} 
    """;
  }

  void updateDepencies(Map<String, GQFragmentDefinition> map) {
    final Set<String> dependecyNames = block.getDependecies(map);
    for (var name in dependecyNames) {
      final def = map[name];
      if (def == null) {
        throw ParseException("Fragment $name is not defined");
      }
      dependecies.add(def);
    }
  }
}

class GQProjection extends GQToken {
  ///
  ///This should contain the name of the type this projection is on
  ///
  final String? onTypeName;
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

  final List<GQDirectiveValue> directives;

  GQProjection({
    required String token,
    required this.onTypeName,
    required this.alias,
    required this.isFragmentReference,
    required this.block,
    required this.directives,
  }) : super(token);

  @override
  String toString() {
    //return 'FragmentField{fieldName: $name, alias: $alias}';
    return serialize();
  }

  String get uniqueName {
    return "${actualName}_";
  }

  String get actualName => alias ?? token;

  @override
  String serialize() {
    String result = "";
    if (isFragmentReference) {
      result = "... ";
    }
    if (alias != null) {
      result += "$alias: $token";
    } else {
      result += token;
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
        result.add(token);

        var frag = map[token];
        if (frag == null) {
          throw ParseException("Fragment $token is not defined");
        } else {
          result.addAll(frag.block.getDependecies(map));
        }
      } else {
        ///
        ///This should be an inline fragment
        ///

        var myBlock = block;
        if (myBlock == null) {
          throw ParseException("Inline Fragment must have a body");
        }
        result.addAll(myBlock.getDependecies(map));
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

class GQFragmentBlockDefinition {
  final Map<String, GQProjection> projections = {};

  GQFragmentBlockDefinition(List<GQProjection> projections) {
    for (var element in projections) {
      this.projections[element.token] = element;
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
    var p = projections.values;
    for (var v in p) {
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
