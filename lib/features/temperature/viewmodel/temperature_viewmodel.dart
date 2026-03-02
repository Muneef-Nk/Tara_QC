import 'dart:async';
import 'package:flutter/material.dart';

class TemperatureViewModel with ChangeNotifier {
  double _temperature = 0.0;
  bool _isLoading = false;
  bool _isRetesting = false;
  String? _error;
  List<double> _temperatureHistory = [];
  List<String> _temperatureTimestamps = [];

  double get temperature => _temperature;
  bool get isLoading => _isLoading;
  bool get isRetesting => _isRetesting;
  String? get error => _error;
  List<double> get temperatureHistory => _temperatureHistory;
  List<String> get temperatureTimestamps => _temperatureTimestamps;

  Future<void> loadTemperature() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Generate random temperature between 30-50°C for demonstration
      final randomTemp = 30 + (20 * DateTime.now().millisecond / 1000);
      _temperature = double.parse(randomTemp.toStringAsFixed(1));

      // Add to history
      _addToHistory(_temperature);
    } catch (e) {
      _error = 'Failed to load temperature: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retestTemperature() async {
    _isRetesting = true;
    notifyListeners();

    try {
      await loadTemperature();
    } finally {
      _isRetesting = false;
      notifyListeners();
    }
  }

  void _addToHistory(double temp) {
    _temperatureHistory.add(temp);

    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    _temperatureTimestamps.add(timeString);

    // Keep only last 10 readings
    if (_temperatureHistory.length > 10) {
      _temperatureHistory.removeAt(0);
      _temperatureTimestamps.removeAt(0);
    }
  }

  void clearHistory() {
    _temperatureHistory.clear();
    _temperatureTimestamps.clear();
    notifyListeners();
  }

  Future<bool> generateReport() async {
    // Simulate report generation
    await Future.delayed(const Duration(seconds: 2));
    return true; // Return true for success
  }
}
