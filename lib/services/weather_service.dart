import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey = "b616c9ba3f3ae4a5ab3c944c6226b5e2";

  Future<Weather> fetchWeather(String city) async {
    final currentUrl =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";
    final forecastUrl =
        "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric";

    final currentRes = await http.get(Uri.parse(currentUrl));
    final forecastRes = await http.get(Uri.parse(forecastUrl));

    if (currentRes.statusCode == 200 && forecastRes.statusCode == 200) {
      final currentData = jsonDecode(currentRes.body);
      final forecastData = jsonDecode(forecastRes.body);

      // Hourly (next 12 hours)
      List<HourlyWeather> hourly = (forecastData['list'] as List)
          .take(12)
          .map((e) => HourlyWeather(
        time: DateFormat.Hm()
            .format(DateTime.fromMillisecondsSinceEpoch(e['dt'] * 1000)),
        temp: (e['main']['temp'] as num).toDouble(),
        condition: e['weather'][0]['main'],
      ))
          .toList();

      // Group forecast by day
      Map<String, List<dynamic>> grouped = {};
      for (var item in forecastData['list']) {
        String date = item['dt_txt'].split(" ")[0];
        grouped.putIfAbsent(date, () => []);
        grouped[date]!.add(item);
      }

      // Daily (next 7 days)
      List<DailyWeather> daily = grouped.entries.take(7).map((entry) {
        var dayData = entry.value;

        double max = (dayData
            .map((e) => (e['main']['temp_max'] as num))
            .reduce((a, b) => a > b ? a : b))
            .toDouble();
        double min = (dayData
            .map((e) => (e['main']['temp_min'] as num))
            .reduce((a, b) => a < b ? a : b))
            .toDouble();

        String condition = dayData[0]['weather'][0]['main'];

        return DailyWeather(
          day: DateFormat.E().format(DateTime.parse(entry.key)),
          maxTemp: max,
          minTemp: min,
          condition: condition,
        );
      }).toList();

      return Weather(
        cityName: currentData['name'] ?? "Unknown",
        temp: (currentData['main']['temp'] as num).toDouble(),
        condition: currentData['weather'][0]['main'] ?? "Clear",
        humidity: currentData['main']['humidity'] ?? 0,
        windSpeed: (currentData['wind']['speed'] as num?)?.toDouble() ?? 0.0,
        visibility: currentData['visibility'] ?? 0,
        sunrise: currentData['sys']?['sunrise'] ?? 0,
        sunset: currentData['sys']?['sunset'] ?? 0,
        pressure: currentData['main']?['pressure'] ?? 0,
        hourly: hourly,
        daily: daily,
      );
    } else {
      throw Exception("City not found or API error");
    }
  }
}