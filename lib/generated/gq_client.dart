import 'enums.dart';
import 'inputs.dart';
import 'types.dart';
import 'dart:convert';
import 'package:parser/graphql_parser/model/gq_graphql_service.dart';

typedef GQHttpClientAdapter = Future<String> Function(String payload);

    class Queries {
        final GQHttpClientAdapter adapter;
        Queries(this.adapter);
        

}
class Mutations {
        final GQHttpClientAdapter adapter;
        Mutations(this.adapter);
        Future<SavePositionResponse> savePosition({required PositionInput input}) {
        var operationName = "savePosition";
        var fragments = """  """;
        var query = """
        mutation savePosition (\$input: PositionInput!)  {
        savePosition (position: \$input) 
      {
      startTime 
    }
      }
     $fragments
        """;

        var variables = {
          'input': input.toJson()
        };
        
        var payload = PayLoad(query: query, operationName: operationName, variables: variables);
        return adapter(payload.toString()).asStream().map((response) {
      Map<String, dynamic> result = jsonDecode(response);
      if (result.containsKey("errors")) {
        throw result["errors"];
      }
      var data = result["data"];
      return SavePositionResponse.fromJson(data);
      
    }).first;
        
      }

}
class Subscriptions {
        final GQHttpClientAdapter adapter;
        Subscriptions(this.adapter);
        

}

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
