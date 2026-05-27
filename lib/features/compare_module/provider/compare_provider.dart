import 'dart:math' as math;

import 'package:flutter/foundation.dart';

enum TenureUnit { month, year }

class _LoanInput {
  String amount = '';
  double rate = 10.5;
  String tenure = '';
  TenureUnit tenureUnit = TenureUnit.year;
}

class LoanResult {
  const LoanResult({
    required this.emi,
    required this.totalInterest,
    required this.totalPayment,
    required this.months,
  });

  final double emi;
  final double totalInterest;
  final double totalPayment;
  final double months;

  static const zero = LoanResult(emi: 0, totalInterest: 0, totalPayment: 0, months: 0);
}

class CompareProvider with ChangeNotifier {
  final List<_LoanInput> _loans = [_LoanInput(), _LoanInput()];

  bool _calculated = false;

  bool get isCalculated => _calculated;
  int get loanCount => _loans.length;

  // ── Accessors ──────────────────────────────────────────────────────────────

  String amountOf(int i) => _loans[i].amount;
  double rateOf(int i) => _loans[i].rate;
  String tenureOf(int i) => _loans[i].tenure;
  TenureUnit tenureUnitOf(int i) => _loans[i].tenureUnit;

  // ── Mutators ───────────────────────────────────────────────────────────────

  void setAmount(int i, String value) {
    _loans[i].amount = value;
    _calculated = false;
    notifyListeners();
  }

  void setRate(int i, double value) {
    _loans[i].rate = value;
    _calculated = false;
    notifyListeners();
  }

  void setTenure(int i, String value) {
    _loans[i].tenure = value;
    _calculated = false;
    notifyListeners();
  }

  void setTenureUnit(int i, TenureUnit unit) {
    _loans[i].tenureUnit = unit;
    _calculated = false;
    notifyListeners();
  }

  void addLoan() {
    if (_loans.length >= 4) return;
    _loans.add(_LoanInput());
    _calculated = false;
    notifyListeners();
  }

  void removeLoan(int i) {
    if (_loans.length <= 2) return;
    _loans.removeAt(i);
    _calculated = false;
    notifyListeners();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  bool get isInputValid {
    int validCount = 0;
    for (final loan in _loans) {
      final amount = double.tryParse(loan.amount.trim()) ?? 0;
      final tenure = double.tryParse(loan.tenure.trim()) ?? 0;
      if (amount > 0 && loan.rate > 0 && tenure > 0) validCount++;
    }
    return validCount >= 2;
  }

  // ── Calculate ──────────────────────────────────────────────────────────────

  void calculate() {
    _calculated = true;
    notifyListeners();
  }

  void refresh() {
    while (_loans.length > 2) {
      _loans.removeLast();
    }
    for (final loan in _loans) {
      loan.amount = '';
      loan.rate = 10.5;
      loan.tenure = '';
      loan.tenureUnit = TenureUnit.year;
    }
    _calculated = false;
    notifyListeners();
  }

  // ── Results ────────────────────────────────────────────────────────────────

  LoanResult resultOf(int i) {
    final loan = _loans[i];
    final principal = double.tryParse(loan.amount.trim()) ?? 0;
    final months = loan.tenureUnit == TenureUnit.year
        ? (double.tryParse(loan.tenure.trim()) ?? 0) * 12
        : (double.tryParse(loan.tenure.trim()) ?? 0);

    if (principal <= 0 || loan.rate <= 0 || months <= 0) return LoanResult.zero;

    final monthlyRate = loan.rate / 12 / 100;
    final pow = math.pow(1 + monthlyRate, months).toDouble();
    final emi = principal * monthlyRate * pow / (pow - 1);
    final total = emi * months;
    final interest = total - principal;
    return LoanResult(
      emi: emi,
      totalInterest: interest,
      totalPayment: total,
      months: months,
    );
  }

  /// Returns the index of the loan with the lowest total payment.
  /// Returns -1 if fewer than 2 valid results exist.
  int bestLoanIndex() {
    int bestIdx = -1;
    double bestTotal = double.infinity;
    for (int i = 0; i < _loans.length; i++) {
      final r = resultOf(i);
      if (r.emi > 0 && r.totalPayment < bestTotal) {
        bestTotal = r.totalPayment;
        bestIdx = i;
      }
    }
    return bestIdx;
  }
}
