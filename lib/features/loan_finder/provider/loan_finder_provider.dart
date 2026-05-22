import 'package:flutter/foundation.dart';

enum LoanPurpose {
  personalExpenses,
  homePurchase,
  vehiclePurchase,
  education,
  business,
  debit,
  other,
}

enum EmploymentStatus {
  salaried,
  selfEmployed,
  businessOwner,
  professional,
  retired,
  other,
}

enum CreditScoreRange { excellent, good, fair, poor, dontKnow }

enum ExistingLoan { personal, home, car, creditCard, none }

enum LoanUrgency { immediately, withinWeek, withinMonth, flexible }

class LoanFinderProvider with ChangeNotifier {
  LoanPurpose? _purpose;
  double _loanAmount = 1000;
  double _monthlyIncome = 1000;
  EmploymentStatus? _employmentStatus;
  CreditScoreRange? _creditScore;
  final Set<ExistingLoan> _existingLoans = <ExistingLoan>{};
  bool? _hasExistingLoans;
  int? _numberOfLoans;
  double? _totalEmi;
  LoanUrgency? _urgency;

  LoanPurpose? get purpose => _purpose;
  double get loanAmount => _loanAmount;
  double get monthlyIncome => _monthlyIncome;
  EmploymentStatus? get employmentStatus => _employmentStatus;
  CreditScoreRange? get creditScore => _creditScore;
  Set<ExistingLoan> get existingLoans => _existingLoans;
  bool? get hasExistingLoans => _hasExistingLoans;
  int? get numberOfLoans => _numberOfLoans;
  double? get totalEmi => _totalEmi;
  LoanUrgency? get urgency => _urgency;

  void setPurpose(LoanPurpose value) {
    _purpose = value;
    notifyListeners();
  }

  void setLoanAmount(double value) {
    _loanAmount = value;
    notifyListeners();
  }

  void setMonthlyIncome(double value) {
    _monthlyIncome = value;
    notifyListeners();
  }

  void setEmploymentStatus(EmploymentStatus value) {
    _employmentStatus = value;
    notifyListeners();
  }

  void setCreditScore(CreditScoreRange value) {
    _creditScore = value;
    notifyListeners();
  }

  void toggleExistingLoan(ExistingLoan value) {
    if (value == ExistingLoan.none) {
      _existingLoans
        ..clear()
        ..add(ExistingLoan.none);
    } else {
      _existingLoans.remove(ExistingLoan.none);
      if (!_existingLoans.add(value)) {
        _existingLoans.remove(value);
      }
    }
    notifyListeners();
  }

  void setHasExistingLoans(bool value) {
    _hasExistingLoans = value;
    notifyListeners();
  }

  void setNumberOfLoans(int value) {
    _numberOfLoans = value;
    notifyListeners();
  }

  void setTotalEmi(double value) {
    _totalEmi = value;
    notifyListeners();
  }

  void setUrgency(LoanUrgency value) {
    _urgency = value;
    notifyListeners();
  }

  void reset() {
    _purpose = null;
    _loanAmount = 1000;
    _monthlyIncome = 1000;
    _employmentStatus = null;
    _creditScore = null;
    _existingLoans.clear();
    _hasExistingLoans = null;
    _numberOfLoans = null;
    _totalEmi = null;
    _urgency = null;
    notifyListeners();
  }
}
