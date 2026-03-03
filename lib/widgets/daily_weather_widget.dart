import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_icons/weather_icons.dart';
import '../models/weather_model.dart';

class DailyWeatherWidget extends StatelessWidget {
  final List<DailyWeather> daily;
  const DailyWeatherWidget({super.key, required this.daily});

  BoxedIcon getWeatherIcon(String condition, {double size = 30}) {
    condition = condition.toLowerCase();
    if (condition.contains("cloud")) return BoxedIcon(WeatherIcons.cloud, color: Colors.white, size: size);
    if (condition.contains("rain")) return BoxedIcon(WeatherIcons.rain, color: Colors.blueAccent, size: size);
    if (condition.contains("sun") || condition.contains("clear")) return BoxedIcon(WeatherIcons.day_sunny, color: Colors.yellowAccent, size: size);
    if (condition.contains("storm")) return BoxedIcon(WeatherIcons.thunderstorm, color: Colors.orangeAccent, size: size);
    if (condition.contains("snow")) return BoxedIcon(WeatherIcons.snow, color: Colors.white, size: size);
    return BoxedIcon(WeatherIcons.day_sunny, color: Colors.yellowAccent, size: size);
  }

  Widget glassCard({required Widget child, double radius = 25}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.white.withOpacity(0.12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: daily.map((day) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: glassCard(
            radius: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(day.day,
                    style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                getWeatherIcon(day.condition, size: 32),
                Text("${day.maxTemp.toStringAsFixed(0)}° / ${day.minTemp.toStringAsFixed(0)}°",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}