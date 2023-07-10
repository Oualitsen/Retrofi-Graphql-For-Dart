import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/dart_serializable.dart';
import 'package:retrofit_graphql/src/model/gq_directive.dart';
import 'package:retrofit_graphql/src/model/gq_field.dart';
import 'package:retrofit_graphql/src/model/gq_token.dart';
import 'package:retrofit_graphql/src/utils.dart';

class GQTypeDefinition extends GQTokenWithFields implements DartSerializable {
  final Set<String> interfaceNames;
  final List<GQDirectiveValue> directives;
  final bool nameDeclared;
  GQTypeDefinition? superClass;

  ///
  /// Used only when generating type for interfaces.
  /// This will be a super class of one or more base types.
  ///
  final Map<String, GQTypeDefinition> subTypes = {};

  String? _hash;

  List<GQField>? _myFields;
  List<GQField>? _commontFields;

  GQTypeDefinition({
    required String name,
    required this.nameDeclared,
    required List<GQField> fields,
    required this.interfaceNames,
    required this.directives,
  }) : super(name, fields) {
    fields.sort((f1, f2) => f1.name.compareTo(f2.name));
  }

  ///
  ///check is the two definitions will produce the same object structure
  ///
  bool isSimilarTo(GQTypeDefinition other, GQGrammar g) {
    return getHash(g) == other.getHash(g);
  }

  String getHash(GQGrammar grammar) {
    _hash ??= serializeFields(grammar);
    return _hash!;
  }

  @override
  String toString() {
    return 'GraphqlType{name: $token, fields: $fields, interfaceNames: $interfaceNames}';
  }

  @override
  String toDart(GQGrammar grammar) {
    return """
      @JsonSerializable()
      class $token ${_serializeSuperClass()}{
          ${serializeListText(getFields().map((e) => e.toDart(grammar)).toList(), join: "\n\r          ", withParenthesis: false)}
          
          $token(${serializeContructorArgs(grammar)})${_serializeCallToSuper(grammar)};
          
          factory $token.fromJson(Map<String, dynamic> json) => _\$${token}FromJson(json);
          
          Map<String, dynamic> toJson() => _\$${token}ToJson(this);
      }
    """;
  }

  String _serializeCallToSuper(GQGrammar grammar) {
    if (getCommonFields().isEmpty) {
      return "";
    }
    return ": super(${serializeListText(
      getCommonFields().map((e) => "${e.name}: ${e.name}").toList(),
      withParenthesis: false,
    )})";
  }

  List<GQField> getFields() {
    if (_myFields != null) {
      return _myFields!;
    }
    return [...fields, ...getCommonFields()];
  }

  List<GQField> getCommonFields() {
    if (_commontFields != null) {
      return _commontFields!;
    }

    if (subTypes.isNotEmpty) {
      //get the commont fields
      Set<GQField> commonFields = {};

      Map<GQField, int> occurenceMap = {};

      subTypes.forEach((key, typeDef) {
        for (var field in typeDef.fields) {
          if (occurenceMap.containsKey(field)) {
            occurenceMap[field] = occurenceMap[field]! + 1;
          } else {
            occurenceMap[field] = 1;
          }
        }
      });

      occurenceMap.forEach((key, value) {
        if (value > 1) {
          commonFields.add(key);
        }
      });
      _commontFields = commonFields.toList();
    } else {
      _commontFields = [];
    }
    return _commontFields!;
  }

  String _serializeSuperClass() {
    if (superClass == null) {
      return '';
    }
    return "extends ${superClass!.token} ";
  }

  String serializeFields(GQGrammar grammar) {
    return serializeListText(
        fields.map((e) => e.toDartNoFinal(grammar)).toList(),
        join: " ",
        withParenthesis: false);
  }

  String serializeContructorArgs(GQGrammar grammar) {
    if (fields.isEmpty) {
      return "";
    }
    String commonFields = getCommonFields()
        .map((e) => e.toDartMethodDeclaration(grammar))
        .join(", ");
    String nonCommonFields =
        fields.map((e) => e.name).map((e) => "required this.$e").join(", ");
    return "{${[nonCommonFields, commonFields].join(", ")}}";
  }

  @override
  String serialize() {
    throw UnimplementedError();
  }

  GQTypeDefinition clone(String newName) {
    return GQTypeDefinition(
      name: newName,
      nameDeclared: nameDeclared,
      fields: fields.toList(),
      interfaceNames: interfaceNames,
      directives: [],
    );
  }
}
