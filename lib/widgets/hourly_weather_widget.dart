import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_icons/weather_icons.dart';
import '../models/weather_model.dart';

class HourlyWeatherWidget extends StatelessWidget {
  final List<HourlyWeather> hourly;
  const HourlyWeatherWidget({super.key, required this.hourly});

  BoxedIcon getWeatherIcon(String condition, {double size = 32}) {
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
          padding: const EdgeInsets.all(8),
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
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final hour = hourly[index];
          return glassCard(
            radius: 25,
            child: SizedBox(
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(hour.time,
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                  getWeatherIcon(hour.condition, size: 32),
                  Text("${hour.temp.toStringAsFixed(0)}°",
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}