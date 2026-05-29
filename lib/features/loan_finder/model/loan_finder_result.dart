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
  
  String existingLoansDisplay(AppLocalizations l10n) {
    if (!hasExistingLoans) return l10n.existingLoansNo;
    if (numberOfLoans != null && totalEmi != null) {
      return l10n.existingLoansYesWithCount(numberOfLoans!, totalEmi!.toInt());
    }
    return l10n.existingLoansYes;
  }
}

extension LoanPurposeLabel on LoanPurpose {
  String label(AppLocalizations l10n) => switch (this) {
        LoanPurpose.personalExpenses => l10n.loanPurposePersonalExpenses,
        LoanPurpose.homePurchase => l10n.loanPurposeHomePurchase,
        LoanPurpose.vehiclePurchase => l10n.loanPurposeVehiclePurchase,
        LoanPurpose.education => l10n.onboarding1Education,
        LoanPurpose.business => l10n.onboarding1Business,
        LoanPurpose.debit => l10n.loanPurposeDebtConsolidation,
        LoanPurpose.other => l10n.loanPurposeOther,
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
        EmploymentStatus.salaried => l10n.employmentSalaried,
        EmploymentStatus.selfEmployed => l10n.employmentSelfEmployed,
        EmploymentStatus.businessOwner => l10n.employmentBusinessOwner,
        EmploymentStatus.professional => l10n.employmentProfessional,
        EmploymentStatus.retired => l10n.employmentRetired,
        EmploymentStatus.other => l10n.loanPurposeOther,
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
        CreditScoreRange.excellent => l10n.creditRangeExcellentFull,
        CreditScoreRange.good => l10n.creditRangeGoodFull,
        CreditScoreRange.fair => l10n.creditRangeFairFull,
        CreditScoreRange.poor => l10n.creditRangePoorFull,
        CreditScoreRange.dontKnow => l10n.creditScoreDontKnow,
      };
}

extension ExistingLoanLabel on ExistingLoan {
  String label(AppLocalizations l10n) => switch (this) {
        ExistingLoan.personal => l10n.homeLoanPersonal,
        ExistingLoan.home => l10n.homeLoanHome,
        ExistingLoan.car => l10n.homeLoanCar,
        ExistingLoan.creditCard => l10n.homeLoanCreditCard,
        ExistingLoan.none => l10n.creditScoreStep5InquiryNone,
      };
}

extension LoanUrgencyLabel on LoanUrgency {
  String label(AppLocalizations l10n) => switch (this) {
        LoanUrgency.immediately => l10n.loanUrgencyImmediatelyFull,
        LoanUrgency.withinWeek => l10n.loanUrgencyImmediatelyDesc,
        LoanUrgency.withinMonth => l10n.loanUrgencyWithinMonth,
        LoanUrgency.flexible => l10n.loanUrgencyFlexible,
      };
}

extension ExistingLoansSetLabel on Set<ExistingLoan> {
  String displayLabel(AppLocalizations l10n) {
    if (isEmpty) return '—';
    return map((e) => e.label(l10n)).join(', ');
  }
}
