import 'dart:convert';

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
import 'dart:convert';
import 'package:parser/graphql_parser/model/gq_graphql_service.dart';

typedef GQHttpClientAdapter = Future<String> Function(String payload);

    ${GQQueryType.values.map((e) => generateQueriesClassByType(e, grammar)).join("\n")}

class GQClient {
  final GQHttpClientAdapter adapter;
  late final Queries queries;
  late final Mutations mutations;
  late final Subscriptions subscriptions;
  GQClient(this.adapter) {
    queries = Queries(adapter);
    mutations = Mutations(adapter);
    subscriptions = Subscriptions(adapter);
  }
}

    """
        .trim();
  }

  String generateQueriesClassByType(GQQueryType type, GraphQlGrammar g) {
    var queryList = queries.where((element) => element.type == type).toList();

    return """
      class ${classNameFromType(type)} {
        final GQHttpClientAdapter adapter;
        ${classNameFromType(type)}(this.adapter);
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
        var query = \"\"\"
        ${def.serialize()} \$fragments
        \"\"\";

        var variables = {
          ${def.arguments.map((e) => "'${e.dartArgumentName}': ${serializeArgumentValue(g, def, e.token)}").toList().join(", ")}
        };
        
        var payload = PayLoad(query: query, operationName: operationName, variables: variables);
        return adapter(payload.toString()).asStream().map((response) {
      Map<String, dynamic> result = jsonDecode(response);
      if (result.containsKey("errors")) {
        throw result["errors"];
      }
      var data = result["data"];
      return ${def.generate().token}.fromJson(data);
      
    }).first;
        
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

class PayLoad {
  final String query;
  final Map<dynamic, dynamic> variables;
  final String operationName;
  PayLoad({
    required this.query,
    required this.operationName,
    required this.variables,
  });
  Map<String, dynamic> toJson() =>
      {'operationName': operationName, 'variables': variables, 'query': query};

  @override
  String toString() => jsonEncode(toJson());
}
