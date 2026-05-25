
import 'package:finwise/extension/ext_context.dart';
import 'package:finwise/features/loan_detail/model/loan_detail_data.dart';
import 'package:finwise/gen/assets.gen.dart';
import 'package:finwise/routes/app_router.dart';
import 'package:finwise/utils/anaytics_manager.dart';
import 'package:finwise/utils/app_size.dart';
import 'package:finwise/utils/navigation_helper.dart';
import 'package:finwise/widgets/app_button.dart';
import 'package:finwise/widgets/app_summary_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'provider/home_notification_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeNotificationProvider>(
      create: (_) => HomeNotificationProvider(),
      child: const _HomeScreenView(),
    );
  }
}

class _HomeScreenView extends StatelessWidget {
  const _HomeScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.backgroundColor,
      body: Column(
        children: [
          const _HomeHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSize.appPadding,
                AppSize.h20,
                AppSize.appPadding,
                AppSize.h20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    title: 'Loan Tools',
                    subtitle: 'Calculate EMI and compare loan options',
                  ),
                  SizedBox(height: AppSize.h16),
                  const _LoanTypesGrid(),
                  SizedBox(height: AppSize.h20),
                  const _SectionTitle(
                    title: 'Investment Tools',
                    subtitle: 'Plan your savings and investments',
                  ),
                  SizedBox(height: AppSize.h16),
                  const _InvestmentRow(),
                  SizedBox(height: AppSize.h20),
                  const _SectionTitle(
                    title: 'Helpful Resources',
                    subtitle: 'Everything you need to know',
                  ),
                  SizedBox(height: AppSize.h16),
                  _ResourceTile(
                    icon: Assets.homeIcons.icDocuments,
                    title: 'Documents Required',
                    subtitle: 'Complete checklist for loans',
                    iconBgColor: const Color(0xFF2563EB).withValues(alpha: 0.08),
                    iconColor: const Color(0xFF2563EB),
                    onTap: () {
                      AnalyticsManager.instance.logEvent(
                        name: 'home_resource_tap',
                        parameters: const {'resource': 'documents_required'},
                      );
                      NavigationHelper().navigateWithAdCheck(context, () {
                        context.pushNamed(AppRoutes.documentRequired);
                      });
                    },
                  ),
                  SizedBox(height: AppSize.h12),
                  _ResourceTile(
                    icon: Assets.onboardingIcons.icMakeSmart,
                    title: 'Tips & Advice',
                    subtitle: 'Expert financial guidance',
                    iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                    iconColor: const Color(0xFFF59E0B),
                    onTap: () {
                      AnalyticsManager.instance.logEvent(
                        name: 'home_resource_tap',
                        parameters: const {'resource': 'tips_advice'},
                      );
                      NavigationHelper().navigateWithAdCheck(context, () {
                        context.pushNamed(AppRoutes.tipsAdvice);
                      });
                    },
                  ),
                  SizedBox(height: AppSize.h8),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return AppSummaryBackground(
      gradientColors: const [Color(0xFF1A55C4), Color(0xFF3B82F6)],
      useImage: true,
      imagePath: 'assets/images/splash_screen.png',
      imageOpacity: 0.15,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSize.appPadding,
            AppSize.h16,
            AppSize.appPadding,
            AppSize.h24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back to,',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: AppSize.sp13,
                          ),
                        ),
                        Text(
                          'FinWise',
                          style: context.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: AppSize.sp28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Assets.images.splashScreenLogo.image(
                    width: AppSize.w80,
                    height: AppSize.h80,
                    fit: BoxFit.contain
                  ),
                ],
              ),
               Container(
                padding: EdgeInsets.all(AppSize.h16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSize.r16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Action',
                              style: context.textTheme.titleSmall?.copyWith(
                                color: context.themeTextColors.descriptionColor,
                                fontSize: AppSize.sp12,
                              ),
                            ),
                            Text(
                              'Find Your Perfect Loan',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: AppSize.sp16,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(AppSize.sp10),
                          decoration: BoxDecoration(
                            color: Color(0xff0D9488).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppSize.r10)
                          ),
                          child: Assets.homeIcons.icStars.svg(

                            colorFilter: ColorFilter.mode(Color(0xff0D9488), BlendMode.srcIn)
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSize.h12),
                    AppButton(
                      text: 'Start Smart Match',
                      backgroundColor: const Color(0xFF2563EB),
                      borderRadius: AppSize.r50,
                      suffixIcon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                      onPressed: () {
                        NavigationHelper().navigateWithAdCheck(context, () {
                          context.pushNamed(AppRoutes.loanPurpose);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: AppSize.sp18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppSize.h2),
        Text(
          subtitle,
          style: context.textTheme.titleSmall?.copyWith(
            fontSize: AppSize.sp13,
            color: context.themeTextColors.descriptionColor,
          ),
        ),
      ],
    );
  }
}

// ── Shared shadow decoration ──────────────────────────────────────────────────

BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
      color: context.themeColors.whiteColor,
      borderRadius: BorderRadius.circular(AppSize.r12),
      boxShadow:   [
        BoxShadow(
          color: Color(0xff000000).withValues(alpha: 0.1),
          blurRadius: AppSize.r3,
          spreadRadius: AppSize.sp1,
          offset: Offset(0, 1),
        ),
      ],
    );

// ── Loan Types ────────────────────────────────────────────────────────────────

class _LoanTypeItem {
  const _LoanTypeItem(
      this.title, this.subtitle, this.icon, this.loanType, this.iconBgColor, this.iconColor);

  final String title;
  final String subtitle;
  final SvgGenImage icon;
  final LoanType loanType;
  final Color iconBgColor;
  final Color iconColor;
}

class _LoanTypesGrid extends StatelessWidget {
  const _LoanTypesGrid();

