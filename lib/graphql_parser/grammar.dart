import 'package:parser/graphql_parser/model/gq_schema.dart';
import 'package:parser/graphql_parser/model/gq_argument.dart';
import 'package:parser/graphql_parser/model/gq_comment.dart';
import 'package:parser/graphql_parser/model/gq_directive.dart';
import 'package:parser/graphql_parser/grammar_data_mixin.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';
import 'package:parser/graphql_parser/model/gq_interface.dart';
import 'package:parser/graphql_parser/model/gq_type.dart';
import 'package:parser/graphql_parser/model/gq_input_type.dart';
import 'package:parser/graphql_parser/model/gq_fragments.dart';
import 'package:parser/graphql_parser/model/gq_queries.dart';
import 'package:petitparser/petitparser.dart';

class GraphQlGrammar extends GrammarDefinition with GrammarDataMixin {
  final Map<String, String> typeMap;

  GraphQlGrammar({
    this.typeMap = const {
      "ID": "String",
      "String": "String",
      "Float": "double",
      "Int": "int",
      "Boolean": "bool",
      "Null": "null"
    },
  });

  @override
  Parser start() => ref0(enumDefinition).end();

  Parser token(Object input) {
    if (input is Parser) {
      return input.trim(
        ref0(hiddenStuffWhitespace),
        ref0(hiddenStuffWhitespace),
      );
    } else if (input is String) {
      return token(input.toParser());
    }
    throw ArgumentError(input, "Invalid Token parser");
  }

  Parser<List<GQArgumentDefinition>> arguments({bool parametrized = false}) =>
      (openParen() &
              oneArgumentDefinition(parametrized: parametrized).star() &
              closeParen())
          .map((value) => value[1]);

  Parser<List<GQArgumentValue>> argumentValues() =>
      (openParen() & oneArgumentValue().star() & closeParen())
          .map((value) => value[1]);

  Parser<GQArgumentValue> oneArgumentValue() =>
      (ref1(token, identifier()) & colon() & ref1(token, initialValue()))
          .map((value) {
        return GQArgumentValue(value.first, value.last);
      });

  Parser openParen() => ref1(token, char("("));

  Parser closeParen() => ref1(token, char(")"));

  Parser openBrace() => ref1(token, char("{"));

  Parser closeBrace() => ref1(token, char("}"));

  Parser openSquareBracket() => ref1(token, char("["));

  Parser closeSquareBracket() => ref1(token, char("]"));

  Parser colon() => ref1(token, char(":"));

  Parser<GQTypeDefinition> typeDefinition() => (ref1(token, "type") &
              ref0(identifier) &
              implementsToken().optional() &
              directiveValue().star() &
              ref0(openBrace) &
              fieldList(
                required: true,
                canBeInitialized: true,
                acceptsArguments: true,
              ) &
              ref0(closeBrace))
          .map((value) {
        return GQTypeDefinition(
          name: value[1],
          fields: value[5],
          interfaceNames: value[2] ?? [],
        );
      });

  Parser<GQInputDefinition> inputDefinition() => (ref1(token, "input") &
              ref0(identifier) &
              directiveValue().star() &
              ref0(openBrace) &
              fieldList(
                  required: true,
                  canBeInitialized: true,
                  acceptsArguments: false) &
              ref0(closeBrace))
          .map((value) {
        return GQInputDefinition(name: value[1], fields: value[4]);
      });

  Parser<GQField> field(
      {required bool canBeInitialized, required acceptsArguments}) {
    late String name;
    late GQType type;
    String? _documentation;
    List<GQArgumentDefinition>? _arguments;
    Object? initialValue;
    return ([
      ref0(documentation).optional().map((value) => _documentation = value),
      identifier().map((value) {
        name = value;
        return value;
      }),
      if (acceptsArguments)
        arguments().optional().map((value) => _arguments = value),
      colon(),
      ref0(typeToken).map((value) => type = value),
      if (canBeInitialized)
        initialization().optional().map((value) => initialValue = value),
      directiveValue().star()
    ].toSequenceParser())
        .map((value) {
      return GQField(
          name: name,
          type: type,
          documentation: _documentation,
          arguments: _arguments ?? [],
          initialValue: initialValue);
    });
  }

