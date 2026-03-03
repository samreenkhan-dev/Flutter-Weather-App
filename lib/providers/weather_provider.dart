import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  Weather? weather;
  bool isLoading = false;
  String error = "";

  Future<void> getWeather(String city) async {
    isLoading = true;
    error = "";
    notifyListeners();

    try {
      weather = await WeatherService().fetchWeather(city);
    } catch (e) {
      weather = null;
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}