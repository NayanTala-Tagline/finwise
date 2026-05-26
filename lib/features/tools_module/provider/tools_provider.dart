import 'package:flutter/foundation.dart';

enum ConverterKind { temperature, mass, speed, length }

class ToolsProvider with ChangeNotifier {
  final Map<ConverterKind, _ConverterState> _state = {
    ConverterKind.temperature: _ConverterState(
      fromUnit: temperatureUnits.first,
      toUnit: temperatureUnits[1],
    ),
    ConverterKind.mass: _ConverterState(
      fromUnit: massUnits.first,
      toUnit: massUnits[6],
    ),
    ConverterKind.speed: _ConverterState(
      fromUnit: speedUnits.first,
      toUnit: speedUnits[1],
    ),
    ConverterKind.length: _ConverterState(
      fromUnit: lengthUnits.first,
      toUnit: lengthUnits[4],
    ),
  };

  String inputOf(ConverterKind kind) => _state[kind]!.input;
  String fromUnitOf(ConverterKind kind) => _state[kind]!.fromUnit;
  String toUnitOf(ConverterKind kind) => _state[kind]!.toUnit;
  bool isCalculatedOf(ConverterKind kind) => _state[kind]!.calculated;

  void setInput(ConverterKind kind, String value) {
    _state[kind]!.input = value;
    _state[kind]!.calculated = false;
    notifyListeners();
  }

  void setFromUnit(ConverterKind kind, String unit) {
    _state[kind]!.fromUnit = unit;
    _state[kind]!.calculated = false;
    notifyListeners();
  }

  void setToUnit(ConverterKind kind, String unit) {
    _state[kind]!.toUnit = unit;
    _state[kind]!.calculated = false;
    notifyListeners();
  }

  void convert(ConverterKind kind) {
    _state[kind]!.calculated = true;
    notifyListeners();
  }

  void refresh(ConverterKind kind) {
    final s = _state[kind]!;
    s.input = '';
    s.calculated = false;
    notifyListeners();
  }

  /// Returns the converted value from [fromUnit] to [toUnit] using the
  /// converter [kind]. Returns 0 when the input is empty/invalid.
  double convertValue({
    required ConverterKind kind,
    required String fromUnit,
    required String toUnit,
  }) {
    final raw = double.tryParse(_state[kind]!.input);
    if (raw == null) return 0;
    switch (kind) {
      case ConverterKind.temperature:
        return _convertTemperature(raw, fromUnit, toUnit);
      case ConverterKind.mass:
        return _convertByFactor(raw, fromUnit, toUnit, _massToKg);
      case ConverterKind.speed:
        return _convertByFactor(raw, fromUnit, toUnit, _speedToMps);
      case ConverterKind.length:
        return _convertByFactor(raw, fromUnit, toUnit, _lengthToMeter);
    }
  }

  // ── Unit catalogues ───────────────────────────────────────────────────────

  static const List<String> temperatureUnits = [
    'Degree Celsius',
    'Fahrenheit',
    'Kelvin',
  ];

  static const List<String> massUnits = [
    'Kilogram',
    'Microgram',
    'Milligram',
    'Carat',
    'Quintal',
    'Ton',
    'Gram',
  ];

  static const List<String> speedUnits = [
    'Kilometer per Second',
    'Kilometer per Hour',
    'Speed of Light',
    'Meter per Second',
    'Meter per Hour',
    'Inch per Second',
    'Mach',
  ];

  static const List<String> lengthUnits = [
    'Kilometer',
    'Millimeter',
    'Centimeter',
    'Decimeter',
    'Meter',
    'Decameter',
    'Hectometer',
  ];

  // ── Conversion tables (factor → base unit) ────────────────────────────────

  static const Map<String, double> _massToKg = {
    'Kilogram': 1,
    'Microgram': 1e-9,
    'Milligram': 1e-6,
    'Carat': 0.0002,
    'Quintal': 100,
    'Ton': 1000,
    'Gram': 0.001,
  };

  static const Map<String, double> _speedToMps = {
    'Kilometer per Second': 1000,
    'Kilometer per Hour': 1000 / 3600,
    'Speed of Light': 299792458,
    'Meter per Second': 1,
    'Meter per Hour': 1 / 3600,
    'Inch per Second': 0.0254,
    'Mach': 343,
  };

  static const Map<String, double> _lengthToMeter = {
    'Kilometer': 1000,
    'Millimeter': 0.001,
    'Centimeter': 0.01,
    'Decimeter': 0.1,
    'Meter': 1,
    'Decameter': 10,
    'Hectometer': 100,
  };

  double _convertByFactor(
    double value,
    String from,
    String to,
    Map<String, double> factors,
  ) {
    final f = factors[from];
    final t = factors[to];
    if (f == null || t == null) return 0;
    return value * f / t;
  }

  double _convertTemperature(double value, String from, String to) {
    if (from == to) return value;
    // Step 1: from → Celsius
    double celsius;
    switch (from) {
      case 'Degree Celsius':
        celsius = value;
        break;
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = value - 273.15;
        break;
      default:
        return 0;
    }
    // Step 2: Celsius → target
    switch (to) {
      case 'Degree Celsius':
        return celsius;
      case 'Fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'Kelvin':
        return celsius + 273.15;
    }
    return 0;
  }
}

class _ConverterState {
  _ConverterState({required this.fromUnit, required this.toUnit});

  String input = '';
  String fromUnit;
  String toUnit;
  bool calculated = false;
}
