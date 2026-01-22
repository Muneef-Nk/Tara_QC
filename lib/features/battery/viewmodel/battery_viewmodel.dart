import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '../../../core/base/base_viewmodel.dart';

class BatteryViewModel extends BaseViewModel {
  int _batteryPercentage = 0;
  double _voltage = 0.0;
  double _temperature = 0.0;
  bool _isCharging = false;
  BatteryHealth _health = BatteryHealth.unknown;
  BatteryStatus _status = BatteryStatus.unknown;
  Timer? _simulationTimer;
  bool _isSimulating = false;
  DateTime? _lastUpdated;
  int _cycles = 0;

  // Getters
  int get batteryPercentage => _batteryPercentage;
  double get voltage => _voltage;
  double get temperature => _temperature;
  bool get isCharging => _isCharging;
  BatteryHealth get health => _health;
  BatteryStatus get status => _status;
  DateTime? get lastUpdated => _lastUpdated;
  int get cycles => _cycles;
  bool get isSimulating => _isSimulating;

  // Battery health thresholds
  static const int criticalThreshold = 30;
  static const int lowThreshold = 60;
  static const int healthyThreshold = 80;

  // Voltage ranges for different battery percentages
  static const Map<String, double> voltageRanges = {
    'min': 11.0,
    'max': 12.6,
    'critical': 11.2,
    'low': 11.8,
    'healthy': 12.2,
  };

  BatteryViewModel() {
    // Initialize with default values
    _lastUpdated = DateTime.now();
    _cycles = Random().nextInt(500);
  }

  Future<void> loadBattery() async {
    try {
      setLoading(true);
      clearError();

      // Simulate API call with realistic delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Simulate real battery data with some randomness
      final random = Random();

      // Generate realistic battery percentage (70-100% for demo)
      _batteryPercentage = 70 + random.nextInt(31);

      // Calculate voltage based on percentage
      _voltage = _calculateVoltage(_batteryPercentage);

      // Generate realistic temperature (20-35°C)
      _temperature = 20.0 + random.nextDouble() * 15;
      _temperature = double.parse(_temperature.toStringAsFixed(1));

      // Random charging status (20% chance of charging)
      _isCharging = random.nextDouble() < 0.2;

      // Determine battery health based on percentage
      _health = _determineHealth(_batteryPercentage);

      // Determine battery status
      _status = _determineStatus();

      _lastUpdated = DateTime.now();

      notifyListeners();

      // Log the battery data
      _logBatteryData();
    } catch (e) {
      setError('Failed to load battery data: ${e.toString()}');
      _resetToDefaults();
    } finally {
      setLoading(false);
    }
  }

  double _calculateVoltage(int percentage) {
    // Linear interpolation between min and max voltage based on percentage
    final minVoltage = voltageRanges['min']!;
    final maxVoltage = voltageRanges['max']!;

    final voltage = minVoltage + (maxVoltage - minVoltage) * (percentage / 100);
    return double.parse(voltage.toStringAsFixed(2));
  }

  BatteryHealth _determineHealth(int percentage) {
    if (percentage >= healthyThreshold) return BatteryHealth.excellent;
    if (percentage >= lowThreshold) return BatteryHealth.good;
    if (percentage >= criticalThreshold) return BatteryHealth.fair;
    return BatteryHealth.poor;
  }

  BatteryStatus _determineStatus() {
    if (_batteryPercentage < 5) return BatteryStatus.shutdown;
    if (_batteryPercentage < criticalThreshold) return BatteryStatus.critical;
    if (_isCharging) return BatteryStatus.charging;
    return BatteryStatus.discharging;
  }

  String getHealthDescription() {
    switch (_health) {
      case BatteryHealth.excellent:
        return 'Battery is in excellent condition';
      case BatteryHealth.good:
        return 'Battery is in good condition';
      case BatteryHealth.fair:
        return 'Battery shows signs of wear';
      case BatteryHealth.poor:
        return 'Battery needs replacement soon';
      case BatteryHealth.unknown:
        return 'Battery health unknown';
    }
  }

  String getStatusDescription() {
    switch (_status) {
      case BatteryStatus.charging:
        return 'Battery is currently charging';
      case BatteryStatus.discharging:
        return 'Battery is discharging';
      case BatteryStatus.critical:
        return 'Battery level is critically low';
      case BatteryStatus.shutdown:
        return 'Battery is about to shutdown';
      case BatteryStatus.unknown:
        return 'Battery status unknown';
    }
  }

