import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

enum LoanType { homeLoan, personalLoan, carLoan, educationLoan, businessLoan, creditCard }

class LoanFeature {
  const LoanFeature(this.title, this.subtitle, this.iconPath);
  final String title;
  final String subtitle;
  final String iconPath;
}

class LoanStep {
  const LoanStep(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

class LoanDetailData {
  const LoanDetailData({
    required this.type,
    required this.title,
    required this.description,
    required this.features,
    required this.useCases,
    required this.steps,
    required this.processButtonLabel,
    required this.themeColor,
    required this.gradientColors,
  });

  final LoanType type;
  final String title;
  final String description;
  final List<LoanFeature> features;
  final List<String> useCases;
  final List<LoanStep> steps;
  final String processButtonLabel;
  final Color themeColor;
  final List<Color> gradientColors;

  static LoanDetailData forType(LoanType type, AppLocalizations l10n) {
    switch (type) {
      case LoanType.personalLoan:
        return LoanDetailData(
          type: LoanType.personalLoan,
          title: l10n.homeLoanPersonal,
          description: l10n.loanPersonalDesc,
          features: [
            LoanFeature(l10n.loanPersonalF1Title, l10n.loanPersonalF1Subtitle,
                'assets/personal_loan_icons/ic_instant_approval.svg'),
            LoanFeature(l10n.loanPersonalF2Title, l10n.loanPersonalF2Subtitle,
                'assets/personal_loan_icons/ic_secure.svg'),
            LoanFeature(l10n.loanPersonalF3Title, l10n.loanPersonalF3Subtitle,
                'assets/onboarding_icons/ic_currency.svg'),
            LoanFeature(l10n.loanPersonalF4Title, l10n.loanPersonalF4Subtitle,
                'assets/personal_loan_icons/ic_clock.svg'),
          ],
          useCases: [
            l10n.loanPersonalUseCase1,
            l10n.loanPersonalUseCase2,
            l10n.loanPersonalUseCase3,
            l10n.loanPersonalUseCase4,
            l10n.loanPersonalUseCase5,
            l10n.loanPersonalUseCase6,
          ],
          steps: [
            LoanStep(l10n.loanCarStep2Title, l10n.loanPersonalStep1Subtitle),
            LoanStep(l10n.loanCarStep3Title, l10n.loanPersonalStep2Subtitle),
            LoanStep(l10n.loanPersonalStep3Title, l10n.loanPersonalStep3Subtitle),
            LoanStep(l10n.loanPersonalStep4Title, l10n.loanPersonalStep4Subtitle),
          ],
          processButtonLabel: l10n.fdViewStepsButton,
          themeColor: const Color(0xFF2563EB),
          gradientColors: const [Color(0xFF2563EB), Color(0xFF153885)],
        );

      case LoanType.homeLoan:
        return LoanDetailData(
          type: LoanType.homeLoan,
          title: l10n.homeLoanHome,
          description: l10n.loanHomeDesc,
          features: [
            LoanFeature(l10n.loanHomeF1Title, l10n.loanHomeF1Subtitle,
                'assets/personal_loan_icons/ic_payment_breakdown.svg'),
            LoanFeature(l10n.loanHomeF2Title, l10n.loanHomeF2Subtitle,
                'assets/onboarding_icons/ic_currency.svg'),
            LoanFeature(l10n.loanHomeF3Title, l10n.loanHomeF3Subtitle,
                'assets/personal_loan_icons/ic_calendar.svg'),
            LoanFeature(l10n.loanHomeF4Title, l10n.loanHomeF4Subtitle,
                'assets/home_icons/ic_documents.svg'),
          ],
          useCases: [
            l10n.loanHomeUseCase1,
            l10n.loanHomeUseCase2,
            l10n.loanHomeUseCase3,
            l10n.loanHomeUseCase4,
            l10n.loanHomeUseCase5,
            l10n.loanHomeUseCase6,
          ],
          steps: [
            LoanStep(l10n.loanCarStep2Title, l10n.loanHomeStep1Subtitle),
            LoanStep(l10n.loanHomeStep2Title, l10n.loanHomeStep2Subtitle),
            LoanStep(l10n.loanCarStep3Title, l10n.loanHomeStep3Subtitle),
            LoanStep(l10n.loanHomeStep4Title, l10n.loanHomeStep4Subtitle),
          ],
          processButtonLabel: l10n.fdViewStepsButton,
          themeColor: const Color(0xFF0D9488),
          gradientColors: const [Color(0xFF0D9488), Color(0xFF065E55)],
        );

      case LoanType.carLoan:
        return LoanDetailData(
          type: LoanType.carLoan,
          title: l10n.homeLoanCar,
          description: l10n.loanCarDesc,
          features: [
            LoanFeature(l10n.loanCarF1Title, l10n.loanCarF1Subtitle,
                'assets/personal_loan_icons/ic_instant_approval.svg'),
            LoanFeature(l10n.loanCarF2Title, l10n.loanCarF2Subtitle,
                'assets/onboarding_icons/ic_vehicle.svg'),
            LoanFeature(l10n.loanCarF3Title, l10n.loanCarF3Subtitle,
                'assets/onboarding_icons/ic_currency.svg'),
            LoanFeature(l10n.loanCarF4Title, l10n.loanCarF4Subtitle,
                'assets/personal_loan_icons/ic_calendar.svg'),
          ],
          useCases: [
            l10n.loanCarUseCase1,
            l10n.loanCarUseCase2,
            l10n.loanCarUseCase3,
            l10n.loanCarUseCase4,
            l10n.loanCarUseCase5,
            l10n.loanCarUseCase6,
          ],
          steps: [
            LoanStep(l10n.loanCarStep1Title, l10n.loanCarStep1Subtitle),
            LoanStep(l10n.loanCarStep2Title, l10n.loanCarStep2Subtitle),
            LoanStep(l10n.loanCarStep3Title, l10n.loanCarStep3Subtitle),
            LoanStep(l10n.loanCarStep4Title, l10n.loanCarStep4Subtitle),
          ],
          processButtonLabel: l10n.fdViewStepsButton,
          themeColor: const Color(0xFF0D9488),
          gradientColors: const [Color(0xFF0D9488), Color(0xFF065E55)],
        );

      case LoanType.educationLoan:
        return LoanDetailData(
          type: LoanType.educationLoan,
          title: l10n.homeLoanEducation,
          description: l10n.loanEducationDesc,
          features: [
            LoanFeature(l10n.loanEducationF1Title, l10n.loanEducationF1Subtitle,
                'assets/personal_loan_icons/ic_clock.svg'),
            LoanFeature(l10n.loanHomeF4Title, l10n.loanEducationF2Subtitle,
                'assets/home_icons/ic_documents.svg'),
            LoanFeature(l10n.loanEducationF3Title, l10n.loanEducationF3Subtitle,
                'assets/onboarding_icons/ic_education.svg'),
            LoanFeature(l10n.loanPersonalF2Title, l10n.loanEducationF4Subtitle,
                'assets/personal_loan_icons/ic_secure.svg'),
          ],
          useCases: [
            l10n.loanEducationUseCase1,
            l10n.loanEducationUseCase2,
            l10n.loanEducationUseCase3,
            l10n.loanEducationUseCase4,
            l10n.loanEducationUseCase5,
            l10n.loanEducationUseCase6,
          ],
          steps: [
            LoanStep(l10n.loanEducationStep1Title, l10n.loanEducationStep1Subtitle),
            LoanStep(l10n.loanEducationStep2Title, l10n.loanEducationStep2Subtitle),
            LoanStep(l10n.loanEducationStep3Title, l10n.loanEducationStep3Subtitle),
            LoanStep(l10n.loanHomeStep4Title, l10n.loanEducationStep4Subtitle),
          ],
          processButtonLabel: l10n.fdViewStepsButton,
          themeColor: const Color(0xFFD97706),
          gradientColors: const [Color(0xFFD97706), Color(0xFF92400E)],
        );

      case LoanType.businessLoan:
        return LoanDetailData(
          type: LoanType.businessLoan,
          title: l10n.homeLoanBusiness,
          description: l10n.loanBusinessDesc,
          features: [
            LoanFeature(l10n.loanHomeF2Title, l10n.loanBusinessF1Subtitle,
                'assets/onboarding_icons/ic_currency.svg'),
            LoanFeature(l10n.loanBusinessF2Title, l10n.loanBusinessF2Subtitle,
                'assets/personal_loan_icons/ic_instant_approval.svg'),
            LoanFeature(l10n.loanBusinessF3Title, l10n.loanBusinessF3Subtitle,
                'assets/personal_loan_icons/ic_secure.svg'),
            LoanFeature(l10n.loanBusinessF4Title, l10n.loanBusinessF4Subtitle,
                'assets/personal_loan_icons/ic_calendar.svg'),
          ],
          useCases: [
            l10n.loanBusinessUseCase1,
            l10n.loanBusinessUseCase2,
            l10n.loanBusinessUseCase3,
            l10n.loanBusinessUseCase4,
            l10n.loanBusinessUseCase5,
            l10n.loanBusinessUseCase6,
          ],
          steps: [
            LoanStep(l10n.loanBusinessStep1Title, l10n.loanBusinessStep1Subtitle),
            LoanStep(l10n.loanBusinessStep2Title, l10n.loanBusinessStep2Subtitle),
            LoanStep(l10n.loanBusinessStep3Title, l10n.loanBusinessStep3Subtitle),
            LoanStep(l10n.loanBusinessStep4Title, l10n.loanBusinessStep4Subtitle),
          ],
          processButtonLabel: l10n.fdViewStepsButton,
          themeColor: const Color(0xFF7C3AED),
          gradientColors: const [Color(0xFF7C3AED), Color(0xFF4C1D95)],
        );

      case LoanType.creditCard:
        return LoanDetailData(
          type: LoanType.creditCard,
          title: l10n.loanCreditCardTitle,
          description: l10n.loanCreditCardDesc,
          features: [
            LoanFeature(l10n.loanPersonalF1Title, l10n.loanCreditCardF1Subtitle,
                'assets/personal_loan_icons/ic_instant_approval.svg'),
            LoanFeature(l10n.loanPersonalF3Title, l10n.loanCreditCardF2Subtitle,
                'assets/home_icons/ic_credit_card.svg'),
            LoanFeature(l10n.loanCreditCardF3Title, l10n.loanCreditCardF3Subtitle,
                'assets/personal_loan_icons/ic_calendar.svg'),
            LoanFeature(l10n.loanPersonalF2Title, l10n.loanCreditCardF4Subtitle,
                'assets/personal_loan_icons/ic_secure.svg'),
          ],
          useCases: [
            l10n.loanCreditCardUseCase1,
            l10n.loanCreditCardUseCase2,
            l10n.loanCreditCardUseCase3,
            l10n.loanPersonalUseCase5,
            l10n.loanCreditCardUseCase5,
            l10n.loanPersonalUseCase4,
          ],
          steps: [
            LoanStep(l10n.loanCreditCardStep1Title, l10n.loanCreditCardStep1Subtitle),
            LoanStep(l10n.loanCreditCardStep2Title, l10n.loanCreditCardStep2Subtitle),
            LoanStep(l10n.loanCreditCardStep3Title, l10n.loanCreditCardStep3Subtitle),
            LoanStep(l10n.loanCreditCardStep4Title, l10n.loanCreditCardStep4Subtitle),
          ],
          processButtonLabel: l10n.fdViewStepsButton,
          themeColor: const Color(0xFFDC2626),
          gradientColors: const [Color(0xFFDC2626), Color(0xFF991B1B)],
        );
    }
  }
}
