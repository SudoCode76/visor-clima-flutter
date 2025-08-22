import 'package:flutter/material.dart';

class Weather3DIcon extends StatelessWidget {
  final String weatherCondition;
  final double size;

  const Weather3DIcon({
    super.key,
    required this.weatherCondition,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sombra del icono
          Transform.translate(
            offset: Offset(size * 0.05, size * 0.05),
            child: _buildWeatherIcon(
              Colors.black.withOpacity(0.3),
              size * 0.9,
            ),
          ),
          // Icono principal
          _buildWeatherIcon(Colors.white, size),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(Color color, double iconSize) {
    switch (weatherCondition.toLowerCase()) {
      case 'despejado':
      case 'soleado':
        return _buildSunIcon(color, iconSize);
      case 'nubes':
      case 'nublado':
        return _buildCloudIcon(color, iconSize);
      case 'lluvia':
      case 'llovizna':
        return _buildRainIcon(color, iconSize);
      case 'tormenta':
      case 'tormenta eléctrica':
        return _buildThunderstormIcon(color, iconSize);
      case 'nieve':
        return _buildSnowIcon(color, iconSize);
      case 'niebla':
      case 'neblina':
        return _buildMistIcon(color, iconSize);
      default:
        return _buildCloudIcon(color, iconSize);
    }
  }


  Widget _buildSunIcon(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: color == Colors.white
              ? [Colors.yellow.shade300, Colors.orange.shade400]
              : [color, color],
        ),
        boxShadow: color == Colors.white
            ? [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ]
            : [],
      ),
    );
  }

  Widget _buildCloudIcon(Color color, double size) {
    return CustomPaint(
      size: Size(size, size * 0.7),
      painter: CloudPainter(color),
    );
  }

  Widget _buildRainIcon(Color color, double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Nube
        Transform.translate(
          offset: Offset(0, -size * 0.1),
          child: CustomPaint(
            size: Size(size * 0.8, size * 0.5),
            painter: CloudPainter(color),
          ),
        ),
        // Gotas de lluvia
        if (color == Colors.white)
          ...List.generate(3, (index) {
            return Transform.translate(
              offset: Offset(
                (index - 1) * size * 0.2,
                size * 0.25,
              ),
              child: Container(
                width: size * 0.08,
                height: size * 0.15,
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  borderRadius: BorderRadius.circular(size * 0.04),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildThunderstormIcon(Color color, double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Nube oscura
        Transform.translate(
          offset: Offset(0, -size * 0.1),
          child: CustomPaint(
            size: Size(size * 0.8, size * 0.5),
            painter: CloudPainter(color == Colors.white ? Colors.grey.shade600 : color),
          ),
        ),
        // Rayo
        if (color == Colors.white)
          Transform.translate(
            offset: Offset(size * 0.1, size * 0.2),
            child: CustomPaint(
              size: Size(size * 0.3, size * 0.4),
              painter: LightningPainter(),
            ),
          ),
      ],
    );
  }

  Widget _buildSnowIcon(Color color, double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Nube
        Transform.translate(
          offset: Offset(0, -size * 0.1),
          child: CustomPaint(
            size: Size(size * 0.8, size * 0.5),
            painter: CloudPainter(color),
          ),
        ),
        // Copos de nieve
        if (color == Colors.white)
          ...List.generate(4, (index) {
            return Transform.translate(
              offset: Offset(
                (index % 2 == 0 ? -1 : 1) * size * 0.15,
                size * 0.2 + (index % 2) * size * 0.1,
              ),
              child: Icon(
                Icons.ac_unit,
                color: Colors.white,
                size: size * 0.12,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMistIcon(Color color, double size) {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(3, (index) {
        return Transform.translate(
          offset: Offset(0, (index - 1) * size * 0.15),
          child: Container(
            width: size * 0.6,
            height: size * 0.08,
            decoration: BoxDecoration(
              color: color == Colors.white
                  ? Colors.grey.shade300.withOpacity(0.8)
                  : color,
              borderRadius: BorderRadius.circular(size * 0.04),
            ),
          ),
        );
      }),
    );
  }
}

class CloudPainter extends CustomPainter {
  final Color color;

  CloudPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Crear forma de nube usando círculos
    final center = Offset(size.width * 0.5, size.height * 0.7);
    final radius = size.width * 0.2;

    // Círculo central (más grande)
    path.addOval(Rect.fromCircle(center: center, radius: radius));

    // Círculo izquierdo
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx - radius * 0.7, center.dy),
      radius: radius * 0.8,
    ));

    // Círculo derecho
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx + radius * 0.7, center.dy),
      radius: radius * 0.8,
    ));

    // Círculo superior izquierdo
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.5),
      radius: radius * 0.6,
    ));

    // Círculo superior derecho
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx + radius * 0.3, center.dy - radius * 0.5),
      radius: radius * 0.6,
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LightningPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.yellow.shade300, Colors.orange.shade400],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();

    // Crear forma de rayo
    path.moveTo(size.width * 0.3, 0);
    path.lineTo(size.width * 0.7, size.height * 0.4);
    path.lineTo(size.width * 0.5, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.6);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}