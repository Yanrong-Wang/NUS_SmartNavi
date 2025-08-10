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

Future<String?> getNextBusArrival(String busStopName, String busName) async {
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
          // API返回的arrivalTime是String格式
          final arrivalTime = bus["arrivalTime"];
          if (arrivalTime != null) {
            return arrivalTime.toString();
          }
          print('arrivalTime is null');
          return null;
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
