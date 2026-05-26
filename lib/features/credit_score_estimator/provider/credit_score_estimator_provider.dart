import 'package:flutter/material.dart';

enum PaymentHistory {
  never,
  moreThan5Years,
  twoToFiveYears,
  oneToTwoYears,
  withinLastYear,
}

enum CreditHistoryLength {
  moreThan20Years,
  tenTo20Years,
  fiveTo10Years,
  twoToFiveYears,
  oneToTwoYears,
  lessThan1Year,
}

class CreditScoreResult {
  const CreditScoreResult({
    required this.score,
    required this.grade,
    required this.utilization,
    required this.totalAccounts,
    required this.paymentHistoryScore,
    required this.creditUtilizationScore,
    required this.creditAgeScore,
    required this.accountMixScore,
    required this.creditInquiriesScore,
  });

  final int score;
  final String grade;
  final double utilization;
  final int totalAccounts;

  /// Each factor score 0.0–1.0
  final double paymentHistoryScore;
  final double creditUtilizationScore;
  final double creditAgeScore;
  final double accountMixScore;
  final double creditInquiriesScore;

  Color get gradeColor {
    if (score >= 750) return const Color(0xFF16A34A);
    if (score >= 700) return const Color(0xFF2563EB);
    if (score >= 650) return const Color(0xFFF59E0B);
    if (score >= 600) return const Color(0xFFF97316);
    return const Color(0xFFDC2626);
  }
}

class CreditScoreEstimatorProvider extends ChangeNotifier {
  // Step 1: Payment History
  PaymentHistory? paymentHistory;

  // Step 2: Account Mix
  int creditCards = 0;
  int mortgages = 0;
  int retailAccounts = 0;
  int autoLoans = 0;
  int studentLoans = 0;
  int otherLoans = 0;

  // Step 3: Credit Limits
  double totalCreditLimit = 200000;

  // Step 4: Current Balances
  double totalBalance = 0;

  // Step 5: Credit Inquiries
  int creditInquiries = 0;

  // Step 6: Credit History Length
  CreditHistoryLength? creditHistoryLength;

  void setPaymentHistory(PaymentHistory value) {
    paymentHistory = value;
    notifyListeners();
  }

  void setAccountCount(String type, int delta) {
    switch (type) {
      case 'creditCards':
        creditCards = (creditCards + delta).clamp(0, 20);
      case 'mortgages':
        mortgages = (mortgages + delta).clamp(0, 20);
      case 'retailAccounts':
        retailAccounts = (retailAccounts + delta).clamp(0, 20);
      case 'autoLoans':
        autoLoans = (autoLoans + delta).clamp(0, 20);
      case 'studentLoans':
        studentLoans = (studentLoans + delta).clamp(0, 20);
      case 'otherLoans':
        otherLoans = (otherLoans + delta).clamp(0, 20);
    }
    notifyListeners();
  }

  void setCreditLimit(double value) {
    totalCreditLimit = value;
    notifyListeners();
  }

  void setTotalBalance(double value) {
    totalBalance = value;
    notifyListeners();
  }

  void setCreditInquiries(int value) {
    creditInquiries = value;
    notifyListeners();
  }

  void setCreditHistoryLength(CreditHistoryLength value) {
    creditHistoryLength = value;
    notifyListeners();
  }

  double get utilizationRate {
    if (totalCreditLimit <= 0) return 0;
    return (totalBalance / totalCreditLimit).clamp(0.0, 1.0);
  }

  int get totalAccounts =>
      creditCards + mortgages + retailAccounts + autoLoans + studentLoans + otherLoans;

  CreditScoreResult calculate() {
    final payment = _paymentHistoryScore();
    final utilization = _utilizationScore();
    final age = _historyLengthScore();
    final mix = _accountMixScore();
    final inquiries = _inquiriesScore();

    final weighted =
        0.35 * payment + 0.30 * utilization + 0.15 * age + 0.10 * mix + 0.10 * inquiries;

    final score = (300 + weighted * 600).round().clamp(300, 900);
    final util = (utilizationRate * 100);

    return CreditScoreResult(
      score: score,
      grade: _grade(score),
      utilization: util,
      totalAccounts: totalAccounts,
      paymentHistoryScore: payment,
      creditUtilizationScore: utilization,
      creditAgeScore: age,
      accountMixScore: mix,
      creditInquiriesScore: inquiries,
    );
  }

  double _paymentHistoryScore() {
    return switch (paymentHistory) {
      PaymentHistory.never => 1.0,
      PaymentHistory.moreThan5Years => 0.85,
      PaymentHistory.twoToFiveYears => 0.60,
      PaymentHistory.oneToTwoYears => 0.40,
      PaymentHistory.withinLastYear => 0.15,
      null => 0.5,
    };
  }

  double _utilizationScore() {
    final rate = utilizationRate;
    if (rate <= 0.10) return 1.0;
    if (rate <= 0.30) return 0.80;
    if (rate <= 0.50) return 0.55;
    if (rate <= 0.75) return 0.35;
    return 0.10;
  }

  double _historyLengthScore() {
    return switch (creditHistoryLength) {
      CreditHistoryLength.moreThan20Years => 1.0,
      CreditHistoryLength.tenTo20Years => 0.80,
      CreditHistoryLength.fiveTo10Years => 0.65,
      CreditHistoryLength.twoToFiveYears => 0.45,
      CreditHistoryLength.oneToTwoYears => 0.30,
      CreditHistoryLength.lessThan1Year => 0.10,
      null => 0.5,
    };
  }

  double _accountMixScore() {
    final types = [creditCards, mortgages, retailAccounts, autoLoans, studentLoans, otherLoans]
        .where((c) => c > 0)
        .length;
    if (types == 0) return 0.10;
    if (types == 1) return 0.30;
    if (types == 2) return 0.55;
    if (types == 3) return 0.70;
    if (types == 4) return 0.85;
    return 1.0;
  }

  double _inquiriesScore() {
    if (creditInquiries == 0) return 1.0;
    if (creditInquiries == 1) return 0.80;
    if (creditInquiries == 2) return 0.60;
    if (creditInquiries == 3) return 0.45;
    if (creditInquiries == 4) return 0.30;
    return 0.10;
  }

  String _grade(int score) {
    if (score >= 750) return 'Excellent';
    if (score >= 700) return 'Very Good';
    if (score >= 650) return 'Good';
    if (score >= 600) return 'Fair';
    return 'Poor';
  }
}
