// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Brand_BrandFragment _$Brand_BrandFragmentFromJson(Map<String, dynamic> json) =>
    Brand_BrandFragment(
      name: json['name'] as String,
      country: json['country'] as String,
    );

Map<String, dynamic> _$Brand_BrandFragmentToJson(
        Brand_BrandFragment instance) =>
    <String, dynamic>{
      'name': instance.name,
      'country': instance.country,
    };

ProductFragment_on_Product _$ProductFragment_on_ProductFromJson(
        Map<String, dynamic> json) =>
    ProductFragment_on_Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      brand:
          Brand_BrandFragment.fromJson(json['brand'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductFragment_on_ProductToJson(
        ProductFragment_on_Product instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'brand': instance.brand,
    };

BrandFragment_on_Brand _$BrandFragment_on_BrandFromJson(
        Map<String, dynamic> json) =>
    BrandFragment_on_Brand(
      name: json['name'] as String,
      country: json['country'] as String,
    );

Map<String, dynamic> _$BrandFragment_on_BrandToJson(
        BrandFragment_on_Brand instance) =>
    <String, dynamic>{
      'name': instance.name,
      'country': instance.country,
    };

Product_id_name_price_wasPrice _$Product_id_name_price_wasPriceFromJson(
        Map<String, dynamic> json) =>
    Product_id_name_price_wasPrice(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      wasPrice: (json['wasPrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$Product_id_name_price_wasPriceToJson(
        Product_id_name_price_wasPrice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'wasPrice': instance.wasPrice,
    };

Product_id_name _$Product_id_nameFromJson(Map<String, dynamic> json) =>
    Product_id_name(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$Product_id_nameToJson(Product_id_name instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

Brand_BrandFragment_1 _$Brand_BrandFragment_1FromJson(
        Map<String, dynamic> json) =>
    Brand_BrandFragment_1(
      name: json['name'] as String,
      country: json['country'] as String,
    );

Map<String, dynamic> _$Brand_BrandFragment_1ToJson(
        Brand_BrandFragment_1 instance) =>
    <String, dynamic>{
      'name': instance.name,
      'country': instance.country,
    };

Product_ProductFragment _$Product_ProductFragmentFromJson(
        Map<String, dynamic> json) =>
    Product_ProductFragment(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      brand:
          Brand_BrandFragment_1.fromJson(json['brand'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$Product_ProductFragmentToJson(
        Product_ProductFragment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'brand': instance.brand,
    };

Product_id_name_1 _$Product_id_name_1FromJson(Map<String, dynamic> json) =>
    Product_id_name_1(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$Product_id_name_1ToJson(Product_id_name_1 instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

GetProductsResponse _$GetProductsResponseFromJson(Map<String, dynamic> json) =>
    GetProductsResponse(
      getProducts: (json['getProducts'] as List<dynamic>)
          .map((e) => Product_id_name_price_wasPrice.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      getCount: json['getCount'] as int,
    );

Map<String, dynamic> _$GetProductsResponseToJson(
        GetProductsResponse instance) =>
    <String, dynamic>{
      'getProducts': instance.getProducts,
      'getCount': instance.getCount,
    };

GetAllProductsResponse _$GetAllProductsResponseFromJson(
        Map<String, dynamic> json) =>
    GetAllProductsResponse(
      getAllProducts: (json['getAllProducts'] as List<dynamic>)
          .map((e) => Product_id_name.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetAllProductsResponseToJson(
        GetAllProductsResponse instance) =>
    <String, dynamic>{
      'getAllProducts': instance.getAllProducts,
    };

CreateProductResponse _$CreateProductResponseFromJson(
        Map<String, dynamic> json) =>
    CreateProductResponse(
      createProduct: Product_ProductFragment.fromJson(
          json['createProduct'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateProductResponseToJson(
        CreateProductResponse instance) =>
    <String, dynamic>{
      'createProduct': instance.createProduct,
    };

DeleteProductResponse _$DeleteProductResponseFromJson(
        Map<String, dynamic> json) =>
    DeleteProductResponse(
      deleteProduct: Product_id_name_1.fromJson(
          json['deleteProduct'] as Map<String, dynamic>),
      deleteProduct2: json['deleteProduct2'] as int?,
    );

Map<String, dynamic> _$DeleteProductResponseToJson(
        DeleteProductResponse instance) =>
    <String, dynamic>{
      'deleteProduct': instance.deleteProduct,
      'deleteProduct2': instance.deleteProduct2,
    };
