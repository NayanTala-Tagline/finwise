import '../../../gen/assets.gen.dart';
import '../../../l10n/app_localizations.dart';
import '../provider/loan_finder_provider.dart';

/// Immutable snapshot of everything the 7-step loan finder collected. Built
/// from [LoanFinderProvider] at the end of the flow and passed to the
/// Recommendations screen via go_router's `extra`.
class LoanFinderResult {
  const LoanFinderResult({
    required this.purpose,
    required this.loanAmount,
    required this.monthlyIncome,
    required this.employmentStatus,
    required this.creditScore,
    required this.hasExistingLoans,
    this.numberOfLoans,
    this.totalEmi,
    required this.urgency,
    this.processingFee = 0,
  });

  final LoanPurpose purpose;
  final double loanAmount;
  final double monthlyIncome;
  final EmploymentStatus employmentStatus;
  final CreditScoreRange creditScore;
  final bool hasExistingLoans;
  final int? numberOfLoans;
  final double? totalEmi;
  final LoanUrgency urgency;
  final double processingFee;

  factory LoanFinderResult.fromProvider(LoanFinderProvider p) {
    return LoanFinderResult(
      purpose: p.purpose!,
      loanAmount: p.loanAmount,
      monthlyIncome: p.monthlyIncome,
      employmentStatus: p.employmentStatus!,
      creditScore: p.creditScore!,
      hasExistingLoans: p.hasExistingLoans ?? false,
      numberOfLoans: p.numberOfLoans,
      totalEmi: p.totalEmi,
      urgency: p.urgency!,
    );
  }
  
  String get existingLoansDisplay {
    if (!hasExistingLoans) return 'No';
    if (numberOfLoans != null && totalEmi != null) {
      return 'Yes ($numberOfLoans loans, ₹${totalEmi!.toInt()} EMI)';
    }
    return 'Yes';
  }
}

extension LoanPurposeLabel on LoanPurpose {
  String label(AppLocalizations l10n) => switch (this) {
        LoanPurpose.personalExpenses => 'Personal Expenses',
        LoanPurpose.homePurchase => 'Home Purchase',
        LoanPurpose.vehiclePurchase => 'Vehicle Purchase',
        LoanPurpose.education => 'Education',
        LoanPurpose.business => 'Business',
        LoanPurpose.debit => 'Debt Consolidation',
        LoanPurpose.other => 'Other',
      };

  // SvgGenImage get icon => switch (this) {
  //       LoanPurpose.personalExpenses => Assets.loanFinder.icPersonalExpenses,
  //       LoanPurpose.homePurchase => Assets.loanFinder.icHomePurchase,
  //       LoanPurpose.vehiclePurchase => Assets.loanFinder.icVehiclePurchase,
  //       LoanPurpose.education => Assets.loanFinder.icEducation,
  //       LoanPurpose.business => Assets.loanFinder.icBusiness,
  //       LoanPurpose.medicalEmergency => Assets.loanFinder.icMedicalEmerg,
  //       LoanPurpose.other => Assets.loanFinder.icOther,
  //     };
}

extension EmploymentStatusLabel on EmploymentStatus {
  String label(AppLocalizations l10n) => switch (this) {
        EmploymentStatus.salaried => 'Salaried',
        EmploymentStatus.selfEmployed => 'Self-Employed',
        EmploymentStatus.businessOwner => 'Business Owner',
        EmploymentStatus.professional => 'Professional',
        EmploymentStatus.retired => 'Retired',
        EmploymentStatus.other => 'Other',
      };

  // SvgGenImage get icon => switch (this) {
  //       EmploymentStatus.salaried => Assets.loanFinder.icSalaried,
  //       EmploymentStatus.selfEmployed => Assets.loanFinder.icSelfemployed,
  //       EmploymentStatus.businessOwner => Assets.loanFinder.icBusinessOwner,
  //       EmploymentStatus.professional => Assets.loanFinder.icProfessional,
  //       EmploymentStatus.retired => Assets.loanFinder.icRetired,
  //       EmploymentStatus.other => Assets.loanFinder.icOther,
  //     };
}

extension CreditScoreLabel on CreditScoreRange {
  String label(AppLocalizations l10n) => switch (this) {
        CreditScoreRange.excellent => 'Excellent (750+)',
        CreditScoreRange.good => 'Good (700-750)',
        CreditScoreRange.fair => 'Fair (650-700)',
        CreditScoreRange.poor => 'Poor (Below 650)',
        CreditScoreRange.dontKnow => 'Don\'t Know',
      };
}

extension ExistingLoanLabel on ExistingLoan {
  String label(AppLocalizations l10n) => switch (this) {
        ExistingLoan.personal => 'Personal Loan',
        ExistingLoan.home => 'Home Loan',
        ExistingLoan.car => 'Car Loan',
        ExistingLoan.creditCard => 'Credit Card',
        ExistingLoan.none => 'None',
      };
}

extension LoanUrgencyLabel on LoanUrgency {
  String label(AppLocalizations l10n) => switch (this) {
        LoanUrgency.immediately => 'Immediately (1-3 days)',
        LoanUrgency.withinWeek => 'Within a week',
        LoanUrgency.withinMonth => 'Within a month',
        LoanUrgency.flexible => 'Flexible',
      };
}

extension ExistingLoansSetLabel on Set<ExistingLoan> {
  String displayLabel(AppLocalizations l10n) {
    if (isEmpty) return '—';
    return map((e) => e.label(l10n)).join(', ');
  }
}
