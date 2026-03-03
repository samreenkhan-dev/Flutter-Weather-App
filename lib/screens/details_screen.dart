import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  // Convert UNIX timestamp to readable time
  String formatTime(int? timestamp) {
    if (timestamp == null) return "-";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}";
  }

  BoxedIcon getWeatherIcon(String condition, {double size = 30}) {
    condition = condition.toLowerCase();
    if (condition.contains("cloud")) return BoxedIcon(WeatherIcons.cloud, size: size, color: Colors.white);
    if (condition.contains("rain")) return BoxedIcon(WeatherIcons.rain, size: size, color: Colors.blueAccent);
    if (condition.contains("sun") || condition.contains("clear")) return BoxedIcon(WeatherIcons.day_sunny, size: size, color: Colors.yellowAccent);
    if (condition.contains("storm")) return BoxedIcon(WeatherIcons.thunderstorm, size: size, color: Colors.orangeAccent);
    if (condition.contains("snow")) return BoxedIcon(WeatherIcons.snow, size: size, color: Colors.white);
    return BoxedIcon(WeatherIcons.day_sunny, size: size, color: Colors.yellowAccent);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);
    final weather = provider.weather;

    if (weather == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Details")),
        body: const Center(child: Text("No data available")),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF141E30), Color(0xFF243B55), Color(0xFF1B2735)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button + title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white)),
                    Text("${weather.cityName} Details",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 20),

                // Weather Stats
                glassCard(
                  radius: 25,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statColumn(Icons.thermostat, "${weather.temp.toStringAsFixed(0)}°", "Temp"),
                        _statColumn(Icons.water_drop, "${weather.humidity}%", "Humidity"),
                        _statColumn(Icons.air, "${weather.windSpeed} km/h", "Wind"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                glassCard(
                  radius: 25,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statColumn(Icons.visibility, "${weather.visibility ?? '-'} m", "Visibility"),
                        _statColumn(Icons.wb_sunny_outlined, formatTime(weather.sunrise), "Sunrise"),
                        _statColumn(Icons.nights_stay_outlined, formatTime(weather.sunset), "Sunset"),
                        _statColumn(Icons.speed, "${weather.pressure ?? '-'} hPa", "Pressure"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 7-Day Forecast Title
                Text("7-Day Forecast",
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // 7-Day Forecast List
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weather.daily.length,
                    itemBuilder: (context, index) {
                      final day = weather.daily[index];
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: glassCard(
                          radius: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(day.day,
                                    style: GoogleFonts.poppins(color: Colors.white70)),
                                const SizedBox(height: 8),
                                getWeatherIcon(day.condition),
                                const SizedBox(height: 8),
                                Text("${day.maxTemp.toStringAsFixed(0)}° / ${day.minTemp.toStringAsFixed(0)}°",
                                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Text(day.condition, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Temperature Graph
                Text("Temperature Graph",
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                glassCard(
                  radius: 25,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < weather.daily.length) {
                                    return Text(
                                      weather.daily[index].day.substring(0, 3),
                                      style: const TextStyle(color: Colors.white70),
                                    );
                                  }
                                  return const Text("");
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 5,
                                getTitlesWidget: (value, meta) {
                                  return Text("${value.toInt()}°",
                                      style: const TextStyle(color: Colors.white70, fontSize: 12));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                weather.daily.length,
                                    (index) => FlSpot(index.toDouble(), weather.daily[index].maxTemp),
                              ),
                              isCurved: true,
                              color: Colors.yellowAccent,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Glass card widget
  Widget glassCard({required Widget child, double radius = 25}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  // Stat column
  Column _statColumn(IconData icon, String value, String title) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 5),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}