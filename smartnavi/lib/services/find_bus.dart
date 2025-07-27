import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class BusService {
  Map<String, dynamic>? _routesData;
  Future<void> loadData() async {
    if (_routesData != null) return;
    final String data = await rootBundle.loadString(
      'smartnavi/assets/pickupPoint.json',
    );
    final Map<String, dynamic> jsonData = json.decode(data);
    _routesData = jsonData['PickupPointResult'] as Map<String, dynamic>;
  }

  Future<List<String>> findBusRoutes(String startStop, String endStop) async {
    await loadData();
    List<String> result = [];
    if (_routesData == null) return result;
    for (var entry in _routesData!.entries) {
      final routeId = entry.key;
      final stops = entry.value;
      if (stops is List) {
        final startIdx = stops.indexWhere(
          (stop) => stop['ShortName'] == startStop,
        );
        final endIdx = stops.indexWhere((stop) => stop['ShortName'] == endStop);
        if (startIdx != -1 && endIdx != -1 && startIdx < endIdx) {
          result.add(routeId);
        }
      }
    }
    return result;
  }
}

void main() async {
  final busService = BusService();
  final routes = await busService.findBusRoutes('PGP', 'LT27');
  print('找到的路线: $routes');
}
