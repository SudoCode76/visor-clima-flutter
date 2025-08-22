import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Verificar si los servicios de ubicación están habilitados
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Solicitar permisos de ubicación
  static Future<bool> requestLocationPermission() async {
    // Verificar el estado actual del permiso
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Obtener la ubicación actual
  static Future<Position?> getCurrentLocation() async {
    try {
      // Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException();
      }

      // Solicitar permisos
      bool permissionGranted = await requestLocationPermission();
      if (!permissionGranted) {
        throw LocationPermissionDeniedException();
      }

      // Obtener la ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  // Abrir configuración de la aplicación (para cuando los permisos están denegados permanentemente)
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // Abrir configuración de ubicación del dispositivo
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}

// Excepciones personalizadas para ubicación
class LocationServiceDisabledException implements Exception {
  final String message = 'Los servicios de ubicación están deshabilitados.';
  @override
  String toString() => message;
}

class LocationPermissionDeniedException implements Exception {
  final String message = 'Permisos de ubicación denegados.';
  @override
  String toString() => message;
}