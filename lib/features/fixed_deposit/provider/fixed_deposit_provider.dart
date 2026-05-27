import 'package:flutter/widgets.dart';

enum FdTenureUnit { month, year }

class FixedDepositProvider with ChangeNotifier {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController tenureController = TextEditingController();

  FdTenureUnit _tenureUnit = FdTenureUnit.month;
  DateTime _startDate = DateTime.now();
  bool _isCalculated = false;

  FdTenureUnit get tenureUnit => _tenureUnit;
  DateTime get startDate => _startDate;
  bool get isCalculated => _isCalculated;

  String get tenureUnitLabel =>
      _tenureUnit == FdTenureUnit.month ? 'Month' : 'Year';

  void setTenureUnit(String unit) {
    _tenureUnit = unit == 'Year' ? FdTenureUnit.year : FdTenureUnit.month;
    _isCalculated = false;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    _startDate = date;
    _isCalculated = false;
    notifyListeners();
  }

  bool get isInputValid {
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final rate = double.tryParse(rateController.text.trim()) ?? 0;
    final tenure = double.tryParse(tenureController.text.trim()) ?? 0;
    return amount > 0 && rate > 0 && tenure > 0;
  }

  void calculate() {
    _isCalculated = true;
    notifyListeners();
  }

  void refresh() {
    amountController.clear();
    rateController.clear();
    tenureController.clear();
    _tenureUnit = FdTenureUnit.month;
    _startDate = DateTime.now();
    _isCalculated = false;
    notifyListeners();
  }

  FdResult get result {
    final principal = double.tryParse(amountController.text.trim()) ?? 0;
    final annualRate = double.tryParse(rateController.text.trim()) ?? 0;
    final tenureValue = double.tryParse(tenureController.text.trim()) ?? 0;

    final tenureMonths = _tenureUnit == FdTenureUnit.year
        ? (tenureValue * 12).round()
        : tenureValue.round();
    final tenureInYears = tenureMonths / 12;

    final interest = principal * annualRate * tenureInYears / 100;
    final total = principal + interest;

    final totalRawMonths = _startDate.month - 1 + tenureMonths;
    final endDate = DateTime(
      _startDate.year + totalRawMonths ~/ 12,
      totalRawMonths % 12 + 1,
      _startDate.day,
    );

    return FdResult(
      principal: principal,
      annualRate: annualRate,
      tenureMonths: tenureMonths,
      totalInterestValue: interest,
      maturityValue: total,
      endDate: endDate,
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    rateController.dispose();
    tenureController.dispose();
    super.dispose();
  }
}

class FdResult {
  const FdResult({
    required this.principal,
    required this.annualRate,
    required this.tenureMonths,
    required this.totalInterestValue,
    required this.maturityValue,
    required this.endDate,
  });

  final double principal;
  final double annualRate;
  final int tenureMonths;
  final double totalInterestValue;
  final double maturityValue;
  final DateTime endDate;
}
