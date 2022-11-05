import 'package:parser/graphql_parser/excpetions/parse_exception.dart';
import 'package:parser/graphql_parser/model/gq_schema.dart';
import 'package:parser/graphql_parser/model/gq_argument.dart';
import 'package:parser/graphql_parser/model/gq_comment.dart';
import 'package:parser/graphql_parser/model/gq_directive.dart';
import 'package:parser/graphql_parser/gq_grammar_data_mixin.dart';
import 'package:parser/graphql_parser/model/gq_field.dart';
import 'package:parser/graphql_parser/model/gq_interface.dart';
import 'package:parser/graphql_parser/model/gq_type.dart';
import 'package:parser/graphql_parser/model/gq_input_type.dart';
import 'package:parser/graphql_parser/model/gq_fragment.dart';
import 'package:parser/graphql_parser/model/gq_queries.dart';
import 'package:parser/graphql_parser/model/gq_union.dart';
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

  // write the full grammar here

  Parser fullGrammar() => (documentation().optional() &
              [
                scalarDefinition(),
                directiveDefinition(),
                schemaDefinition(),
                inputDefinition(),
                typeDefinition(),
                interfaceDefinition(),
                fragmentDefinition(),
                enumDefinition(),
                unionDefinition(),
                queryDefinition(GQQueryType.query),
                queryDefinition(GQQueryType.mutation),
                queryDefinition(GQQueryType.subscription),
              ].toChoiceParser())
          .plus()
          .map((value) {
        _onDone();
        return value;
      });

  void _onDone() {
    updateFragmentDependencies();
    updateInterfaceParents();
    updateDirectives();
  }

  void updateInterfaceParents() {
    interfaces.forEach((key, value) {
      if (value.parentNames.isNotEmpty) {
        for (var interfaceName in value.parentNames) {
          var interface = interfaces[interfaceName];
          if (interface == null) {
            throw ParseException("interface $interfaceName is not defined");
          } else {
            value.parents.add(interface);
          }
        }
      }
    });
  }

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

  Parser<List<GQArgumentDefinition>> arguments({bool parametrized = false}) {
    late List<GQArgumentDefinition> list;
    return (openParen() &
            oneArgumentDefinition(parametrized: parametrized)
                .star()
                .map((value) => list = value) &
            closeParen())
        .map((value) => list);
  }

  Parser<List<GQArgumentValue>> argumentValues() {
    late List<GQArgumentValue> list;
    return (openParen() &
            oneArgumentValue().star().map((value) => list = value) &
            closeParen())
        .map((value) => list);
  }

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

  Parser<GQTypeDefinition> typeDefinition() {
    late String name;
    late Set<String> interfaceNames;
    late List<GQField> fields;
    return (ref1(token, "type") &
            ref0(identifier).map((value) => name = value) &
            implementsToken().optional().map((value) {
              interfaceNames = value ?? <String>{};
            }) &
            directiveValue().star() &
            ref0(openBrace) &
            fieldList(
              required: true,
              canBeInitialized: true,
              acceptsArguments: true,
            ).map((value) => fields = value) &
            ref0(closeBrace))
        .map((value) {
      final type = GQTypeDefinition(
        name: name,
        fields: fields,
        interfaceNames: interfaceNames,
      );
      addTypeDefinition(type);
      return type;
    });
  }

  Parser<GQInputDefinition> inputDefinition() {
    late String name;
    late List<GQField> fields;
    return (ref1(token, "input") &
            ref0(identifier).map((value) => name = value) &
            directiveValue().star() &
            ref0(openBrace) &
            fieldList(
                    required: true,
                    canBeInitialized: true,
                    acceptsArguments: false)
                .map((value) => fields = value) &
            ref0(closeBrace))
        .map((value) {
      final input = GQInputDefinition(name: name, fields: fields);
      addInputDefinition(input);
      return input;
    });
  }

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
      ref0(typeTokenDefinition).map((value) => type = value),
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
        initialValue: initialValue,
      );
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

  Parser<GQInterfaceDefinition> interfaceDefinition() {
    late String name;
    late List<GQField> fields;
    late Set<String> parentNames;
    return (ref1(token, "interface") &
            ref0(identifier).map((value) {
              name = value;
              return value;
            }) &
            implementsToken().optional().map((value) {
              parentNames = value ?? <String>{};
            }) &
            directiveValue().star() &
            ref0(openBrace) &
            fieldList(
              required: true,
              canBeInitialized: false,
              acceptsArguments: false,
            ).map((value) {
              fields = value;
              return value;
            }) &
            ref0(closeBrace))
        .map((value) {
      var interface = GQInterfaceDefinition(
        name: name,
        fields: fields,
        parentNames: parentNames,
      );
      addInterfaceDefinition(interface);
      return interface;
    });
  }

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

  Parser<GQDirectiveValue> directiveValue() {
    late String name;
    List<GQArgumentValue>? arguments;
    return (directiveName().map((value) => name = value) &
            ref1(token, argumentValues())
                .optional()
                .map((value) => arguments = value))
        .map((_) {
      return GQDirectiveValue(name, [], arguments ?? []);
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
            ref0(typeTokenDefinition).map((value) => type = value) &
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

  Parser<GQType> typeTokenDefinition() =>
      (ref0(simpleTypeTokenDefinition) | ref0(listTypeDefinition))
          .cast<GQType>();

  Parser<GQType> simpleTypeTokenDefinition() {
    late String name;
    bool nullable = true;
    return (ref1(token, identifier().map((value) => name = value)) &
            ref1(token, char("!")).optional().map((value) {
              nullable = value == null;
            }))
        .map((value) {
      return GQType(name, nullable, isScalar: false);
    });
  }

  Parser<GQType> listTypeDefinition() {
    bool nullable = true;
    late GQType type;
    return ((ref1(token, char('[')) &
                simpleTypeTokenDefinition().map((value) => type = value) &
                ref1(token, char(']'))) &
            ref1(token, char("!")).optional().map((value) => nullable = false))
        .map((value) {
      return GQListType(type, nullable);
    });
  }

  Parser complexType() => (openBrace() &
      (identifier() & colon() & (typeTokenDefinition() | ref0(complexType)))
          .star() &
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
  Parser<Set<String>> implementsToken() {
    late Set<String> set;
    return (ref1(token, "implements") &
            interfaceList().map((value) => set = value))
        .map((_) => set);
  }

  Parser<Set<String>> interfaceList() {
    late Set<String> interfaceList;
    return (identifier().map((value) {
              interfaceList = {value};
            }) &
            (ref1(token, "&") &
                    identifier().map((value) {
                      final added = interfaceList.add(value);
                      if (!added) {
                        throw ParseException(
                          "interface $value has been implemented more than once",
                        );
                      }
                    }))
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

  Parser<String> scalarDefinition() {
    late String scalarName;
    return (ref1(token, "scalar") &
            ref1(token, identifier()).map((value) => scalarName = value) &
            directiveValue().star())
        .map((_) {
      addScalarDefinition(scalarName);
      return scalarName;
    });
  }

  Parser<GQSchema> schemaDefinition() {
    late GQSchema schema;
    return (ref1(token, "schema") &
            openBrace() &
            (schemaElement().repeat(0, 3))
                .map(GQSchema.fromList)
                .map((value) => schema = value) &
            closeBrace())
        .map((value) {
      defineSchema(schema);
      return schema;
    });
  }

  Parser<String> schemaElement() {
    late String ident;
    late String tokenValue;
    return (ref1(
                    token,
                    ["query", "mutation", "subscription"]
                        .map((e) => e.toParser())
                        .toChoiceParser())
                .map((value) => tokenValue = value) &
            colon() &
            identifier().map((value) => ident = value))
        .map((value) => "$tokenValue-$ident");
  }

  Parser<GQProjection> fragmentField() {
    return (fragmentValue() | plainFragmentField()).cast<GQProjection>();
  }

  Parser<GQProjection> plainFragmentField() {
    late String name;
    String? alias;
    List<GQDirectiveValue>? directives;
    GQFragmentBlock? block;

    return (ref1(
                token,
                identifier().map((value) {
                  alias = null;
                  return name = value;
                })) &
            (colon() &
                    identifier().map((value) {
                      alias = name;
                      name = value;
                    }))
                .optional() &
            directiveValue().star().map((value) => directives = value) &
            ref0(fragmentBlock).optional().map((value) => block = value))
        .map((value) {
      return GQProjection(
          name: name,
          alias: alias,
          block: block,
          isFragment: false,
          directiveList: directives ?? []);
    });
  }

  Parser<GQProjection> fragmentNameValue() {
    late String name;
    List<GQDirectiveValue>? directives;
    return (ref1(token, "...") &
            identifier().map((value) => name = value) &
            directiveValue().star().map((value) => directives = value))
        .map((value) => GQProjection(
            name: name,
            alias: null,
            isFragment: true,
            block: null,
            directiveList: directives ?? []));
  }

  Parser<GQProjection> inlineFragment() {
    late String name;
    late GQFragmentBlock block;
    late List<GQDirectiveValue> directiveValues;
    return (ref1(token, "...") &
            ref1(token, "on") &
            identifier().map((value) => name = value) &
            directiveValue().star().map((value) => directiveValues = value) &
            fragmentBlock().map((value) => block = value))
        .map((value) =>
            GQInlineFragmentDefinition(name, block, directiveValues));
  }

  Parser<GQProjection> fragmentValue() =>
      (inlineFragment() | fragmentNameValue()).cast<GQProjection>();

  Parser<List<GQProjection>> fragmentFields() {
    return fragmentField().plus();
  }

  Parser<GQFragmentDefinition> fragmentDefinition() {
    late String name;
    late String onTypeName;
    late GQFragmentBlock block;

    List<GQDirectiveValue>? directives;

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

  Parser<GQUnionDefinition> unionDefinition() {
    late final String name;
    final List<String> types = [];

    return (ref1(token, "union") &
            ref0(identifier).map((value) => name = value) &
            ref1(token, "=") &
            ref0(identifier).map(types.add) &
            (ref1(token, "|") & ref0(identifier).map(types.add)).star())
        .map((value) => GQUnionDefinition(name, types))
        .map((value) {
      addUnionDefinition(value);
      return value;
    });
  }

  Parser<GQFragmentBlock> fragmentBlock() {
    late List<GQProjection> fields;
    return (openBrace() &
            ref0(fragmentFields).map((value) => fields = value) &
            closeBrace())
        .map((value) => GQFragmentBlock(fields));
  }

  Parser<int> _plainInt() => pattern("0-9").plus().flatten().map(int.parse);

  Parser<GQDefinition> queryDefinition(GQQueryType type) {
    late String name;
    List<GQArgumentDefinition>? args;
    late List<GQQueryElement> elements;
    List<GQDirectiveValue>? directives;

    return (ref1(token, type.name) &
            identifier().map((value) => name = value) &
            arguments(parametrized: true)
                .optional()
                .map((value) => args = value ?? []) &
            directiveValue().star().map((value) => directives = value) &
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
    List<GQDirectiveValue>? directives;
    GQFragmentBlock? block;

    return (identifier().map((value) => name = value) &
            argumentValues().optional().map((value) => argValues = value) &
            directiveValue().star().map((value) => directives = value) &
            fragmentBlock().optional().map((value) => block = value))
        .map((_) =>
            GQQueryElement(name, directives ?? [], block, argValues ?? []));
  }
}
