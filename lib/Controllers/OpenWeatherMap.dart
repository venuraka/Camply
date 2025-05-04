import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getWeatherDataFromLocationString(String locationString) async {
  final regex = RegExp(r'Latitude:\s*([-\d.]+),\s*Longitude:\s*([-\d.]+)');
  final match = regex.firstMatch(locationString);

  if (match == null) {
    throw Exception('Invalid location string format');
  }

  final lat = double.parse(match.group(1)!);
  final lon = double.parse(match.group(2)!);

  final apiKey = '88965e3bb8cfd7e9df3349b0c954f181';
  final url =
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&exclude=current&units=metric&appid=$apiKey';

  print("Fetching from: $url");

  final response = await http.get(Uri.parse(url));

  print("Status Code: ${response.statusCode}");
  print("Body: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load weather data');
  }
}