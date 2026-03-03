class HourlyWeather {
  final String time;
  final double temp;
  final String condition;

  HourlyWeather({required this.time, required this.temp, required this.condition});
}

class DailyWeather {
  final String day;
  final double maxTemp;
  final double minTemp;
  final String condition;

  DailyWeather({required this.day, required this.maxTemp, required this.minTemp, required this.condition});
}

class Weather {
  final String cityName;
  final double temp;
  final String condition;
  final int humidity;
  final double windSpeed;
  final int? visibility;
  final int? sunrise;
  final int? sunset;
  final int? pressure;

  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  Weather( {
    this.visibility, this.sunrise, this.sunset, this.pressure,
    required this.cityName,
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.hourly,
    required this.daily,
  });
}