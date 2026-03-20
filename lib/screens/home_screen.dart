import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  final List<WeatherModel> citiesWeather;

  const HomeScreen({super.key, required this.citiesWeather});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  late List<WeatherModel> _citiesWeather;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _citiesWeather = List.from(widget.citiesWeather);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showChangeCityDialog(int index) {
    final TextEditingController editController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2c3e50),
          title: Text('Replace ${_citiesWeather[index].cityName}', style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: editController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter new city...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _fetchAndReplaceCity(index, editController.text.trim());
              },
              child: const Text('Change', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _fetchAndReplaceCity(int index, String newCity) async {
    if (newCity.isEmpty) return;
    setState(() => _isLoading = true);
    
    try {
      final WeatherService weatherService = WeatherService();
      final newWeather = await weatherService.getWeather(newCity);
      
      setState(() {
        _citiesWeather[index] = newWeather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch city. Check spelling or API.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  LinearGradient _getBackgroundGradient(String? condition) {
    if (condition == null) {
      return const LinearGradient(colors: [Color(0xFF2c3e50), Color(0xFF3498db)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
    switch (condition.toLowerCase()) {
      case 'clear': return const LinearGradient(colors: [Color(0xFFf2994a), Color(0xFFf2c94c)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'rain': case 'drizzle': return const LinearGradient(colors: [Color(0xFF2c3e50), Color(0xFF4ca1af)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'clouds': return const LinearGradient(colors: [Color(0xFF757f9a), Color(0xFFd7dde8)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'snow': return const LinearGradient(colors: [Color(0xFFe6dada), Color(0xFF274046)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      default: return const LinearGradient(colors: [Color(0xFF2c3e50), Color(0xFF3498db)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
  }

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return Icons.device_unknown;
    switch (condition.toLowerCase()) {
      case 'clear': return Icons.wb_sunny;
      case 'rain': case 'drizzle': return Icons.umbrella;
      case 'clouds': return Icons.cloud;
      case 'snow': return Icons.ac_unit;
      case 'thunderstorm': return Icons.flash_on;
      default: return Icons.cloud_queue;
    }
  }

  String _formatDay(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month) {
      return 'Today';
    }
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    WeatherModel? currentViewedWeather;
    int currentPage = 0;
    if (_citiesWeather.isNotEmpty && _pageController.hasClients) {
      currentPage = _pageController.page?.round() ?? 0;
      if (currentPage >= 0 && currentPage < _citiesWeather.length) {
        currentViewedWeather = _citiesWeather[currentPage];
      }
    } else if (_citiesWeather.isNotEmpty) {
      currentViewedWeather = _citiesWeather.first;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                   width: 20, height: 20,
                   child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_location_alt, color: Colors.white),
              tooltip: 'Replace this city',
              onPressed: () => _showChangeCityDialog(currentPage),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(currentViewedWeather?.mainCondition),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {}); 
                  },
                  itemCount: _citiesWeather.length,
                  itemBuilder: (context, index) {
                    final weather = _citiesWeather[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              _getWeatherIcon(weather.mainCondition),
                              key: ValueKey(weather.mainCondition),
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${weather.temperature.round()}°C',
                            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            weather.cityName,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weather.description.toUpperCase(),
                            style: const TextStyle(fontSize: 16, letterSpacing: 2.0, color: Colors.white70),
                          ),
                          
                          const SizedBox(height: 48),

                          if (weather.forecasts != null && weather.forecasts!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    '3-DAY FORECAST',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: weather.forecasts!.map((forecast) {
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: GlassCard(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _formatDay(forecast.dateTime),
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 8),
                                              Icon(
                                                _getWeatherIcon(forecast.mainCondition),
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${forecast.temperature.round()}°',
                                                style: const TextStyle(color: Colors.white, fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_citiesWeather.length, (dotIndex) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                height: 8,
                                width: index == dotIndex ? 24 : 8,
                                decoration: BoxDecoration(
                                  color: index == dotIndex ? Colors.white : Colors.white.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
