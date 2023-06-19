  import 'package:json_annotation/json_annotation.dart';

  part 'inputs.g.dart';

    @JsonSerializable()
      class PageIndex {
          final int index;

          
          PageIndex({required this.index, required this.page});
          
          factory PageIndex.fromJson(Map<String, dynamic> json) => _$PageIndexFromJson(json);
          
          Map<String, dynamic> toJson() => _$PageIndexToJson(this);
      }

    @JsonSerializable()
      class ProductInput {
          final String name;


          
          ProductInput({required this.name, required this.price, required this.wasPrice});
          
          factory ProductInput.fromJson(Map<String, dynamic> json) => _$ProductInputFromJson(json);
          
          Map<String, dynamic> toJson() => _$ProductInputToJson(this);
      }
