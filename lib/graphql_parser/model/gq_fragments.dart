import 'package:parser/graphql_parser/model/gq_directive.dart';
import 'package:parser/graphql_parser/model/token.dart';
import 'package:parser/graphql_parser/utils.dart';

class GQFragmentDefinition extends GQTokenWithDirectives {
  /// can be an interface or a type
  final String onTypeName;

  final GQFragmentBlock block;
  final List<GQDirective> directiveList;

  final List<GQFragmentDefinition> children = [];

  GQFragmentDefinition(
      String name, this.onTypeName, this.block, this.directiveList)
      : super(name);

  @override
  String toString() {
    return 'Fragment{name: $name, onTypeName: $onTypeName, block: $block}';
  }

  @override
  List<GQDirective> get directives => directiveList;

  @override
  String serialize() {
    return """
      fragment $name on $onTypeName ${directiveList.map((e) => e.serialize()).join(" ")} ${block.serialize()} 
    """;
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

  final List<GQDirective> directiveList;

  GQFragmentField({
    required String name,
    required this.alias,
    required this.isFragment,
    required this.block,
    required this.directiveList,
  }) : super(name);

  @override
  String toString() {
    return 'FragmentField{fieldName: $name, alias: $alias}';
  }

  List<GQDirective> get directive => directiveList;

  @override
  String serialize() {
    String result = "";
    if (isFragment) {
      result = "...";
    }
    if (alias != null) {
      result += "$alias: $name";
    } else {
      result += name;
    }
    result += " ${serializeList(directive, join: " ", withParenthesis: false)}";

    return result;
  }
}

class GQInlineFragment extends GQFragmentField {
  final String typeName;
  GQInlineFragment(
      this.typeName, GQFragmentBlock block, List<GQDirective> directives)
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
      ${serializeList(children, join: "\n", withParenthesis: false)}
    }""";
  }
}
