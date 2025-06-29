import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:smartnavi/models/location.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'buildings.freezed.dart';
part 'buildings.g.dart';

@freezed
sealed class Building with _$Building {
  const Building._();
  const factory Building({
    required String roomName,
    required Location location,
  }) = _Building;

  factory Building.fromJson(Map<String, dynamic> json) =>
      _$BuildingFromJson(json);
  static Future<Map<String, Building>> get buildings async {
    final String jsonString = await rootBundle.loadString(
      'assets/buildings.json',
    );
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap.map(
      (key, value) =>
          MapEntry(key, Building.fromJson(value as Map<String, dynamic>)),
    );
  }
}
