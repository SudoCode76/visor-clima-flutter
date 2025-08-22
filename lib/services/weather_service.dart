import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';
import '../models/weather_exception.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _geoUrl = 'https://api.openweathermap.org/geo/1.0';
  late final String _apiKey;

  WeatherService() {
    _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw const InvalidApiKeyException();
    }
  }

  // Método principal para obtener el clima por nombre de ciudad
  Future<WeatherModel> getWeatherByCity(String cityName) async {
    if (cityName.trim().isEmpty) {
      throw const WeatherException('El nombre de la ciudad no puede estar vacío.');
    }

    try {
      final url = Uri.parse('$_baseUrl/weather?q=${cityName.trim()}&appid=$_apiKey&lang=es');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw const NetworkException();
        },
      );

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on WeatherException {
      rethrow;
    } catch (e) {
      throw UnknownWeatherException(e.toString());
    }
  }

  // Método para obtener clima por coordenadas
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final url = Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&lang=es');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw const NetworkException();
        },
      );

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on WeatherException {
      rethrow;
    } catch (e) {
      throw UnknownWeatherException(e.toString());
    }
  }

  // Método para obtener el nombre de la ciudad desde coordenadas (geocoding inverso)
  Future<String> getCityNameFromCoordinates(double lat, double lon) async {
    try {
      final url = Uri.parse('$_geoUrl/reverse?lat=$lat&lon=$lon&limit=1&appid=$_apiKey');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw const NetworkException();
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final location = data[0];
          final city = location['name'] ?? 'Ciudad desconocida';
          final country = location['country'] ?? '';
          return country.isNotEmpty ? '$city, $country' : city;
        }
      }

      return 'Ubicación actual';
    } catch (e) {
      return 'Ubicación actual';
    }
  }

  // Método privado para manejar la respuesta HTTP
  WeatherModel _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final Map<String, dynamic> data = json.decode(response.body);
        return WeatherModel.fromJson(data);

      case 404:
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String cityName = errorData['message']?.toString().split(' ').last ?? 'desconocida';
        throw CityNotFoundException(cityName);

      case 401:
        throw const InvalidApiKeyException();

      case 500:
      case 502:
      case 503:
        throw const ServerException();

      default:
        throw UnknownWeatherException('Código de estado: ${response.statusCode}');
    }
  }

  bool get isConfigured => _apiKey.isNotEmpty;
}