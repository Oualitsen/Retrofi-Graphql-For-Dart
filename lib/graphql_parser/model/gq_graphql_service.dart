import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:parser/graphql_parser/model/dart_serializable.dart';
import 'package:parser/graphql_parser/model/gq_argument.dart';
import 'package:parser/graphql_parser/model/gq_queries.dart';

class GQGraphqlService implements DartSerializable {
  final List<GQQueryDefinition> queries;

  GQGraphqlService(this.queries);

  @override
  String toDart(GraphQlGrammar grammar) {
    return """

    ${GQQueryType.values.map((e) => generateQueriesClassByType(e, grammar)).join("\n")}

    class GQClient {
      
       final queries = Queries();
       final mustations = Mutations();
       final subscriptions = Subscriptions();

}
    """
        .trim();
  }

  String generateQueriesClassByType(GQQueryType type, GraphQlGrammar g) {
    var queryList = queries.where((element) => element.type == type).toList();

    return """
      class ${classNameFromType(type)} {
        
        ${queryList.map((e) => queryToMethod(e, g)).join("\n")}

}

    """
        .trim();
  }

  String classNameFromType(GQQueryType type) {
    switch (type) {
      case GQQueryType.query:
        return "Queries";
      case GQQueryType.mutation:
        return "Mutations";
      case GQQueryType.subscription:
        return "Subscriptions";
    }
  }

  String queryToMethod(GQQueryDefinition def, GraphQlGrammar g) {
    return """
      ${returnTypeByQueryType(def, g)} ${def.token}(${generateArgs(def, g)}) {
        var operationName = "${def.token}";
        var fragments = \"\"\" ${def.fragments.map((e) => e.serialize()).toList().join(" ")} \"\"\";
        var q = \"\"\"
        ${def.serialize()} \$fragments
        \"\"\";

        var variables = {
          ${def.arguments.map((e) => "'${e.dartArgumentName}': ${serializeArgumentValue(g, def, e.token)}").toList().join(", ")}
        };
        
        return Future.value();
      }
    """
        .trim();
  }

  String serializeArgumentValue(
      GraphQlGrammar g, GQQueryDefinition def, String argName) {
    var arg = def.findByName(argName);
    String result = arg.dartArgumentName;
    if (g.inputTypeRequiresProjection(arg.type)) {
      return "$result.toJson()";
    } else {
      return result;
    }
  }

  String generateArgs(GQQueryDefinition def, GraphQlGrammar g) {
    if (def.arguments.isEmpty) {
      return "";
    }
    var result = def.arguments
        .map((e) => "${e.type.toDartType(g.typeMap)} ${e.dartArgumentName}")
        .map((e) => "required $e")
        .toList()
        .join(", ");
    return "{$result}";
  }

  String returnTypeByQueryType(GQQueryDefinition def, GraphQlGrammar g) {
    var gen = def.generate();

    if (def.type == GQQueryType.subscription) {
      return "Stream<${gen.token}>";
    }
    return "Future<${gen.token}>";
  }
}

class Service {
  static final queries = Queries();
}

class Queries {
  String getData() {
    return "Data";
  }
}

void main(List<String> args) {
  Service.queries.getData();
}