import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'arrive_time.dart';

// Define a route result with details about the bus route
class RouteResult {
  final String routeId;
  final int stops;
  final String startStop;
  final String endStop;
  final int? arrivalTime; // Added to store bus arrival time

  RouteResult({
    required this.routeId,
    required this.stops,
    required this.startStop,
    required this.endStop,
    this.arrivalTime, // Optional arrival time
  });

  // Helper method to create a copy with updated values
  RouteResult copyWith({
    String? routeId,
    int? stops,
    String? startStop,
    String? endStop,
    int? arrivalTime,
  }) {
    return RouteResult(
      routeId: routeId ?? this.routeId,
      stops: stops ?? this.stops,
      startStop: startStop ?? this.startStop,
      endStop: endStop ?? this.endStop,
      arrivalTime: arrivalTime, // Allow setting it to null
    );
  }
}

class BusService {
  Map<String, dynamic>? _routesData;
  Map<String, List<String>>? _venueData;
  
  Future<void> loadData() async {
    if (_routesData != null && _venueData != null) return;
    
    try {
      // Loading pickupPoint.json
      final String data = await rootBundle.loadString('assets/pickupPoint.json');
      final Map<String, dynamic> jsonData = json.decode(data);
      
      // Loading venues.json
      final String venueData = await rootBundle.loadString('assets/venues.json');
      final Map<String, dynamic> venueJsonData = json.decode(venueData);
      
      // Check if the JSON structure contains the expected keys
      if (jsonData.containsKey('PickupPointResult')) {
        _routesData = jsonData['PickupPointResult'] as Map<String, dynamic>;
      } else {
        _routesData = jsonData; 
      }
      
      if (venueJsonData.containsKey('VenueResult')) {
        _venueData = Map<String, List<String>>.from(
          venueJsonData['VenueResult'].map((key, value) => 
            MapEntry(key, List<String>.from(value))
          )
        );
      } else {
        _venueData = Map<String, List<String>>.from(
          venueJsonData.map((key, value) => 
            MapEntry(key, List<String>.from(value))
          )
        );
      }
      
      print('Loaded routes data: ${_routesData?.keys.length} routes');
      print('Loaded venue data: ${_venueData?.keys.length} venues');
      
    } catch (e) {
      print('Error loading data: $e');
      _routesData = <String, dynamic>{};
      _venueData = <String, List<String>>{};
    }
  }

  // Find routes between two venues
  Future<List<RouteResult>> findVenueRoutes(
    String startVenue,
    String endVenue,
  ) async {
    await loadData();
    
    List<String> startBus = [];
    List<String> endBus = [];
    
    if (_routesData != null && _venueData != null) {
      startBus = _venueData![startVenue] ?? [];
      endBus = _venueData![endVenue] ?? [];
      
      print('Start venue: $startVenue -> Bus stops: $startBus');
      print('End venue: $endVenue -> Bus stops: $endBus');
      
      if (startBus.isNotEmpty && endBus.isNotEmpty) {
        print('=== SEARCHING FOR ROUTES ===');
        
        // Define routeResults Map
        Map<String, RouteResult> routeResults = {};
        
        for (String start in startBus) {
          for (String end in endBus) {
            print('Checking: $start -> $end');
            
            for (var entry in _routesData!.entries) {
              final routeId = entry.key;
              final stops = entry.value;
              
              if (stops is List) {
                int startIdx = -1;
                int endIdx = -1;
                
                for (int i = 0; i < stops.length; i++) {
                  final stop = stops[i];
                  if (stop is Map) {
                    final busstopcode = stop['busstopcode']?.toString();
                    
                    if (busstopcode == start) {
                      startIdx = i;
                    }
                    if (busstopcode == end) {
                      endIdx = i;
                    }
                  }
                }
                
                if (startIdx != -1 && endIdx != -1 && startIdx < endIdx) {
                  final stopsCount = endIdx - startIdx;
                  print('Route $routeId: $start(idx:$startIdx) -> $end(idx:$endIdx) = $stopsCount stops');
                  
                  // Keep the minimum stops for each route
                  if (!routeResults.containsKey(routeId) || 
                      stopsCount < routeResults[routeId]!.stops) {
                    routeResults[routeId] = RouteResult(
                      routeId: routeId,
                      stops: stopsCount,
                      startStop: start,   
                      endStop: end,        
                    );
                  }
                }
              }
            }
          }
        }
        
        // --- Fetch Arrival Times ---
        List<Future<RouteResult>> arrivalTimeFutures = [];

        for (var routeResult in routeResults.values) {
            // Find the start stop name from _routesData
            String? startStopName;
            final routeStops = _routesData![routeResult.routeId];
            if (routeStops is List) {
                for (final stop in routeStops) {
                    if (stop is Map && stop['busstopcode'] == routeResult.startStop) {
                        startStopName = stop['busstopcode'];
                        break;
                    }
                }
            }

            if (startStopName != null) {
                print('Fetching arrival time for ${routeResult.routeId} at $startStopName');
                final future = getNextBusArrival(startStopName, routeResult.routeId)
                    .then((arrivalTime) {
                      print('Arrival time result for ${routeResult.routeId}: $arrivalTime minutes');
                      return routeResult.copyWith(arrivalTime: arrivalTime);
                    });
                arrivalTimeFutures.add(future);
            } else {
                print('No pickup name found for route ${routeResult.routeId} with start stop ${routeResult.startStop}');
                // If name not found, add original result back
                arrivalTimeFutures.add(Future.value(routeResult));
            }
        }

        List<RouteResult> resultWithArrivals = await Future.wait(arrivalTimeFutures);
        resultWithArrivals.sort((a, b) => a.stops.compareTo(b.stops));

        print('\n ROUTE SEARCH RESULTS');
        if (resultWithArrivals.isNotEmpty) {
          print('Found ${resultWithArrivals.length} available route(s):');
          for (int i = 0; i < resultWithArrivals.length; i++) {
            final route = resultWithArrivals[i];
            final arrivalText = route.arrivalTime != null ? '${route.arrivalTime} min' : 'N/A';
            print('${i + 1}. Route ${route.routeId}: ${route.startStop} -> ${route.endStop} (${route.stops} stops) - Arrival: $arrivalText');
          }
        } else {
          print('No direct bus routes found.');
        }
        print('================================');
        
        return resultWithArrivals;
      }
    }
    
    print('No direct bus routes found.');
    return [];
  }
}
