import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'weather_3d_icon.dart';

class ModernWeatherDisplay extends StatelessWidget {
  final WeatherModel weather;

  const ModernWeatherDisplay({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Saludo y ubicación
          _buildGreetingSection(),

          const SizedBox(height: 40),

          // Icono 3D del clima
          Weather3DIcon(
            weatherCondition: weather.mainWeather,
            size: 150,
          ),

          const SizedBox(height: 30),

          // Temperatura principal
          Text(
            weather.temperatureString,
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              height: 1,
            ),
          ),

          // Descripción del clima
          Text(
            weather.description.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),

          // Fecha y hora
          Text(
            _getCurrentDateString(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 40),

          // Información del sol
          _buildSunInformation(),

          const SizedBox(height: 30),

          // Temperaturas min/max
          _buildTemperatureRange(),
        ],
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.white.withOpacity(0.8),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              weather.fullLocationName,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _getGreeting(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSunInformation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Amanecer
          _buildSunTimeItem(
            icon: Icons.wb_sunny,
            label: 'Amanecer',
            time: _formatTime(weather.sunrise),
            color: Colors.orange.shade300,
          ),

          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),

          // Atardecer
          _buildSunTimeItem(
            icon: Icons.nights_stay,
            label: 'Anochecer',
            time: _formatTime(weather.sunset),
            color: Colors.indigo.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildSunTimeItem({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureRange() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Temperatura máxima
          _buildTempItem(
            icon: Icons.thermostat,
            label: 'Temperatura',
            value: weather.feelsLikeString,
            color: Colors.red.shade300,
          ),

          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),

          // Humedad
          _buildTempItem(
            icon: Icons.water_drop,
            label: 'Humedad',
            value: '${weather.humidity}%',
            color: Colors.blue.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildTempItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    final weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];


    final weekday = weekdays[now.weekday - 1];
    final day = now.day;
    final month = months[now.month - 1];
    final time = '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}${now.hour >= 12 ? 'pm' : 'am'}';

    return '$weekday $day • $time';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'pm' : 'am';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }
}