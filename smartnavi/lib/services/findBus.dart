import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class BusService {
  Map<String, dynamic>? _routesData;
  Map<String, List<String>>? _venueData;
  Future<void> loadData() async {
    if (_routesData != null) return;
    final String data = await rootBundle.loadString(
      'smartnavi/assets/pickupPoint.json',
    );
    if (_venueData != null) return;
    final String venueData = await rootBundle.loadString(
      'smartnavi/assets/buildings.json', // 修正为 buildings.json
    );
    final Map<String, dynamic> jsonData = json.decode(data);
    final Map<String, dynamic> venueJsonData = json.decode(venueData);
    _routesData = jsonData['PickupPointResult'] as Map<String, dynamic>;
    _venueData = venueJsonData['VenueResult'] as Map<String, List<String>>;
  }

  

  Future<List<Map<String, int>>> findVenueRoutes(
    String startVenue,
    String endVenue,
  ) async {
    await loadData();
    List<Map<String, int>> findBusRoutes(String startStop,String endStop){
      List<Map<String, int>> result = [];
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
            result.add({routeId: endIdx - startIdx});
          }
        }
      }
      return result;
  }
    List<Map<String, int>> result = [];
    List<String> startBus = _venueData[startVenue];
    List<Map<String, int>> findBusRoutes(String startStop, String endStop) {
    for (String start in startBus) {
      for (String end in endBus) {
        final routes = await findBusRoutes(start, end);
        result.addAll(routes);
      }
    }

    // 筛选：routeId 相同只保留 int 最小的
    Map<String, int> minMap = {};
    for (var map in result) {
      map.forEach((routeId, stationNum) {
        if (!minMap.containsKey(routeId) || stationNum < minMap[routeId]!) {
          minMap[routeId] = stationNum;
        }
      });
    }
    // 转回 List<Map<String, int>>
    List<Map<String, int>> filteredResult = minMap.entries
    final startBus = _venueData?[startVenue] ?? [];
    final endBus = _venueData?[endVenue] ?? [];

    return filteredResult;
  }
}

void main() async {
  final busService = BusService();
  await busService.loadData();
  final routes = busService.findBusRoutes('PGP', 'LT27');
  print('找到的路线: $routes');
}