  Color getStatusColor() {
    if (_isCharging) return const Color(0xFF4CAF50); // Green
    if (_batteryPercentage >= lowThreshold) return const Color(0xFF2196F3); // Blue
    if (_batteryPercentage >= criticalThreshold) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  Color getHealthColor() {
    switch (_health) {
      case BatteryHealth.excellent:
        return const Color(0xFF4CAF50); // Green
      case BatteryHealth.good:
        return const Color(0xFF8BC34A); // Light Green
      case BatteryHealth.fair:
        return const Color(0xFFFF9800); // Orange
      case BatteryHealth.poor:
        return const Color(0xFFF44336); // Red
      case BatteryHealth.unknown:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  // Simulation methods for demo purposes
  void startBatterySimulation() {
    if (_isSimulating) return;

    _isSimulating = true;
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _simulateBatteryChange();
      notifyListeners();
    });
  }

  void stopBatterySimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _isSimulating = false;
    notifyListeners();
  }

  void _simulateBatteryChange() {
    final random = Random();

    // Simulate battery drain or charge
    if (_isCharging) {
      // When charging, increase battery
      _batteryPercentage = (_batteryPercentage + random.nextInt(3)).clamp(0, 100);
      if (_batteryPercentage >= 100) {
        _isCharging = false; // Stop charging when full
      }
    } else {
      // When not charging, slowly drain battery
      _batteryPercentage = (_batteryPercentage - random.nextInt(2)).clamp(0, 100);

      // Occasionally start charging (10% chance)
      if (random.nextDouble() < 0.1 && _batteryPercentage < 80) {
        _isCharging = true;
      }
    }

    // Update voltage based on new percentage
    _voltage = _calculateVoltage(_batteryPercentage);

    // Update temperature (small variations)
    _temperature += (random.nextDouble() - 0.5) * 2;
    _temperature = _temperature.clamp(15.0, 40.0);
    _temperature = double.parse(_temperature.toStringAsFixed(1));

    // Update health and status
    _health = _determineHealth(_batteryPercentage);
    _status = _determineStatus();

    _lastUpdated = DateTime.now();

    // Occasionally increase cycle count
    if (random.nextDouble() < 0.01) {
      _cycles++;
    }
  }

  void toggleCharging() {
    _isCharging = !_isCharging;
    _status = _determineStatus();
    notifyListeners();
  }

  void resetBattery() {
    _batteryPercentage = 100;
    _voltage = voltageRanges['max']!;
    _temperature = 25.0;
    _isCharging = false;
    _health = BatteryHealth.excellent;
    _status = BatteryStatus.discharging;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': _batteryPercentage,
      'voltage': _voltage,
      'temperature': _temperature,
      'isCharging': _isCharging,
      'health': _health.toString().split('.').last,
      'status': _status.toString().split('.').last,
      'lastUpdated': _lastUpdated?.toIso8601String(),
      'cycles': _cycles,
    };
  }

  void _logBatteryData() {
    print('''
    Battery Data Loaded:
    - Percentage: $_batteryPercentage%
    - Voltage: ${_voltage}V
    - Temperature: ${_temperature}°C
    - Charging: $_isCharging
    - Health: $_health
    - Status: $_status
    - Cycles: $_cycles
    - Last Updated: $_lastUpdated
    ''');
  }

  void _resetToDefaults() {
    _batteryPercentage = 0;
    _voltage = 0.0;
    _temperature = 0.0;
    _isCharging = false;
    _health = BatteryHealth.unknown;
    _status = BatteryStatus.unknown;
    _lastUpdated = DateTime.now();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}

enum BatteryHealth { excellent, good, fair, poor, unknown }

enum BatteryStatus { charging, discharging, critical, shutdown, unknown }

// Extension methods for better string representation
extension BatteryHealthExtension on BatteryHealth {
  String get displayName {
    switch (this) {
      case BatteryHealth.excellent:
        return 'Excellent';
      case BatteryHealth.good:
        return 'Good';
      case BatteryHealth.fair:
        return 'Fair';
      case BatteryHealth.poor:
        return 'Poor';
      case BatteryHealth.unknown:
        return 'Unknown';
    }
  }
}

extension BatteryStatusExtension on BatteryStatus {
  String get displayName {
    switch (this) {
      case BatteryStatus.charging:
        return 'Charging';
      case BatteryStatus.discharging:
        return 'Discharging';
      case BatteryStatus.critical:
        return 'Critical';
      case BatteryStatus.shutdown:
        return 'Shutdown';
      case BatteryStatus.unknown:
        return 'Unknown';
    }
  }
}
