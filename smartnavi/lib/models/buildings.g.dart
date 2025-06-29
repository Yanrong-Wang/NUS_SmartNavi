// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buildings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Building _$BuildingFromJson(Map<String, dynamic> json) => _Building(
  roomName: json['roomName'] as String,
  location: Location.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BuildingToJson(_Building instance) => <String, dynamic>{
  'roomName': instance.roomName,
  'location': instance.location,
};
