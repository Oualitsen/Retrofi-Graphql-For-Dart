// ignore_for_file: camel_case_types

import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';
part 'types.g.dart';

@JsonSerializable()
class Brand_BrandFragment {
  final String name;

  final String country;

  Brand_BrandFragment({required this.name, required this.country});

  factory Brand_BrandFragment.fromJson(Map<String, dynamic> json) =>
      _$Brand_BrandFragmentFromJson(json);

  Map<String, dynamic> toJson() => _$Brand_BrandFragmentToJson(this);
}

@JsonSerializable()
class ProductFragment_on_Product {
  final String id;

  final String name;

  final double price;

  final Brand_BrandFragment brand;

  ProductFragment_on_Product(
      {required this.id,
      required this.name,
      required this.price,
      required this.brand});

  factory ProductFragment_on_Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFragment_on_ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductFragment_on_ProductToJson(this);
}

@JsonSerializable()
class BrandFragment_on_Brand {
  final String name;

  final String country;

  BrandFragment_on_Brand({required this.name, required this.country});

  factory BrandFragment_on_Brand.fromJson(Map<String, dynamic> json) =>
      _$BrandFragment_on_BrandFromJson(json);

  Map<String, dynamic> toJson() => _$BrandFragment_on_BrandToJson(this);
}

@JsonSerializable()
class Product_id_name_price_wasPrice {
  final String id;

  final String name;

  final double price;

  final double? wasPrice;

  Product_id_name_price_wasPrice(
      {required this.id,
      required this.name,
      required this.price,
      required this.wasPrice});

  factory Product_id_name_price_wasPrice.fromJson(Map<String, dynamic> json) =>
      _$Product_id_name_price_wasPriceFromJson(json);

  Map<String, dynamic> toJson() => _$Product_id_name_price_wasPriceToJson(this);
}

@JsonSerializable()
class Product_id_name {
  final String id;

  final String name;

  Product_id_name({required this.id, required this.name});

  factory Product_id_name.fromJson(Map<String, dynamic> json) =>
      _$Product_id_nameFromJson(json);

  Map<String, dynamic> toJson() => _$Product_id_nameToJson(this);
}

// ignore:
@JsonSerializable()
class Brand_BrandFragment_1 {
  final String name;

  final String country;

  Brand_BrandFragment_1({required this.name, required this.country});

  factory Brand_BrandFragment_1.fromJson(Map<String, dynamic> json) =>
      _$Brand_BrandFragment_1FromJson(json);

  Map<String, dynamic> toJson() => _$Brand_BrandFragment_1ToJson(this);
}

@JsonSerializable()
class Product_ProductFragment {
  final String id;

  final String name;

  final double price;

  final Brand_BrandFragment_1 brand;

  Product_ProductFragment(
      {required this.id,
      required this.name,
      required this.price,
      required this.brand});

  factory Product_ProductFragment.fromJson(Map<String, dynamic> json) =>
      _$Product_ProductFragmentFromJson(json);

  Map<String, dynamic> toJson() => _$Product_ProductFragmentToJson(this);
}

@JsonSerializable()
class Product_id_name_1 {
  final String id;

  final String name;

  Product_id_name_1({required this.id, required this.name});

  factory Product_id_name_1.fromJson(Map<String, dynamic> json) =>
      _$Product_id_name_1FromJson(json);

  Map<String, dynamic> toJson() => _$Product_id_name_1ToJson(this);
}

@JsonSerializable()
class GetProductsResponse {
  final List<Product_id_name_price_wasPrice> getProducts;

  final int getCount;

  GetProductsResponse({required this.getProducts, required this.getCount});

  factory GetProductsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetProductsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetProductsResponseToJson(this);
}

@JsonSerializable()
class GetAllProductsResponse {
  final List<Product_id_name> getAllProducts;

  GetAllProductsResponse({required this.getAllProducts});

  factory GetAllProductsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAllProductsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetAllProductsResponseToJson(this);
}

@JsonSerializable()
class CreateProductResponse {
  final Product_ProductFragment createProduct;

  CreateProductResponse({required this.createProduct});

  factory CreateProductResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateProductResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateProductResponseToJson(this);
}

@JsonSerializable()
class DeleteProductResponse {
  final Product_id_name_1 deleteProduct;

  final int? deleteProduct2;

  DeleteProductResponse(
      {required this.deleteProduct, required this.deleteProduct2});

  factory DeleteProductResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteProductResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteProductResponseToJson(this);
}
