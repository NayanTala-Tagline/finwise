import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
 import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../gen/assets.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_textfield.dart';
import 'provider/loan_finder_ad_provider.dart';
import 'provider/loan_finder_provider.dart';
import 'widgets/loan_finder_layout.dart';
import 'widgets/loan_finder_option_tile.dart';

class ExistingLoansScreen extends StatefulWidget {
  const ExistingLoansScreen({super.key, this.inlineAd});

  /// Native preloaded by the previous step's ad provider — owned and disposed
  /// by this screen.
  final InlineAdManager? inlineAd;

  @override
  State<ExistingLoansScreen> createState() => _ExistingLoansScreenState();
}

class _ExistingLoansScreenState extends State<ExistingLoansScreen> {
  bool? _hasExistingLoans;
  final TextEditingController _numberOfLoansController = TextEditingController();
  final TextEditingController _totalEmiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'existing_loans_screen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LoanFinderAdProvider>().preloadAfterStep(5);
    });
  }

  @override
  void dispose() {
    _numberOfLoansController.dispose();
    _totalEmiController.dispose();
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  void _next() {
    final formProvider = context.read<LoanFinderProvider>();
    
    if (_hasExistingLoans == null) {
      AnalyticsManager.instance.logEvent(
        name: 'loan_finder_validation_failed',
        parameters: const {'step': 6, 'field': 'existing_loans'},
      );
      'Please select Yes or No'.showErrorAlert();
      return;
    }
    
    // Save to provider
    formProvider.setHasExistingLoans(_hasExistingLoans!);
    
    if (_hasExistingLoans == true) {
      if (_numberOfLoansController.text.isEmpty) {
        'Please enter number of existing loans'.showErrorAlert();
        return;
      }
      if (_totalEmiController.text.isEmpty) {
        'Please enter approximate total EMI'.showErrorAlert();
        return;
      }
      
      formProvider.setNumberOfLoans(int.parse(_numberOfLoansController.text));
      formProvider.setTotalEmi(double.parse(_totalEmiController.text));
    }
    
    AnalyticsManager.instance.logEvent(
      name: 'loan_finder_next',
      parameters: {
        'step': 6,
        'has_existing_loans': ?_hasExistingLoans,
        if (_hasExistingLoans == true) ...{
          'number_of_loans': _numberOfLoansController.text,
          'total_emi': _totalEmiController.text,
        },
      },
    );
    context.read<LoanFinderAdProvider>().next(context, AppRoutes.loanUrgency);
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = context.watch<LoanFinderAdProvider>();
    
    return LoanFinderLayout(
      stepIndex: 5,
      title: 'Do you have any\nexisting loans?',
      subtitle: 'This helps us understand your financial obligations',
      isLoading: adProvider.busy,
      adSlot: AdSlot(ad: widget.inlineAd),
      onNextPressed: _next,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.w5,
          vertical: AppSize.h16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Yes/No buttons
            Row(
              children: [
                Expanded(
                  child: _OptionButton(
                    label: 'Yes',
                    subtitle: 'I have existing\nloans',
                    selected: _hasExistingLoans == true,
                    onTap: () {
                      setState(() {
                        _hasExistingLoans = true;
                      });
                      AnalyticsManager.instance.logEvent(
                        name: 'loan_finder_option_selected',
                        parameters: {'step': 6, 'has_loans': true},
                      );
                    },
                  ),
                ),
                SizedBox(width: AppSize.w16),
                Expanded(
                  child: _OptionButton(
                    label: 'No',
                    subtitle: 'No current loans',
                    selected: _hasExistingLoans == false,
                    onTap: () {
                      setState(() {
                        _hasExistingLoans = false;
                        _numberOfLoansController.clear();
                        _totalEmiController.clear();
                      });
                      AnalyticsManager.instance.logEvent(
                        name: 'loan_finder_option_selected',
                        parameters: {'step': 6, 'has_loans': false},
                      );
                    },
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0, delay: 300.ms, duration: 500.ms),
            
            // Text fields (shown when Yes is selected)
            if (_hasExistingLoans == true) ...[
              SizedBox(height: AppSize.h24),
              AppTextFormField(
                title: 'Number of existing loans',
                controller: _numberOfLoansController,
                keyboardType: TextInputType.number,
                hintText: 'Enter number of loans',
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 500.ms),
              SizedBox(height: AppSize.h20),
              AppTextFormField(
                title: 'Approximate total EMI (monthly)',
                controller: _totalEmiController,
                keyboardType: TextInputType.number,
                hintText: 'Enter total EMI amount',
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, delay: 300.ms, duration: 500.ms),
            ],
          ],
        ),
      ),
    );
  }
}

// Custom option button widget
class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          height: AppSize.h110,
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.w20,
            vertical: AppSize.h16,
          ),
          decoration: BoxDecoration(
              gradient: selected ? LinearGradient(colors: [context.themeColors.primary,Color(0xff153885),]) : LinearGradient(colors: [Colors.white,Color(0xffE7F1FF),]),
              borderRadius: BorderRadius.circular(AppSize.r20),
            border: Border.all(
              color: selected ? colors.primary : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffFF8F4A).withValues(alpha: 0.12),
                blurRadius: AppSize.r16,
                offset: Offset(0, AppSize.h2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
             children: [
              Text(
                label,
                style: context.textTheme.titleLarge?.copyWith(
                  color: selected ? Colors.white : textColors.textColor,
                  fontSize: AppSize.sp18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSize.h8),
              Text(
                subtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? Colors.white.withOpacity(0.9)
                      : textColors.descriptionColor,
                  fontSize: AppSize.sp13,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
