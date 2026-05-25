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
  });

  final LoanType type;
  final String title;
  final String description;
  final List<LoanFeature> features;
  final List<String> useCases;
  final List<LoanStep> steps;
  final String processButtonLabel;

  static LoanDetailData forType(LoanType type) {
    switch (type) {
      case LoanType.personalLoan:
        return const LoanDetailData(
          type: LoanType.personalLoan,
          title: 'Personal Loan',
          description: 'Get instant funds for any personal need with minimal documentation and quick approval.',
          features: [
            LoanFeature('Instant Approval', 'Get approved within 24 hours with minimal paperwork',
                'assets/personal_loan_icons/ic_instant_approval.svg'),
            LoanFeature('No Collateral', 'Unsecured loans without asset requirement',
                'assets/personal_loan_icons/ic_secure.svg'),
            LoanFeature('Flexible Amount', 'Borrow ₹50K to ₹25L based on eligibility',
                'assets/onboarding_icons/ic_currency.svg'),
            LoanFeature('Quick Disbursal', 'Funds in your account within 48 hours',
                'assets/personal_loan_icons/ic_clock.svg'),
          ],
          useCases: [
            'Wedding expenses and celebrations',
            'Medical emergencies and treatments',
            'Home renovation and repairs',
            'Debt consolidation',
            'Travel and vacation planning',
            'Electronics and appliances purchase',
          ],
          steps: [
            LoanStep('Check Eligibility', 'Use our calculator to check your loan eligibility and EMI amount'),
            LoanStep('Submit Documents', 'Provide PAN, Aadhaar, salary slips, and bank statements'),
            LoanStep('Get Approved', 'Receive instant approval based on your credit score and income'),
            LoanStep('Receive Funds', 'Loan amount disbursed directly to your bank account'),
          ],
          processButtonLabel: 'View Application Steps',
        );

      case LoanType.homeLoan:
        return const LoanDetailData(
          type: LoanType.homeLoan,
          title: 'Home Loan',
          description: 'Finance your dream home with competitive interest rates and flexible repayment options up to 30 years.',
          features: [
            LoanFeature('Low Interest Rate', 'Starting from 8.5% per annum for eligible borrowers',
                'assets/personal_loan_icons/ic_payment_breakdown.svg'),
            LoanFeature('High Loan Amount', 'Finance up to 90% of the property value',
                'assets/onboarding_icons/ic_currency.svg'),
            LoanFeature('Long Tenure', 'Repayment period of up to 30 years',
                'assets/personal_loan_icons/ic_calendar.svg'),
            LoanFeature('Tax Benefits', 'Save tax under Section 80C and 24(b)',
                'assets/home_icons/ic_documents.svg'),
          ],
          useCases: [
            'Ready-to-move property purchase',
            'Under-construction flat or house',
            'Residential plot purchase',
            'Home construction on own plot',
            'Home extension or renovation',
            'Balance transfer from other banks',
          ],
          steps: [
            LoanStep('Check Eligibility', 'Verify your eligibility and estimate your home loan amount'),
            LoanStep('Choose Property', 'Finalise and get the property legally verified'),
            LoanStep('Submit Documents', 'Provide income, KYC, and property documents'),
            LoanStep('Get Disbursed', 'Loan disbursed directly to the builder or seller'),
          ],
          processButtonLabel: 'View Application Steps',
        );

      case LoanType.carLoan:
        return const LoanDetailData(
          type: LoanType.carLoan,
          title: 'Car Loan',
          description: 'Drive home your dream car with quick approvals, competitive rates, and financing up to 100% on-road price.',
          features: [
            LoanFeature('Quick Approval', 'In-principle approval within 30 minutes',
                'assets/personal_loan_icons/ic_instant_approval.svg'),
            LoanFeature('High Financing', 'Up to 100% on-road price for select models',
                'assets/onboarding_icons/ic_vehicle.svg'),
            LoanFeature('Low Interest', 'Starting from 7% per annum for new cars',
                'assets/onboarding_icons/ic_currency.svg'),
            LoanFeature('Flexible Tenure', 'Choose 12 to 84 months repayment period',
                'assets/personal_loan_icons/ic_calendar.svg'),
          ],
          useCases: [
            'Brand new car purchase',
            'Pre-owned vehicle financing',
            'Electric vehicle with special rates',
            'Two-wheeler financing',
            'Luxury car and SUV purchase',
            'Commercial vehicle for business',
          ],
          steps: [
            LoanStep('Choose Vehicle', 'Finalise the car make, model, and variant'),
            LoanStep('Check Eligibility', 'Verify your eligibility and required EMI amount'),
            LoanStep('Submit Documents', 'Provide KYC, income, and vehicle documents'),
            LoanStep('Drive Home', 'Loan disbursed directly to the dealer'),
          ],
          processButtonLabel: 'View Application Steps',
        );

      case LoanType.educationLoan:
        return const LoanDetailData(
          type: LoanType.educationLoan,
          title: 'Education Loan',
          description: 'Invest in your future with education loans covering tuition, living expenses, and all study-related costs.',
          features: [
            LoanFeature('Moratorium Period', 'Start repaying 6–12 months after course completion',
                'assets/personal_loan_icons/ic_clock.svg'),
            LoanFeature('Tax Benefits', 'Full interest deduction under Section 80E',
                'assets/home_icons/ic_documents.svg'),
            LoanFeature('Full Coverage', 'Tuition, hostel, books, laptop, and travel',
                'assets/onboarding_icons/ic_education.svg'),
            LoanFeature('No Collateral', 'Available for loans up to ₹7.5 lakh',
                'assets/personal_loan_icons/ic_secure.svg'),
          ],
          useCases: [
            'Undergraduate degree programs',
            'Postgraduate and MBA programs',
            'Study abroad at top universities',
            'Professional courses (CA, MBBS, Law)',
            'Vocational and diploma courses',
            'School education financing',
          ],
          steps: [
            LoanStep('Secure Admission', 'Obtain admission letter from the institution'),
            LoanStep('Apply for Loan', 'Submit application with all required documents'),
            LoanStep('Document Verification', 'Bank verifies academic and financial documents'),
            LoanStep('Get Disbursed', 'Payment sent directly to the institution'),
          ],
          processButtonLabel: 'View Application Steps',
        );

      case LoanType.businessLoan:
        return const LoanDetailData(
          type: LoanType.businessLoan,
          title: 'Business Loan',
          description: 'Grow your business with quick financing for working capital, expansion, and equipment purchase needs.',
          features: [
            LoanFeature('High Loan Amount', 'Up to ₹5 crore for SMEs and MSMEs',
                'assets/onboarding_icons/ic_currency.svg'),
            LoanFeature('Quick Processing', 'Loan decision within 3–5 working days',
                'assets/personal_loan_icons/ic_instant_approval.svg'),
            LoanFeature('Minimal Collateral', 'Unsecured options for eligible businesses',
                'assets/personal_loan_icons/ic_secure.svg'),
            LoanFeature('Flexible Repayment', 'Monthly, quarterly, or bullet payment options',
                'assets/personal_loan_icons/ic_calendar.svg'),
          ],
          useCases: [
            'Working capital management',
            'Business expansion and scaling',
            'Machinery and equipment purchase',
            'Inventory and stock financing',
            'Office setup and renovation',
            'Technology and software upgrade',
          ],
          steps: [
            LoanStep('Business Assessment', 'Evaluate your exact financial requirement'),
            LoanStep('Apply Online', 'Submit application with business documentation'),
            LoanStep('Verification', 'Bank verifies financials and business details'),
            LoanStep('Get Funded', 'Amount disbursed to your business account'),
          ],
          processButtonLabel: 'View Application Steps',
        );

      case LoanType.creditCard:
        return const LoanDetailData(
          type: LoanType.creditCard,
          title: 'Credit Card Loan',
          description: 'Get instant funds against your credit card limit with flexible EMI options and no documentation required.',
          features: [
            LoanFeature('Instant Approval', 'No additional documentation required',
                'assets/personal_loan_icons/ic_instant_approval.svg'),
            LoanFeature('Flexible Amount', 'Based on available credit card limit',
                'assets/home_icons/ic_credit_card.svg'),
            LoanFeature('EMI Options', 'Choose 3, 6, 12, 24, or 36 months tenure',
                'assets/personal_loan_icons/ic_calendar.svg'),
            LoanFeature('No Collateral', 'Completely unsecured credit product',
                'assets/personal_loan_icons/ic_secure.svg'),
          ],
          useCases: [
            'Emergency and urgent expenses',
            'Shopping and retail purchases',
            'Home appliances and electronics',
            'Travel and vacation planning',
            'Medical and healthcare expenses',
            'Debt consolidation',
          ],
          steps: [
            LoanStep('Check Offer', 'View pre-approved offer on app or net banking'),
            LoanStep('Select Amount', 'Choose loan amount within your eligible limit'),
            LoanStep('Confirm Terms', 'Review processing fee and total cost of loan'),
            LoanStep('Instant Credit', 'Amount credited to your account immediately'),
          ],
          processButtonLabel: 'View Application Steps',
        );
    }
  }
}
