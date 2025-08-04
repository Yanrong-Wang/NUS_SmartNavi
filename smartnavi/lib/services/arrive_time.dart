import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';

// 测试基础连接的函数
Future<void> testBasicConnection() async {
  try {
    // 使用http包测试基础连接
    final response = await http.get(
      Uri.parse('https://nnextbus.nus.edu.sg/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Basic TlVTbmV4dGJ1czoxM2RMP3pLDNmZvdSxiJU',
      },
    ).timeout(const Duration(seconds: 10));
    print('Base URL test - Status: ${response.statusCode}');
  } catch (e) {
    print('Base URL test failed: $e');
  }
}

Future<int?> getNextBusArrival(String busStopName, String busName) async {
  try {
    final url = Uri.parse('https://nnextbus.nus.edu.sg/ShuttleService?busstopname=$busStopName');
    
    print('=== API CALL START ===');
    print('Original stop name: $busStopName');
    print('Calling API: $url');
    print('Looking for bus: $busName');
    
    // 使用http包发送请求，包含授权头
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Basic TlVTbmV4dGJ1czoxM2RMP3pZLDNmZVdSXiJU',
      },
    ).timeout(const Duration(seconds: 15));
    
    print('API Response Status: ${response.statusCode}');
    print('Headers sent: Accept: application/json, Authorization: Basic TlVTbmV4dGJ1czoxM2RMP3pLDNmZvdSxiJU');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response Data: ${data.toString().substring(0, data.toString().length.clamp(0, 200))}...');
      
      final shuttles = data['ShuttleServiceResult']?['shuttles'] as List?;
      print('Found ${shuttles?.length ?? 0} shuttles');
      
      if (shuttles != null && shuttles.isNotEmpty) {
        print('Looking for bus: $busName');
        final bus = shuttles.firstWhere(
          (s) => s['name'] == busName,
          orElse: () => null,
        );
        
        if (bus != null) {
          print('Found bus $busName: ${bus.toString()}');
          
          // get all arrival times
          final etas = bus['_etas'] as List?;
          if (etas != null && etas.isNotEmpty) {
            final now = DateTime.now().toUtc();
            DateTime? closestFutureTime;
            int? closestMinutes;
            
            print('Processing ${etas.length} arrival times:');
            
            // iterate through all arrival times, find the closest future time
            for (int i = 0; i < etas.length; i++) {
              final etaData = etas[i];
              final arrivalStr = etaData['ts'] as String?;
              
              if (arrivalStr != null && arrivalStr.isNotEmpty) {
                final eta = DateTime.tryParse(arrivalStr);
                if (eta != null) {
                  final diff = eta.difference(now).inMinutes;
                  print('ETA ${i + 1}: $arrivalStr -> $diff minutes from now');
                  
                  // only consider future times (diff >= 0)
                  if (diff >= 0) {
                    if (closestFutureTime == null || eta.isBefore(closestFutureTime)) {
                      closestFutureTime = eta;
                      closestMinutes = diff;
                      print('Updated closest future time: $diff minutes');
                    }
                  } else {
                    print('Skipping past time: $diff minutes ago');
                  }
                }
              }
            }
            
            if (closestMinutes != null) {
              print('Final closest arrival time: $closestMinutes minutes');
              return closestMinutes;
            } else {
              print('No future arrival times found for bus $busName');
            }
          } else {
            print('No arrival time data found for bus $busName');
          }
        } else {
          print('Bus $busName not found in shuttles list');
          print('Available buses: ${shuttles.map((s) => s['name']).toList()}');
        }
      }
    } else {
      print('API call failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error in getNextBusArrival: $e');
    print('Error type: ${e.runtimeType}');
    print('Error details: ${e.toString()}');
  }
  print('=== API CALL END (FAILED) ===');
  return null;
}
