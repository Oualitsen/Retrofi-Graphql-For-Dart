import 'inputs.dart';
import 'types.dart';

class Queries {
  Future<GetProductsResponse> getProducts({required PageIndex pageIndex}) {
    var operationName = "getProducts";
    var fragments = """  """;
    var q = """
        query getProducts (\$pageIndex: PageIndex!)  {
        getProducts (pageIndex: \$pageIndex) 
      {
      id  name  price  wasPrice 
    }

getCount  
      
      }
     $fragments
        """;

    var variables = {'pageIndex': pageIndex.toJson()};

    return Future.value();
  }

  Future<GetAllProductsResponse> getAllProducts() {
    var operationName = "getAllProducts";
    var fragments = """  """;
    var q = """
        query getAllProducts   {
        getAllProducts  
      {
      id  name 
    }
      }
     $fragments
        """;

    var variables = {};

    return Future.value();
  }
}

class Mutations {
  Future<CreateProductResponse> createProduct({required ProductInput input}) {
    var operationName = "createProduct";
    var fragments = """       fragment ProductFragment on Product  {
      id  name  price 
    } 
     """;
    var q = """
        mutation createProduct (\$input: ProductInput!)  {
        createProduct (input: \$input) 
      {
      ... ProductFragment 
    }
      }
     $fragments
        """;

    var variables = {'input': input.toJson()};

    return Future.value();
  }

  Future<DeleteProductResponse> deleteProduct(
      {required String id, required int? id2}) {
    var operationName = "deleteProduct";
    var fragments = """  """;
    var q = """
        mutation deleteProduct (\$id: ID!, \$id2: Int)  {
        deleteProduct (id: \$id) 
      {
      id  name 
    }

deleteProduct2 (id: \$id2) 
      
      }
     $fragments
        """;

    var variables = {'id': id, 'id2': id2};

    return Future.value();
  }
}

class Subscriptions {}

class GQClient {
  final queries = Queries();
  final mustations = Mutations();
  final subscriptions = Subscriptions();
}
