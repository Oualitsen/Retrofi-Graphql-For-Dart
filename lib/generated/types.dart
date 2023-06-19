 import 'package:json_annotation/json_annotation.dart';
 import 'enums.dart';
  part 'types.g.dart';

@JsonSerializable()
      class Position_startTime {
          final int? startTime;
          
          Position_startTime({required this.startTime});
          
          factory Position_startTime.fromJson(Map<String, dynamic> json) => _$Position_startTimeFromJson(json);
          
          Map<String, dynamic> toJson() => _$Position_startTimeToJson(this);
      }
    

@JsonSerializable()
      class SavePositionResponse {
          final Position_startTime? savePosition;
          
          SavePositionResponse({required this.savePosition});
          
          factory SavePositionResponse.fromJson(Map<String, dynamic> json) => _$SavePositionResponseFromJson(json);
          
          Map<String, dynamic> toJson() => _$SavePositionResponseToJson(this);
      }
      

