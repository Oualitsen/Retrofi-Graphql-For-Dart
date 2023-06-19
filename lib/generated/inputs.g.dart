// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inputs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageIndex _$PageIndexFromJson(Map<String, dynamic> json) => PageIndex(
      index: json['index'] as int,
      page: json['page'] as int,
    );

Map<String, dynamic> _$PageIndexToJson(PageIndex instance) => <String, dynamic>{
      'index': instance.index,
      'page': instance.page,
    };

ProductInput _$ProductInputFromJson(Map<String, dynamic> json) => ProductInput(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      wasPrice: (json['wasPrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProductInputToJson(ProductInput instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'wasPrice': instance.wasPrice,
    };
