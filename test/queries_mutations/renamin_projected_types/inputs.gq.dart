  import 'package:json_annotation/json_annotation.dart';
  import 'enums.gq.dart';
  part 'inputs.gq.g.dart';

    @JsonSerializable()
      class PageIndex {
          final int index;

          
          PageIndex({required this.index, required this.page});
          
          factory PageIndex.fromJson(Map<String, dynamic> json) => _$PageIndexFromJson(json);
          
          Map<String, dynamic> toJson() => _$PageIndexToJson(this);
      }

    @JsonSerializable()
      class MyProductInput {
          final String name;


          
          MyProductInput({required this.name, required this.price, required this.wasPrice});
          
          factory MyProductInput.fromJson(Map<String, dynamic> json) => _$MyProductInputFromJson(json);
          
          Map<String, dynamic> toJson() => _$MyProductInputToJson(this);
      }
