import 'enums.dart';
import 'inputs.dart';
import 'types.dart';
import 'dart:convert';
import 'package:parser/graphql_parser/model/gq_graphql_service.dart';

typedef GQHttpClientAdapter = Future<String> Function(String payload);

    class Queries {
        final GQHttpClientAdapter adapter;
        Queries(this.adapter);
        Future<GetProductsResponse> getProducts({required PageIndex pageIndex}) {
        var operationName = "getProducts";
        var fragments = """  """;
        var query = """
        query getProducts (\$pageIndex: PageIndex!)  {
        getProducts (pageIndex: \$pageIndex) 
      {
      id  name  price  wasPrice 
    }
getCount  
      
      }
     $fragments
        """;

        var variables = {
          'pageIndex': pageIndex.toJson()
        };
        
        var payload = PayLoad(query: query, operationName: operationName, variables: variables);
        return adapter(payload.toString()).asStream().map((response) {
      Map<String, dynamic> result = jsonDecode(response);
      if (result.containsKey("errors")) {
        throw result["errors"];
      }
      var data = result["data"];
      return GetProductsResponse.fromJson(data);
      
    }).first;
        
      }
Future<GetAllProductsResponse> getAllProducts() {
        var operationName = "getAllProducts";
        var fragments = """  """;
        var query = """
        query getAllProducts   {
        getAllProducts  
      {
      id  name 
    }
      }
     $fragments
        """;

        var variables = {
          
        };
        
        var payload = PayLoad(query: query, operationName: operationName, variables: variables);
        return adapter(payload.toString()).asStream().map((response) {
      Map<String, dynamic> result = jsonDecode(response);
      if (result.containsKey("errors")) {
        throw result["errors"];
      }
      var data = result["data"];
      return GetAllProductsResponse.fromJson(data);
      
    }).first;
        
      }

}
class Mutations {
        final GQHttpClientAdapter adapter;
        Mutations(this.adapter);
        Future<CreateProductResponse> createProduct({required ProductInput input}) {
        var operationName = "createProduct";
        var fragments = """       fragment ProductFragment on Product  {
      id  name  price  brand {
      ... BrandFragment 
    }
    } 
           fragment BrandFragment on Brand  {
      name  country 
    } 
     """;
        var query = """
        mutation createProduct (\$input: ProductInput!)  {
        createProduct (input: \$input) 
      {
      ... ProductFragment 
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
      return CreateProductResponse.fromJson(data);
      
    }).first;
        
      }
Future<DeleteProductResponse> deleteProduct({required String id, required int? id2}) {
        var operationName = "deleteProduct";
        var fragments = """  """;
        var query = """
        mutation deleteProduct (\$id: ID!, \$id2: Int)  {
        deleteProduct (id: \$id) 
      {
      id  name 
    }
deleteProduct2 (id: \$id2) 
      
      }
     $fragments
        """;

        var variables = {
          'id': id, 'id2': id2
        };
        
        var payload = PayLoad(query: query, operationName: operationName, variables: variables);
        return adapter(payload.toString()).asStream().map((response) {
      Map<String, dynamic> result = jsonDecode(response);
      if (result.containsKey("errors")) {
        throw result["errors"];
      }
      var data = result["data"];
      return DeleteProductResponse.fromJson(data);
      
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
