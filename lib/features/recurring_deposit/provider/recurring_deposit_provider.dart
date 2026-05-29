import 'package:flutter/widgets.dart';

enum RdTenureUnit { month, year }

class RecurringDepositProvider with ChangeNotifier {
  final TextEditingController depositController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController tenureController = TextEditingController();

  RdTenureUnit _tenureUnit = RdTenureUnit.month;
  DateTime _startDate = DateTime.now();
  bool _isCalculated = false;

  RdTenureUnit get tenureUnit => _tenureUnit;
  DateTime get startDate => _startDate;
  bool get isCalculated => _isCalculated;

  void setTenureUnit(RdTenureUnit unit) {
    _tenureUnit = unit;
    _isCalculated = false;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    _startDate = date;
    _isCalculated = false;
    notifyListeners();
  }

  bool get isInputValid {
    final deposit = double.tryParse(depositController.text.trim()) ?? 0;
    final rate = double.tryParse(rateController.text.trim()) ?? 0;
    final tenure = double.tryParse(tenureController.text.trim()) ?? 0;
    return deposit > 0 && rate > 0 && tenure > 0;
  }

  void calculate() {
    _isCalculated = true;
    notifyListeners();
  }

  void refresh() {
    depositController.clear();
    rateController.clear();
    tenureController.clear();
    _tenureUnit = RdTenureUnit.month;
    _startDate = DateTime.now();
    _isCalculated = false;
    notifyListeners();
  }

  RdResult get result {
    final monthlyDeposit =
        double.tryParse(depositController.text.trim()) ?? 0;
    final annualRate = double.tryParse(rateController.text.trim()) ?? 0;
    final tenureValue = double.tryParse(tenureController.text.trim()) ?? 0;

    final tenureMonths = _tenureUnit == RdTenureUnit.year
        ? (tenureValue * 12).round()
        : tenureValue.round();

    // Standard RD simple interest formula:
    // Interest = P × n(n+1)/2 × r / (12 × 100)
    final totalInvested = monthlyDeposit * tenureMonths;
    final interest =
        monthlyDeposit * tenureMonths * (tenureMonths + 1) / 2 * annualRate /
            (12 * 100);
    final maturity = totalInvested + interest;

    final totalRawMonths = _startDate.month - 1 + tenureMonths;
    final endDate = DateTime(
      _startDate.year + totalRawMonths ~/ 12,
      totalRawMonths % 12 + 1,
      _startDate.day,
    );

    return RdResult(
      monthlyDeposit: monthlyDeposit,
      annualRate: annualRate,
      tenureMonths: tenureMonths,
      totalInvested: totalInvested,
      interestEarned: interest,
      maturityValue: maturity,
      endDate: endDate,
    );
  }

  @override
  void dispose() {
    depositController.dispose();
    rateController.dispose();
    tenureController.dispose();
    super.dispose();
  }
}

class RdResult {
  const RdResult({
    required this.monthlyDeposit,
    required this.annualRate,
    required this.tenureMonths,
    required this.totalInvested,
    required this.interestEarned,
    required this.maturityValue,
    required this.endDate,
  });

  final double monthlyDeposit;
  final double annualRate;
  final int tenureMonths;
  final double totalInvested;
  final double interestEarned;
  final double maturityValue;
  final DateTime endDate;
}
