import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'services/weather_service.dart';
import 'services/location_service.dart';
import 'models/weather_model.dart';
import 'models/weather_exception.dart';
import 'widgets/modern_weather_display.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error cargando .env: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with TickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();

  WeatherModel? _currentWeather;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialLoad = true;
  bool _showSearch = false;

  late AnimationController _animationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));

    _loadCurrentLocationWeather();

    // Configurar status bar transparente
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _loadCurrentLocationWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Position? position = await LocationService.getCurrentLocation();

      if (position != null) {
        final weather = await _weatherService.getWeatherByCoordinates(
          position.latitude,
          position.longitude,
        );

        setState(() {
          _currentWeather = weather;
          _isLoading = false;
          _isInitialLoad = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _isLoading = false;
          _isInitialLoad = false;
          _errorMessage = 'No se pudo obtener la ubicación actual';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isInitialLoad = false;
        _errorMessage = 'Error obteniendo ubicación: ${e.toString()}';
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });

    if (_showSearch) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
      _cityController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _searchWeather() async {
    if (_cityController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor ingresa el nombre de una ciudad');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherService.getWeatherByCity(_cityController.text);
      setState(() {
        _currentWeather = weather;
        _isLoading = false;
        _showSearch = false;
      });

      _searchAnimationController.reverse();
      _animationController.reset();
      _animationController.forward();

      _cityController.clear();
      FocusScope.of(context).unfocus();

    } on WeatherException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
        _isLoading = false;
      });
      _showErrorSnackBar('Error inesperado: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _currentWeather?.backgroundGradient ?? [
              const Color(0xFF8B5FBF),
              const Color(0xFF4A90E2),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Contenido principal
              Column(
                children: [
                  // Header con botones
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botón de ubicación
                        _buildActionButton(
                          icon: Icons.my_location,
                          onPressed: _isLoading ? null : _loadCurrentLocationWeather,
                        ),

                        // Botón de búsqueda
                        _buildActionButton(
                          icon: _showSearch ? Icons.close : Icons.search,
                          onPressed: _toggleSearch,
                        ),
                      ],
                    ),
                  ),

                  // Contenido principal
                  Expanded(
                    child: _buildMainContent(),
                  ),
                ],
              ),

              // Barra de búsqueda deslizable
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Container(
                      margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
                      child: _showSearch ? _buildSearchBar() : const SizedBox.shrink(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _cityController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Buscar una ciudad...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          suffixIcon: _isLoading
              ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : IconButton(
            icon: Icon(Icons.send, color: Colors.blue.shade600),
            onPressed: _searchWeather,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onSubmitted: (_) => _searchWeather(),
        enabled: !_isLoading,
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading && _isInitialLoad) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Obteniendo su ubicación...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_currentWeather != null) {
      return SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ModernWeatherDisplay(weather: _currentWeather!),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            _errorMessage ?? 'Busca una ciudad para\npara ver la información meteorológica.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (_errorMessage?.contains('ubicación') == true) ...[
            const SizedBox(height: 30),
            _buildActionButton(
              icon: Icons.refresh,
              onPressed: _loadCurrentLocationWeather,
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _animationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }
}