  Parser<List<GQField>> fieldList({
    required bool required,
    required bool canBeInitialized,
    required bool acceptsArguments,
  }) {
    var p = field(
      canBeInitialized: canBeInitialized,
      acceptsArguments: acceptsArguments,
    );
    if (required) {
      return p.plus();
    } else {
      return p.star();
    }
  }

  Parser<GQInterfaceDefinition> interfaceDefinition() =>
      (ref1(token, "interface") &
              ref0(identifier) &
              implementsToken().optional() &
              directiveValue().star() &
              ref0(openBrace) &
              fieldList(
                required: true,
                canBeInitialized: false,
                acceptsArguments: false,
              ) &
              ref0(closeBrace))
          .map((value) {
        return GQInterfaceDefinition(
          name: value[1],
          fields: value[5],
          parenNames: value[2] ?? [],
        );
      });

  Parser enumDefinition() => (ref1(token, "enum") &
              ref0(identifier) &
              directiveValue().star() &
              ref0(openBrace) &
              (ref1(token, documentation().optional()) &
                      ref1(token, identifier()))
                  .plus() &
              ref0(closeBrace))
          .map((value) {
        return value;
      });

  Parser<GQDirective> directiveValue() {
    late String name;
    List<GQArgumentValue>? arguments;
    return (directiveName().map((value) => name = value) &
            ref1(token, argumentValues())
                .optional()
                .map((value) => arguments = value))
        .map((_) {
      return GQDirective(name, [], arguments ?? []);
    });
  }

  Parser<String> directiveName() =>
      ref1(token, "@".toParser() & identifier()).flatten();

  Parser directiveDefinition() =>
      ref1(token, "directive") &
      directiveName() &
      arguments().optional() &
      ref1(token, "on") &
      ref1(token, directiveScopes());

  Parser directiveScope() =>
      ref1(token, "QUERY") |
      ref1(token, "MUTATION") |
      ref1(token, "SUBSCRIPTION") |
      ref1(token, "FIELD") |
      ref1(token, "FRAGMENT_DEFINITION") |
      ref1(token, "FRAGMENT_SPREAD") |
      ref1(token, "INLINE_FRAGMENT") |
      ref1(token, "SCALAR") |
      ref1(token, "OBJECT") |
      ref1(token, "FIELD_DEFINITION") |
      ref1(token, "ARGUMENT_DEFINITION") |
      ref1(token, "INTERFACE") |
      ref1(token, "UNION") |
      ref1(token, "ENUM") |
      ref1(token, "ENUM_VALUE") |
      ref1(token, "INPUT_OBJECT") |
      ref1(token, "INPUT_FIELD_DEFINITION") |
      ref1(token, "VARIABLE_DEFINITION") |
      ref1(token, "SCHEMA");

  Parser directiveScopes() =>
      directiveScope() & (ref1(token, "|") & directiveScope()).star();

  Parser<GQArgumentDefinition> oneArgumentDefinition(
      {bool parametrized = false}) {
    late String name;
    late GQType type;
    Object? initialValue;
    return (ref0(parametrized ? parametrizedArgument : identifier)
                .map((value) => name = value) &
            colon() &
            ref0(typeToken).map((value) => type = value) &
            initialization().optional().map((value) => initialValue = value))
        .map((_) {
      return GQArgumentDefinition(name, type, initialValue: initialValue);
    });
  }

  Parser<String> parametrizedArgument() =>
      ref1(token, (char("\$") & identifier())).map((value) => value.join());

  Parser<String> refValue() =>
      ref1(token, (char("\$") & identifier())).map((value) => value.join());

  Parser<GQArgumentValue> onArgumentValue() =>
      (ref0(identifier) & colon() & initialValue()).map((value) {
        return GQArgumentValue(value.first, value.last);
      });

  Parser<Object> initialization() =>
      (ref1(token, "=") & ref1(token, initialValue()))
          .map((value) => value.last);

  Parser<Object> initialValue() => ref1(
              token,
              [
                doubleParser(),
                intParser(),
                stringToken(),
                boolean(),
                ref0(objectValue),
                ref0(arrayValue),
                ref1(token, refValue()),
                nullParser()
              ].toChoiceParser())
          .map((value) {
        return value;
      });

  Parser nullParser() => "null".toParser();

  Parser objectValue() =>
      openBrace() &
      ref1(token, identifier() & colon() & initialValue()).star() &
      closeBrace();

  Parser arrayValue() =>
      openSquareBracket() & ref0(initialValue).star() & closeSquareBracket();

