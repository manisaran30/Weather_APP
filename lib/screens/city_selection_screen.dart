import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../widgets/glass_card.dart';
import 'home_screen.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  final _c3 = TextEditingController();
  final _weatherService = WeatherService();

  bool _isLoading = false;
  String? _errorMessage;

  void _fetchAll() async {
    final c1 = _c1.text.trim();
    final c2 = _c2.text.trim();
    final c3 = _c3.text.trim();

    if (c1.isEmpty || c2.isEmpty || c3.isEmpty) {
      setState(() => _errorMessage = 'Please carefully enter exactly 3 cities.');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final w1 = await _weatherService.getWeather(c1);
      final w2 = await _weatherService.getWeather(c2);
      final w3 = await _weatherService.getWeather(c3);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(citiesWeather: [w1, w2, w3])),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather for one or more cities. Check spellings or API activation.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2c3e50), Color(0xFF3498db)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_city, size: 60, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text(
                      'Select 3 Cities', 
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)
                    ),
                    const SizedBox(height: 32),
                    _buildField(_c1, 'City 1 (e.g. London)'),
                    const SizedBox(height: 16),
                    _buildField(_c2, 'City 2 (e.g. Tokyo)'),
                    const SizedBox(height: 16),
                    _buildField(_c3, 'City 3 (e.g. New York)'),
                    const SizedBox(height: 32),
                    
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!, 
                          textAlign: TextAlign.center, 
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
                        ),
                      ),
                      
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _fetchAll,
                        child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Get Weather', style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: const Icon(Icons.location_on, color: Colors.white70),
      ),
    );
  }
}
