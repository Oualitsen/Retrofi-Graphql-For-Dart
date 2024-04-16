import 'package:retrofit_graphql/src/excpetions/parse_exception.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_directive.dart';
import 'package:retrofit_graphql/src/model/gq_token.dart';
import 'package:retrofit_graphql/src/model/gq_type_definition.dart';
import 'package:retrofit_graphql/src/utils.dart';

class GQTypedFragment {
  final GQFragmentDefinitionBase fragment;
  final GQTypeDefinition onType;

  GQTypedFragment(this.fragment, this.onType);
}

abstract class GQFragmentDefinitionBase extends GQToken {
  final String onTypeName;

  final GQFragmentBlockDefinition block;
  final List<GQDirectiveValue> directives;

  final Set<GQFragmentDefinitionBase> dependecies = {};

  GQFragmentDefinitionBase(
    super.token,
    this.onTypeName,
    this.block,
    this.directives,
  );

  void updateDepencies(Map<String, GQFragmentDefinitionBase> map) {
    final Set<String> dependecyNames = block.getDependecies(map);
    for (var name in dependecyNames) {
      final def = map[name];
      if (def == null) {
        throw ParseException("Fragment $name is not defined");
      }
      dependecies.add(def);
    }
  }

  String generateName();
}

class GQInlineFragmentDefinition extends GQFragmentDefinitionBase {
  GQInlineFragmentDefinition(
      String onTypeName, GQFragmentBlockDefinition block, List<GQDirectiveValue> directives)
      : super(
          "Inline_${generateUuid('_')}",
          onTypeName,
          block,
          directives,
        ) {
    if (!block.projections.containsKey(GQGrammar.typename)) {
      block.projections[GQGrammar.typename] = GQProjection(
          fragmentName: null, token: GQGrammar.typename, alias: null, block: null, directives: []);
    }
  }

  @override
  String serialize() {
    return """... on $onTypeName ${directives.map((e) => e.serialize()).join(" ")} ${block.serialize()} """;
  }

  @override
  String generateName() {
    return "${onTypeName}_inline_${block.uniqueName}";
  }
}

class GQFragmentDefinition extends GQFragmentDefinitionBase {
  /// can be an interface or a type

  final String fragmentName;

  GQFragmentDefinition(this.fragmentName, String onTypeName, GQFragmentBlockDefinition block,
      List<GQDirectiveValue> directives)
      : super(fragmentName, onTypeName, block, directives);

  @override
  String toString() {
    return serialize();
  }

  @override
  String serialize() {
    return """fragment $fragmentName on $onTypeName${serializeDirectives(directives)}${block.serialize()}""";
  }

  @override
  String generateName() {
    return "${onTypeName}_$fragmentName";
  }
}

class GQInlineFragmentsProjection extends GQProjection {
  final List<GQInlineFragmentDefinition> inlineFragments;
  GQInlineFragmentsProjection({required this.inlineFragments})
      : super(
          alias: null,
          directives: const [],
          fragmentName: null,
          token: null,
          block: null,
        );
}

class GQProjection extends GQToken {
  ///
  ///This contains a reference to the fragment name containing this projection
  ///
  ///something like  ... fragmentName

  ///
  final String? fragmentName;

  ///
  ///This should contain the name of the type this projection is on
  ///
  final String? alias;

  ///
  ///  something like  ... fragmentName
  ///
  bool get isFragmentReference => fragmentName != null;

  ///
  ///  something like
  ///  ... on Entity {
  ///   id creationDate ...
  ///  }
  ///

  final GQFragmentBlockDefinition? block;

  final List<GQDirectiveValue> directives;

  GQProjection({
    required this.fragmentName,
    required String? token,
    required this.alias,
    required this.block,
    required this.directives,
  }) : super(token ?? fragmentName ?? "projection_${generateUuid('_')}");

  @override
  String toString() {
    return serialize();
  }

  String get actualName => alias ?? token;

  @override
  String serialize() {
    if (this is GQInlineFragmentsProjection) {
      return serializeList((this as GQInlineFragmentsProjection).inlineFragments,
          join: " ", withParenthesis: false);
    }
    String result = "";
    if (isFragmentReference) {
      result = "...";
    }
    if (alias != null) {
      result += "$alias:$token";
    } else {
      result += token;
    }
    result += serializeDirectives(directives);

    result += block?.serialize() ?? '';

    return result;
  }

  Set<String> getDependecies(Map<String, GQFragmentDefinitionBase> map) {
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
    return """{${serializeList(projections.values.toList(), join: " ", withParenthesis: false)}}""";
  }

  @override
  String toString() {
    return serialize();
  }

  Set<String> getDependecies(Map<String, GQFragmentDefinitionBase> map) {
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

  List<GQProjection> getFragmentReferences() {
    return projections.values.where((projection) => projection.isFragmentReference).toList();
  }
}
