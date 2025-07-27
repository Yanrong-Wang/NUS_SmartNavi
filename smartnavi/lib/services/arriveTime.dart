import 'dart:convert';
import 'package:http/http.dart' as http;

Future<int?> getNextBusArrival(String busStopName, String busName) async {
  final url = Uri.parse(
    'https://nnextbus.nus.edu.sg/ShuttleService?busstopname=$busStopName',
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final shuttles = data['ShuttleServiceResult']?['shuttles'] as List?;
    if (shuttles != null && shuttles.isNotEmpty) {
      final bus = shuttles.firstWhere(
        (s) => s['name'] == busName,
        orElse: () => null,
      );
      String? arrivalStr = bus?['ts'];
      if (arrivalStr != null && arrivalStr.isNotEmpty) {
        final now = DateTime.now().toUtc();
        final eta = DateTime.tryParse(arrivalStr);
        if (eta != null) {
          final diff = eta.difference(now).inMinutes;
          return diff >= 0 ? diff : 0;
        }
      }
    }
  }
  return null;
}