  @override
  Widget build(BuildContext context) {
    final loans = [
      _LoanTypeItem('Personal Loan', 'Quick loans for any need',
          Assets.homeIcons.icUser, LoanType.personalLoan,
          const Color(0xFFEEF2FF), const Color(0xFF2563EB)),
      _LoanTypeItem('Home Loan', 'Finance your dream home',
          Assets.onboardingIcons.icHome, LoanType.homeLoan,
          const Color(0xFF0D9488).withValues(alpha: 0.08), const Color(0xFF0D9488)),
      _LoanTypeItem('Car Loan', 'Drive your dream vehicle',
          Assets.onboardingIcons.icVehicle, LoanType.carLoan,
          const Color(0xFF0D9488).withValues(alpha: 0.08), const Color(0xFF0D9488)),
      _LoanTypeItem('Education Loan', 'Invest in your future',
          Assets.onboardingIcons.icEducation, LoanType.educationLoan,
          const Color(0xFFD97706).withValues(alpha: 0.08), const Color(0xFFD97706)),
      _LoanTypeItem('Business Loan', 'Grow your enterprise',
          Assets.onboardingIcons.icBusiness, LoanType.businessLoan,
          const Color(0xFF7C3AED).withValues(alpha: 0.08), const Color(0xFF7C3AED)),
      _LoanTypeItem('Credit Card', 'Compare best cards',
          Assets.homeIcons.icCreditCard, LoanType.creditCard,
          const Color(0xFFDC2626).withValues(alpha: 0.08), const Color(0xFFDC2626)),
    ];
    return Column(
      children: List.generate((loans.length / 2).ceil(), (rowIndex) {
        final leftIndex = rowIndex * 2;
        final rightIndex = leftIndex + 1;
        return Padding(
          padding: EdgeInsets.only(top: rowIndex > 0 ? AppSize.h12 : 0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _LoanTypeCard(item: loans[leftIndex])),
                SizedBox(width: AppSize.w12),
                Expanded(
                  child: rightIndex < loans.length
                      ? _LoanTypeCard(item: loans[rightIndex])
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _LoanTypeCard extends StatelessWidget {
  const _LoanTypeCard({required this.item});

  final _LoanTypeItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AnalyticsManager.instance.logEvent(
          name: 'home_loan_type_tap',
          parameters: {'loan_type': item.loanType.name},
        );
        NavigationHelper().navigateWithAdCheck(context, () {
          context.pushNamed(AppRoutes.loanDetail, extra: item.loanType);
        });
      },
      child: Container(
        padding: EdgeInsets.all(AppSize.h14),
        decoration: _cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSize.sp10),
              decoration: BoxDecoration(
                color: item.iconBgColor,
                borderRadius: BorderRadius.circular(AppSize.r10),
              ),
              child: item.icon.svg(width: AppSize.w24, height: AppSize.h24, colorFilter: ColorFilter.mode(item.iconColor, BlendMode.srcIn)),
            ),
            SizedBox(height: AppSize.h10),
            Text(
              item.title,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSize.h2),
            Text(
              item.subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: AppSize.sp12,
                color: context.themeTextColors.descriptionColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Investment ────────────────────────────────────────────────────────────────

class _InvestmentItem {
  const _InvestmentItem(
      this.title, this.subtitle, this.icon, this.route, this.iconBgColor, this.iconColor);
  final String title;
  final String subtitle;
  final SvgGenImage icon;
  final String route;
  final Color iconBgColor;
  final Color iconColor;
}

class _InvestmentRow extends StatelessWidget {
  const _InvestmentRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      _InvestmentItem('FD Calculator', 'Calculate deposit returns',
          Assets.homeIcons.icFdCalculator, AppRoutes.fixedDeposit,
          const Color(0xFF10B981).withValues(alpha: 0.08), const Color(0xFF10B981)),
      _InvestmentItem('RD Calculator', 'Plan recurring savings',
          Assets.homeIcons.icRdCalculator, AppRoutes.recurringDeposit,
          const Color(0xFF06B6D4).withValues(alpha: 0.08), const Color(0xFF06B6D4)),
    ];
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _InvestmentCard(item: items[0])),
          SizedBox(width: AppSize.w12),
          Expanded(child: _InvestmentCard(item: items[1])),
        ],
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  const _InvestmentCard({required this.item});

  final _InvestmentItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AnalyticsManager.instance.logEvent(
          name: 'home_investment_tap',
          parameters: {'investment': item.title.toLowerCase()},
        );
        NavigationHelper().navigateWithAdCheck(context, () {
          context.pushNamed(item.route);
        });
      },
      child: Container(
        padding: EdgeInsets.all(AppSize.h14),
        decoration: _cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSize.sp10),
              decoration: BoxDecoration(
                  color: item.iconBgColor,
                  borderRadius: BorderRadius.circular(AppSize.r10)
              ),
              child: item.icon.svg(width: AppSize.w24, height: AppSize.h24, colorFilter: ColorFilter.mode(item.iconColor, BlendMode.srcIn)),
            ),
            SizedBox(height: AppSize.h10),
            Text(
              item.title,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSize.h2),
            Text(
              item.subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: AppSize.sp12,
                color: context.themeTextColors.descriptionColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpful Resources ─────────────────────────────────────────────────────────

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.iconBgColor,
    required this.iconColor,
  });

  final SvgGenImage icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconBgColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSize.r12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.w16,
            vertical: AppSize.h14,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.sp10),
                decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(AppSize.r10)
                ),
                child: Center(child: icon.svg(width: AppSize.w22, height: AppSize.h22, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn))),
              ),
              SizedBox(width: AppSize.w14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSize.h2),
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: AppSize.sp12,
                        color: context.themeTextColors.descriptionColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}
