import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_icons/weather_icons.dart';
import '../providers/weather_provider.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController(text: "Lahore");

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<WeatherProvider>(context, listen: false).getWeather(_controller.text);
    });
  }

  // Weather Icon based on condition
  BoxedIcon getWeatherIcon(String condition, {double size = 80}) {
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF141E30),
              Color(0xFF243B55),
              Color(0xFF1B2735),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : provider.error.isNotEmpty
              ? Center(child: Text(provider.error, style: const TextStyle(color: Colors.white)))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search city...",
                          hintStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                        ),
                        onSubmitted: (value) => provider.getWeather(value),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

               Text(
                  weather!.cityName,
                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                  const SizedBox(height: 8), // Weather Icon
                  getWeatherIcon(weather.condition, size: 100),
                  const SizedBox(height: 8),

                  // Temperature
                  Text(
                    "${weather.temp.toStringAsFixed(0)}°",
                    style: GoogleFonts.poppins(
                      fontSize: 65,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Colors.white, Colors.blueAccent],
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                  ),

                  // Condition
                  Text(weather.condition, style: GoogleFonts.poppins(fontSize: 20, color: Colors.white70)),
                 const SizedBox(height: 20),

                // Stats Card
                glassCard(
                  radius: 30,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
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
                const SizedBox(height: 25),

                // Hourly Forecast Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hourly Forecast",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Hourly Forecast Glass Card
                glassCard(
                  radius: 30,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: weather.hourly.length,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemBuilder: (context, index) {
                          final hour = weather.hourly[index];
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: index == 0
                                  ? Colors.white.withOpacity(0.2) // current hour highlight
                                  : Colors.white.withOpacity(0.08),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  hour.time,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                getWeatherIcon(weather.condition, size: 30),
                                const SizedBox(height: 8),
                                Text(
                                  "${hour.temp}°",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // View Details Button
                glassCard(
                  radius: 40,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DetailsScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        "View Details",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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

  // Glass Card Widget
  Widget glassCard({required Widget child, double radius = 25}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
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

  // Stats Column
  Column _statColumn(IconData icon, String value, String title) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}