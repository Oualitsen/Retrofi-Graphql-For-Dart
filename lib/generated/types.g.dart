// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Position_startTime _$Position_startTimeFromJson(Map<String, dynamic> json) =>
    Position_startTime(
      startTime: json['startTime'] as int?,
    );

Map<String, dynamic> _$Position_startTimeToJson(Position_startTime instance) =>
    <String, dynamic>{
      'startTime': instance.startTime,
    };

SavePositionResponse _$SavePositionResponseFromJson(
        Map<String, dynamic> json) =>
    SavePositionResponse(
      savePosition: json['savePosition'] == null
          ? null
          : Position_startTime.fromJson(
              json['savePosition'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SavePositionResponseToJson(
        SavePositionResponse instance) =>
    <String, dynamic>{
      'savePosition': instance.savePosition,
    };
