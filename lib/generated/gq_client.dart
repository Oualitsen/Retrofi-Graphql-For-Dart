import 'inputs.dart';
import 'types.dart';

class Queries {
  Future<GetProductsResponse> getProducts({required PageIndex pageIndex}) {
    return Future.value();
  }

  Future<GetAllProductsResponse> getAllProducts() {
    return Future.value();
  }
}

class Mutations {
  Future<CreateProductResponse> createProduct({required ProductInput input}) {
    return Future.value();
  }

  Future<DeleteProductResponse> deleteProduct(
      {required String id, required int? id2}) {
    return Future.value();
  }
}

class Subscriptions {}

class GQClient {
  static final queries = Queries();
  static final mustations = Mutations();
  static final subscriptions = Subscriptions();
}