  Parser<GQType> typeToken() =>
      (ref0(simpleTypeToken) | ref0(listType)).cast<GQType>();

  Parser<GQType> simpleTypeToken() {
    late String name;
    bool nullable = true;
    return (ref1(token, identifier().map((value) => name = value)) &
            ref1(token, char("!")).optional().map((value) => nullable = false))
        .map((value) {
      return GQType(name, nullable, isScalar: false);
    });
  }

  Parser<GQType> listType() {
    bool nullable = true;
    late GQType type;
    return ((ref1(token, char('[')) &
                    simpleTypeToken().map((value) => type = value) &
                    ref1(token, char(']')))
                .map((value) => value[1] as GQType) &
            ref1(token, char("!")).optional().map((value) => nullable = false))
        .map((value) {
      return GQListType(type, nullable);
    });
  }

  Parser complexType() => (openBrace() &
      (identifier() & colon() & (typeToken() | ref0(complexType))).star() &
      closeBrace());

  Parser<String> identifier() => ref1(
          token,
          (ref0(_myLetter) & (((ref0(_myLetter) | ref0(number)).star())))
              .flatten())
      .cast<String>();

  Parser number() => ref0(digit).plus();

  Parser _myLetter() => ref0(letter) | char("_");

  Parser hiddenStuffWhitespace() =>
      (ref0(visibleWhitespace) | ref0(singleLineComment) | ref0(commas));

  Parser<String> visibleWhitespace() => whitespace();

  Parser commas() => char(",");

  Parser doubleQuote() => char('"');

  Parser tripleQuote() => string('"""');

  Parser<GQComment> singleLineComment() =>
      (char('#') & ref0(newlineLexicalToken).neg().star())
          .flatten()
          .map((value) => GQComment(value));

  Parser singleLineStringLexicalToken() =>
      doubleQuote() &
      ref0(stringContentDoubleQuotedLexicalToken) &
      doubleQuote();

  Parser stringContentDoubleQuotedLexicalToken() => doubleQuote().neg().star();

  Parser<String> singleLineStringToken() =>
      (char('"') & pattern("\"\n\r").neg().star() & char('"')).flatten();

  Parser<String> blockStringToken() =>
      ('"""'.toParser() & pattern('"""').neg().star() & '"""'.toParser())
          .flatten();

  Parser<String> stringToken() =>
      (blockStringToken() | singleLineStringToken()).flatten();

  Parser<String> documentation() =>
      (blockStringToken() | singleLineStringToken()).flatten();

  Parser newlineLexicalToken() => pattern('\n\r');

  /// carry on from here
  Parser<List<String>> implementsToken() =>
      (ref1(token, "implements") & interfaceList()).map((value) => value[1]);

  Parser<List<String>> interfaceList() {
    List<String> interfaceList = [];
    return (identifier().map((value) => interfaceList.add(value)) &
            (ref1(token, "&") &
                    identifier().map((value) => interfaceList.add(value)))
                .star())
        .map((_) {
      return interfaceList;
    });
  }

  Parser<bool> boolean() =>
      ("true".toParser() | "false".toParser()).map((value) => value == "true");

  ///
  /// @TODO check [intParser] and [doubleParser]
  ///
  Parser<int> intParser() =>
      ("0x".toParser() & (pattern("0-9A-Fa-f").times(4)) |
              (char("-").optional() & pattern("0-9").plus()))
          .flatten()
          .map(int.parse);

  Parser<double> doubleParser() =>
      ((_plainInt() & (char(".") & _plainInt()).optional()) |
              intParser().map((value) => "$value"))
          .flatten()
          .map(double.parse);

  Parser<dynamic> constantType() =>
      intParser() | doubleParser() | stringToken() | boolean();

  Parser<String> scalarDefinition() => (ref1(token, "scalar") &
              ref1(token, identifier()) &
              directiveValue().star())
          .map((value) => value[1])
          .map((value) {
        addScalarDefinition(value);
        return value;
      });

  Parser<GQSchema> schemaDefinition() => (ref1(token, "schema") &
              openBrace() &
              (schemaElement().repeat(0, 3)).map(GQSchema.fromList) &
              closeBrace())
          .map((value) {
        return value[2];
      }).map((value) {
        defineSchema(value);
        return value;
      });

  Parser<String> schemaElement() => (ref1(
              token,
              ["query", "mutation", "subscription"]
                  .map((e) => e.toParser())
                  .toChoiceParser()) &
          colon() &
          identifier())
      .map((value) => "${value[0]}-${value[2]}");

