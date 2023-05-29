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
    fillProjectedTypes();
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
    return seq3(
            openParen(),
            oneArgumentDefinition(parametrized: parametrized).star(),
            closeParen())
        .map3((p0, argsDefinition, p2) => argsDefinition);
  }

  Parser<List<GQArgumentValue>> argumentValues() {
    return seq3(openParen(), oneArgumentValue().star(), closeParen())
        .map3((p0, argValues, p2) => argValues);
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
    return seq4(
            seq2(ref1(token, "type"), ref0(identifier))
                .map2((_, identifier) => identifier),
            implementsToken().optional(),
            directiveValueList(),
            seq3(
              ref0(openBrace),
              fieldList(
                required: true,
                canBeInitialized: true,
                acceptsArguments: true,
              ),
              ref0(closeBrace),
            ).map3((p0, fields, p2) => fields))
        .map4((name, interfaceNames, directives, fields) {
      final type = GQTypeDefinition(
        name: name,
        fields: fields,
        interfaceNames: interfaceNames ?? {},
        directives: directives,
      );
      addTypeDefinition(type);
      return type;
    });
  }

  Parser<GQInputDefinition> inputDefinition() {
    return seq4(
            ref1(token, "input"),
            ref0(identifier),
            directiveValueList(),
            seq3(
                    ref0(openBrace),
                    fieldList(
                        required: true,
                        canBeInitialized: true,
                        acceptsArguments: false),
                    ref0(closeBrace))
                .map3((p0, fieldList, p2) => fieldList))
        .map4((_, name, directives, fields) {
      final input = GQInputDefinition(name: name, fields: fields);
      addInputDefinition(input);
      return input;
    });
  }

  Parser<GQField> field(
      {required bool canBeInitialized, required acceptsArguments}) {
    return ([
      ref0(documentation).optional(),
      identifier(),
      if (acceptsArguments) arguments().optional(),
      colon(),
      ref0(typeTokenDefinition),
      if (canBeInitialized) initialization().optional(),
      directiveValueList()
    ].toSequenceParser())
        .map((value) {
      String name = value[1] as String;

      String? fieldDocumentation = value[0] as String?;
      List<GQArgumentDefinition>? fieldArguments;
      Object? initialValue;

      if (acceptsArguments) {
        fieldArguments = value[2] as List<GQArgumentDefinition>?;
      } else {
        fieldArguments = null;
      }

      if (canBeInitialized) {
        initialValue = value[acceptsArguments ? 4 : 5];
      }

      GQType type = value[acceptsArguments ? 4 : 3] as GQType;
      List<GQDirectiveValue>? directives =
          value.last as List<GQDirectiveValue>?;

      return GQField(
        name: name,
        type: type,
        documentation: fieldDocumentation,
        arguments: fieldArguments ?? [],
        initialValue: initialValue,
        directives: directives,
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
    return seq4(
            seq2(ref1(token, "interface"), ref0(identifier))
                .map2((p0, interfaceName) => interfaceName),
            implementsToken().optional(),
            directiveValueList(),
            seq3(
                    ref0(openBrace),
                    fieldList(
                      required: true,
                      canBeInitialized: false,
                      acceptsArguments: false,
                    ),
                    ref0(closeBrace))
                .map3((p0, fieldList, p2) => fieldList))
        .map4((name, parentNames, directives, fieldList) {
      var interface = GQInterfaceDefinition(
          name: name,
          fields: fieldList,
          parentNames: parentNames ?? {},
          directives: directives.toSet());
      addInterfaceDefinition(interface);
      return interface;
    });
  }

  Parser enumDefinition() => (ref1(token, "enum") &
              ref0(identifier) &
              directiveValueList() &
              ref0(openBrace) &
              (ref1(token, documentation().optional()) &
                      ref1(token, identifier()))
                  .plus() &
              ref0(closeBrace))
          .map((value) {
        return value;
      });

  Parser<List<GQDirectiveValue>> directiveValueList() =>
      directiveValue().star();

  Parser<GQDirectiveValue> directiveValue() =>
      (directiveName() & ref1(token, argumentValues()).optional())
          .map((array) => GQDirectiveValue(array[0], [], array[1] ?? []));

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
          {bool parametrized = false}) =>
      (ref0(parametrized ? parametrizedArgument : identifier) &
              colon() &
              ref0(typeTokenDefinition) &
              initialization().optional())
          .map((array) => GQArgumentDefinition(array[1], array[2],
              initialValue: array.last));

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
    return seq2(
        ref1(token, identifier()),
        ref1(token, char("!")).optional().map((value) {
          return value == null;
        })).map2((name, nullable) {
      return GQType(name, nullable, isScalar: false);
    });
  }

  Parser<GQType> listTypeDefinition() => ((ref1(token, char('[')) &
                  simpleTypeTokenDefinition() &
                  ref1(token, char(']')))
              .map((value) => value[1]) &
          ref1(token, char("!")).optional().map((_) => true))
      .map((array) => GQListType(array[0], array[1] ?? true));

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

  Parser<Set<String>> implementsToken() {
    return seq2(ref1(token, "implements"), interfaceList())
        .map2((_, set) => set);
  }

  Parser<Set<String>> interfaceList() => (identifier() &
              (ref1(token, "&") & identifier()).map((value) => value[1]).star())
          .map((array) {
        Set<String> interfaceList = {array[0]};
        for (var value in array[1]) {
          final added = interfaceList.add(value);
          if (!added) {
            throw ParseException(
              "interface $value has been implemented more than once",
            );
          }
        }
        return interfaceList;
      });

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

  Parser<String> scalarDefinition() =>
      (ref1(token, "scalar") & ref1(token, identifier()) & directiveValueList())
          .map((array) {
        final scalarName = array[1];
        addScalarDefinition(scalarName);
        return scalarName;
      });

  Parser<GQSchema> schemaDefinition() {
    return seq4(ref1(token, "schema"), openBrace(),
            schemaElement().repeat(0, 3).map(GQSchema.fromList), closeBrace())
        .map4((p0, p1, schema, p3) {
      defineSchema(schema);
      return schema;
    });
  }

  Parser<String> schemaElement() {
    return seq3(
            ref1(
                token,
                ["query", "mutation", "subscription"]
                    .map((e) => e.toParser())
                    .toChoiceParser()),
            colon(),
            identifier())
        .map3((p0, p1, p2) => "$p0-$p2");
  }

  Parser<GQProjection> fragmentField() {
    return (fragmentValue() | plainFragmentField()).cast<GQProjection>();
  }

  Parser<GQProjection> plainFragmentField() {
    return seq4(
            ref1(token, identifier()),
            (seq2(colon(), identifier()).map2((_, alias) => alias)).optional(),
            directiveValueList(),
            ref0(() => fragmentBlock()).optional())
        .map4((name, alias, directiveList, block) => GQProjection(
              token: name,
              onTypeName: null,
              alias: alias,
              isFragmentReference: false,
              block: block,
              directives: directiveList,
            ));
  }

  Parser<GQProjection> fragmentNameValue() {
    return seq3(ref1(token, "..."), identifier(), directiveValueList()).map3(
      (_, name, directives) => GQProjection(
          onTypeName: null,
          token: name,
          alias: null,
          isFragmentReference: true,
          block: null,
          directives: directives),
    );
  }

  Parser<GQProjection> inlineFragment() {
    return seq3(
      ref1(token, "..."),
      ref1(token, "on"),
      seq3(identifier(), directiveValueList(), fragmentBlock()).map3(
        (typeName, directives, block) => GQProjection(
          token: '',
          onTypeName: typeName,
          alias: null,
          isFragmentReference: false,
          block: block,
          directives: directives,
        ),
      ),
    ).map3((p0, p1, projection) => projection);
  }

  Parser<GQProjection> fragmentValue() =>
      (inlineFragment() | fragmentNameValue()).cast<GQProjection>();

  Parser<List<GQProjection>> fragmentFields() {
    return fragmentField().plus();
  }

  Parser<GQFragmentDefinition> fragmentDefinition() {
    return seq4(
            seq3(
              ref1(token, "fragment"),
              identifier(),
              ref1(token, "on"),
            ).map3((p0, p1, p2) => p1),
            identifier(),
            directiveValueList(),
            fragmentBlock())
        .map4((name, typeName, directiveValues, block) =>
            GQFragmentDefinition(name, typeName, block, directiveValues))
        .map((f) {
      addFragmentDefinition(f);
      return f;
    });
  }

  Parser<GQUnionDefinition> unionDefinition() {
    return seq3(
            seq3(
              ref1(token, "union"),
              ref0(identifier),
              ref1(token, "="),
            ).map3((_, unionName, eq) => unionName),
            ref0(identifier),
            seq2(ref1(token, "|"), ref0(identifier))
                .map2((p0, p1) => p1)
                .star())
        .map3(
            (name, type1, types) => GQUnionDefinition(name, [type1, ...types]))
        .map((value) {
      addUnionDefinition(value);
      return value;
    });
  }

  Parser<GQFragmentBlockDefinition> fragmentBlock() {
    return seq3(openBrace(), ref0(() => fragmentFields()), closeBrace()).map3(
        (p0, projectionList, p2) => GQFragmentBlockDefinition(projectionList));
  }

  Parser<int> _plainInt() => pattern("0-9").plus().flatten().map(int.parse);

  Parser<GQDefinition> queryDefinition(GQQueryType type) {
    return seq4(
            seq2(
              ref1(token, type.name),
              identifier(),
            ).map2((p0, identifier) => identifier),
            arguments(parametrized: true).optional(),
            directiveValueList(),
            seq3(
                    openBrace(),
                    (type == GQQueryType.subscription
                        ? queryElement().map((value) => [value])
                        : queryElement().plus()),
                    closeBrace())
                .map3((p0, queryElements, p2) => queryElements))
        .map4(
      (name, args, directives, elements) => GQDefinition(
        name,
        directives,
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
    return seq4(identifier(), argumentValues().optional(), directiveValueList(),
            fragmentBlock().optional())
        .map4((name, args, directiveList, block) =>
            GQQueryElement(name, directiveList, block, args ?? []));
  }
}
