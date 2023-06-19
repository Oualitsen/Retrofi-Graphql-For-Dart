import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:parser/generated/gq_client.dart';
import 'package:parser/graphql_parser/model/gq_graphql_service.dart';

void main() {
  PayLoad payLoad = PayLoad(
    operationName: "savePosition",
    query:
        "mutation savePosition(\$a: String, \$b:Long){\n  savePosition(position:{designation:\$a startTime:\$b endTime :45}){\n    startTime\n  }\n}",
    variables: {'a': 'pooo', 'b': '12'},
  );
  var url1 = Uri.http('localhost:8080', '/graphql');
  print("url $url1");
  http.post(url1,
      body: jsonEncode(payLoad.toJson()),
      headers: {"Content-Type": "application/json"}).then((response) {
    print("object ${response.request?.url}");
    if (response.statusCode == 200) {
      print("###### reponse.body = ${response.body}");
      // var jsonResponse =
      //     convert.jsonDecode(response.body) as Map<String, dynamic>;
      // var itemCount = jsonResponse['totalItems'];
      // print('Number of books about http: $itemCount.');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  });

  var c = GQClient((text) => http
      .post(Uri.http('localhost:8080', '/graphql'),
          body: jsonEncode(payLoad),
          headers: {"Content-Type": "application/json"})
      .asStream()
      .map((event) => event.body)
      .first);
}
