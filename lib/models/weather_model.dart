import 'dart:ui';

import 'package:flutter/material.dart';

class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final String description;
  final String mainWeather;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int visibility;
  final String icon;
  final DateTime sunrise;
  final DateTime sunset;
  final int timezoneOffset; // Nuevo campo para el offset de la ciudad

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.description,
    required this.mainWeather,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.icon,
    required this.sunrise,
    required this.sunset,
    required this.timezoneOffset,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // Obtener el offset de zona horaria de la respuesta (en segundos)
    final timezoneOffsetSeconds = json['timezone'] ?? 0;

    // Convertir timestamps UTC a hora local de la ciudad
    final sunriseUtc = DateTime.fromMillisecondsSinceEpoch(
      (json['sys']['sunrise'] ?? 0) * 1000,
      isUtc: true,
    );
    final sunsetUtc = DateTime.fromMillisecondsSinceEpoch(
      (json['sys']['sunset'] ?? 0) * 1000,
      isUtc: true,
    );

    // Aplicar el offset de zona horaria de la ciudad
    final sunriseLocal = sunriseUtc.add(Duration(seconds: timezoneOffsetSeconds));
    final sunsetLocal = sunsetUtc.add(Duration(seconds: timezoneOffsetSeconds));

    return WeatherModel(
      cityName: json['name'] ?? 'Ciudad desconocida',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble() - 273.15,
      description: json['weather'][0]['description'] ?? 'Sin descripción',
      mainWeather: json['weather'][0]['main'] ?? 'Desconocido',
      feelsLike: (json['main']['feels_like'] as num).toDouble() - 273.15,
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num?)?.toDouble() ?? 0.0,
      pressure: json['main']['pressure'] ?? 0,
      visibility: json['visibility'] ?? 0,
      icon: json['weather'][0]['icon'] ?? '01d',
      sunrise: sunriseLocal,
      sunset: sunsetLocal,
      timezoneOffset: timezoneOffsetSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'temperature': temperature,
      'description': description,
      'mainWeather': mainWeather,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'pressure': pressure,
      'visibility': visibility,
      'icon': icon,
      'timezoneOffset': timezoneOffset,
    };
  }

  String get temperatureString => '${temperature.round()}°C';
  String get feelsLikeString => '${feelsLike.round()}°C';
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
  String get fullLocationName => '$cityName, $country';
  String get windSpeedString => '${windSpeed.toStringAsFixed(1)} m/s';
  String get pressureString => '$pressure hPa';
  String get visibilityString => '${(visibility / 1000).toStringAsFixed(1)} km';

  // Gradiente según el clima
  List<Color> get backgroundGradient {
    switch (mainWeather.toLowerCase()) {
      case 'clear':
        return [Colors.orange.shade300, Colors.deepOrange.shade400];
      case 'clouds':
        return [Colors.grey.shade400, Colors.blueGrey.shade600];
      case 'rain':
      case 'drizzle':
        return [Colors.blue.shade400, Colors.indigo.shade600];
      case 'thunderstorm':
        return [Colors.purple.shade400, Colors.deepPurple.shade700];
      case 'snow':
        return [Colors.blue.shade100, Colors.blue.shade300];
      case 'mist':
      case 'fog':
        return [Colors.grey.shade300, Colors.grey.shade500];
      default:
        return [Colors.blue.shade300, Colors.blue.shade600];
    }
  }

  @override
  String toString() {
    return 'WeatherModel(cityName: $cityName, temperature: $temperatureString, description: $description)';
  }
}