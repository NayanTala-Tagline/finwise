/// Formats numbers with K (thousands) and L (lakhs) suffixes
/// 
/// Examples:
/// - 999 → "999"
/// - 1000 → "1K"
/// - 1500 → "1.5K"
/// - 99999 → "99.9K"
/// - 100000 → "1L"
/// - 250000 → "2.5L"
class NumberFormatter {
  /// Formats a number with K/L suffixes
  /// 
  /// [value] - The number to format
  /// [decimalPlaces] - Number of decimal places to show (default: 1)
  static String formatWithSuffix(num value, {int decimalPlaces = 1}) {
    if (value < 1000) {
      return value.toStringAsFixed(0);
    } else if (value < 100000) {
      // Show in thousands (K)
      final thousands = value / 1000;
      return '${_formatDecimal(thousands, decimalPlaces)}K';
    } else {
      // Show in lakhs (L)
      final lakhs = value / 100000;
      return '${_formatDecimal(lakhs, decimalPlaces)}L';
    }
  }

  /// Helper to format decimal values, removing trailing zeros
  static String _formatDecimal(double value, int decimalPlaces) {
    final formatted = value.toStringAsFixed(decimalPlaces);
    // Remove trailing zeros and decimal point if not needed
    return formatted.replaceAll(RegExp(r'\.?0+$'), '');
  }
}
