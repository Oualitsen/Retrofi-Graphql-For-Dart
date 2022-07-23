import 'package:parser/graphql_parser/excpetions/parse_error.dart';
import 'package:parser/graphql_parser/model/gq_directive.dart';
import 'package:parser/graphql_parser/model/gq_token.dart';
import 'package:parser/graphql_parser/utils.dart';

class GQFragmentDefinition extends GQTokenWithDirectives {
  /// can be an interface or a type
  final String onTypeName;

  final GQFragmentBlock block;
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
    var set = block.getDependecies(map);
    print("fragment $name depends on $set");
  }
}

class GQFragmentField extends GQToken {
  final String? alias;

  ///
  ///  something like  ... fragmentName
  ///
  final bool isFragment;

  ///
  ///  something like
  ///  ... on Entity {
  ///   id creationDate ...
  ///  }
  ///

  final GQFragmentBlock? block;

  final List<GQDirectiveValue> directiveList;

  GQFragmentField({
    required String name,
    required this.alias,
    required this.isFragment,
    required this.block,
    required this.directiveList,
  }) : super(name);

  @override
  String toString() {
    //return 'FragmentField{fieldName: $name, alias: $alias}';
    return serialize();
  }

  List<GQDirectiveValue> get directive => directiveList;

  @override
  String serialize() {
    String result = "";
    if (isFragment) {
      result = "... ";
    }
    if (alias != null) {
      result += "$alias: $name";
    } else {
      result += name;
    }
    result += " ${serializeList(directive, join: " ", withParenthesis: false)}";

    result += block?.serialize() ?? '';

    return result;
  }

  Set<String> getDependecies(Map<String, GQFragmentDefinition> map) {
    final result = <String>{};
    if (isFragment) {
      if (name.isNotEmpty) {
        result.add(name);

        var frag = map[name];
        if (frag == null) {
          throw ParseError("Fragment $name is not defined");
        } else {
          result.addAll(frag.block.getDependecies(map));
        }
      } else {
        ///
        ///This should be an inline fragment
        ///

        var inlineFrag = this as GQInlineFragment;
        var block = inlineFrag.block;
        if (block == null) {
          throw ParseError("Inline Fragment must have a body");
        }
        result.addAll(block.getDependecies(map));
      }
    }
    if (block != null) {
      var children = block!.children;
      for (var element in children) {
        result.addAll(element.getDependecies(map));
      }
    }

    return result;
  }
}

class GQInlineFragment extends GQFragmentField {
  final String typeName;
  GQInlineFragment(
      this.typeName, GQFragmentBlock block, List<GQDirectiveValue> directives)
      : super(
          name: "",
          isFragment: true,
          block: block,
          alias: null,
          directiveList: directives,
        );
}

class GQFragmentBlock extends GQToken {
  final List<GQFragmentField> children;

  GQFragmentBlock(this.children) : super("");

  @override
  String serialize() {
    return """{
      ${serializeList(children, join: " ", withParenthesis: false)}
    }""";
  }

  @override
  String toString() {
    return serialize();
  }

  Set<String> getDependecies(Map<String, GQFragmentDefinition> map) {
    var result = <String>{};
    for (var v in children) {
      result.addAll(v.getDependecies(map));
    }
    return result;
  }
}
