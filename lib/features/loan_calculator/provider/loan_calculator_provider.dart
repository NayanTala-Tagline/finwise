import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class LoanCalculatorProvider with ChangeNotifier {
  final TextEditingController loanAmountController = TextEditingController();
  final TextEditingController loanTermController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();

  double _interestRate = 10.5;
  double get interestRate => _interestRate;

  String _termUnit = 'Months';
  String get termUnit => _termUnit;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  bool _isCalculated = false;
  bool get isCalculated => _isCalculated;

  void setInterestRate(double value) {
    _interestRate = double.parse(value.toStringAsFixed(1));
    notifyListeners();
  }

  void setTermUnit(String unit) {
    _termUnit = unit;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    _startDate = date;
    startDateController.text =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    notifyListeners();
  }

  bool get isInputValid {
    final loanAmount = double.tryParse(loanAmountController.text.trim()) ?? 0;
    final loanTerm = double.tryParse(loanTermController.text.trim()) ?? 0;
    return loanAmount > 0 && loanTerm > 0;
  }

  void calculate() {
    _isCalculated = true;
    notifyListeners();
  }

  void refresh() {
    loanAmountController.clear();
    loanTermController.clear();
    startDateController.clear();
    _interestRate = 10.5;
    _termUnit = 'Months';
    _startDate = null;
    _isCalculated = false;
    notifyListeners();
  }

  LoanCalculatorResult get result {
    final loanAmount = double.tryParse(loanAmountController.text.trim()) ?? 0;
    final termValue = double.tryParse(loanTermController.text.trim()) ?? 0;
    final int n = _termUnit == 'Months' ? termValue.round() : (termValue * 12).round();
    final double loanTermYears = n / 12;
    final monthlyRate = _interestRate / 100 / 12;

    double emi;
    if (monthlyRate == 0 || n == 0) {
      emi = n > 0 ? loanAmount / n : 0;
    } else {
      final pow = math.pow(1 + monthlyRate, n).toDouble();
      emi = loanAmount * monthlyRate * pow / (pow - 1);
    }

    final totalPayment = emi * n;
    final totalInterest = totalPayment - loanAmount;

    return LoanCalculatorResult(
      loanAmount: loanAmount,
      downPayment: 0,
      loanTermYears: loanTermYears,
      annualRate: _interestRate,
      principal: loanAmount,
      monthlyPayment: emi,
      totalInterest: totalInterest,
      totalPayment: totalPayment,
    );
  }

  @override
  void dispose() {
    loanAmountController.dispose();
    loanTermController.dispose();
    startDateController.dispose();
    super.dispose();
  }
}

class LoanCalculatorResult {
  const LoanCalculatorResult({
    required this.loanAmount,
    required this.downPayment,
    required this.loanTermYears,
    required this.annualRate,
    required this.principal,
    required this.monthlyPayment,
    required this.totalInterest,
    required this.totalPayment,
  });

  final double loanAmount;
  final double downPayment;
  final double loanTermYears;
  final double annualRate;
  final double principal;
  final double monthlyPayment;
  final double totalInterest;
  final double totalPayment;
}
