// Clase base para excepciones del clima
class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => message;
}

// Ciudad no encontrada
class CityNotFoundException extends WeatherException {
  const CityNotFoundException(String cityName)
      : super('La ciudad "$cityName" no fue encontrada. Verifica la ortografía.');
}

// Error de red/conexión
class NetworkException extends WeatherException {
  const NetworkException()
      : super('Error de conexión. Verifica tu conexión a internet.');
}

// Error del servidor
class ServerException extends WeatherException {
  const ServerException()
      : super('Error del servidor. Intenta nuevamente más tarde.');
}

// API key inválida
class InvalidApiKeyException extends WeatherException {
  const InvalidApiKeyException()
      : super('API key inválida. Verifica tu configuración.');
}

// Error genérico
class UnknownWeatherException extends WeatherException {
  const UnknownWeatherException(String details)
      : super('Error inesperado: $details');
}