import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> fetchAndSaveBusStops() async {
  // 1. 请求 API 获取数据
  final url = 'https://nnextbus.nus.edu.sg/BusStops';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'accept': 'application/json',
      'Authorization':
          'Basic TlVTbmV4dGJ1czoxM2RMP3pZLDNmZVdSXiJU', // 替换为你的认证信息
    },
  );

  if (response.statusCode == 200) {
    // 2. 解析数据
    final data = jsonDecode(response.body);

    // 3. 写入本地 assets/busStop.json
    final file = File('smartnavi/assets/busStop.json');
    await file.writeAsString(jsonEncode(data), flush: true);

    print('busStop 数据已保存到 assets/busStop.json');
  } else {
    print('获取 busStop 数据失败: ${response.statusCode}');
    print(response.body);
  }
}

void main() {
  fetchAndSaveBusStops();
}