  Parser<GQFragmentField> fragmentField() {
    return (fragmentValue() | plainFragmentField()).cast<GQFragmentField>();
  }

  Parser<GQFragmentField> plainFragmentField() {
    late String name;
    String? alias;
    List<GQDirective>? directives;
    GQFragmentBlock? block;

    return (ref1(token, identifier().map((value) => name = value)) &
            (colon() &
                    identifier().map((value) {
                      alias = name;
                      name = value;
                    }))
                .optional() &
            directiveValue().star().map((value) => directives = value) &
            ref0(fragmentBlock).optional().map((value) => block = value))
        .map((value) {
      return GQFragmentField(
          name: name,
          alias: alias,
          block: block,
          isFragment: false,
          directiveList: directives ?? []);
    });
  }

  Parser<GQFragmentField> fragmentNameValue() {
    late String name;
    List<GQDirective>? directives;
    return (ref1(token, "...") &
            identifier().map((value) => name = value) &
            directiveValue().star().map((value) => directives = value))
        .map((value) => GQFragmentField(
            name: name,
            alias: null,
            isFragment: true,
            block: null,
            directiveList: directives ?? []));
  }

  Parser<GQFragmentField> inlineFragment() => (ref1(token, "...") &
          ref1(token, "on") &
          identifier() &
          directiveValue().star() &
          fragmentBlock())
      .map((value) => GQInlineFragment(value[2], value.last, value[3]));

  Parser<GQFragmentField> fragmentValue() =>
      (inlineFragment() | fragmentNameValue()).cast<GQFragmentField>();

  Parser<List<GQFragmentField>> fragmentFields() {
    return fragmentField().plus();
  }

  Parser<GQFragmentDefinition> fragmentDefinition() {
    late String name;
    late String onTypeName;
    late GQFragmentBlock block;

    List<GQDirective>? directives;

    return (ref1(token, "fragment") &
            identifier().map((value) => name = value) &
            ref1(token, "on") &
            identifier().map((value) => onTypeName = value) &
            directiveValue().star().map((value) => directives = value) &
            fragmentBlock().map((value) => block = value))
        .map((value) {
      return GQFragmentDefinition(name, onTypeName, block, directives ?? []);
    }).map((f) {
      addFragmentDefinition(f);
      return f;
    });
  }

  Parser<GQDefinition> parseUnion() {
    late final String name;
    final List<String> types = [];

    return (ref1(token, "union") &
            ref0(identifier).map((value) => name = value) &
            ref1(token, "=") &
            ref0(identifier).map(types.add) &
            (ref1(token, "|") & ref0(identifier).map(types.add)).star())
        .map((value) => GQDefinition(name, types))
        .map((value) {
      addUnionDefinition(value);
      return value;
    });
  }

  Parser<GQFragmentBlock> fragmentBlock() =>
      (openBrace() & ref0(fragmentFields) & closeBrace())
          .map((value) => GQFragmentBlock(value[1]));

  Parser<int> _plainInt() => pattern("0-9").plus().flatten().map(int.parse);

  Parser<GQDefinition> queryDefinition(GQQueryType type) {
    late String name;
    List<GQArgumentDefinition>? args;
    late List<GQQueryElement> elements;
    List<GQDirective>? directives;

    return (ref1(token, type.name) &
            identifier().map((value) => name = value) &
            arguments(parametrized: true).map((value) => args = value) &
            openBrace() &
            (type == GQQueryType.subscription
                    ? queryElement().map((value) => [value])
                    : queryElement().plus())
                .map((value) => elements = value) &
            closeBrace())
        .map(
      (_) => GQDefinition(
        name,
        directives ?? [],
        args ?? [],
        elements,
        type,
      ),
    )
        .map((value) {
      addQueryDefinition(value);
      return value;
    });
  }

  Parser<GQQueryElement> queryElement() {
    late String name;
    List<GQArgumentValue>? argValues;
    List<GQDirective>? directives;
    GQFragmentBlock? block;

    return (identifier().map((value) => name = value) &
            argumentValues().optional().map((value) => argValues = value) &
            directiveValue().star().map((value) => directives = value) &
            fragmentBlock().optional().map((value) => block = value))
        .map((_) =>
            GQQueryElement(name, directives ?? [], block, argValues ?? []));
  }
}
