import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_summary_background.dart';
import 'provider/compare_provider.dart';
import 'widgets/compare_result.dart';
import 'widgets/loan_card.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompareProvider(),
      child: const _CompareView(),
    );
  }
}

class _CompareView extends StatefulWidget {
  const _CompareView();

  @override
  State<_CompareView> createState() => _CompareViewState();
}

class _CompareViewState extends State<_CompareView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    final provider = context.watch<CompareProvider>();
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          AppSummaryBackground(
            gradientColors: const [Color(0xFF1A3C8F), Color(0xFF2D5BE3)],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppSize.r24),
              bottomRight: Radius.circular(AppSize.r24),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSize.w20,
                topPadding + AppSize.h16,
                AppSize.w20,
                AppSize.h24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  Text(
                    'Compare Loans',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontSize: AppSize.sp24,
                       color: Colors.white,
                    ),
                  ),
                  SizedBox(height: AppSize.h8),
                  Text(
                    'Find the best loan for your needs',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontSize: AppSize.sp13,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Scrollable Body ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                AppSize.w24,
                AppSize.h20,
                AppSize.w24,
                AppSize.h24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!provider.isCalculated) ...[
                    // Loan Cards
                    ...List.generate(provider.loanCount, (i) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppSize.h14),
                        child: LoanCard(
                          key: ValueKey(i),
                          index: i,
                          onDelete: i >= 2
                              ? () {
                                  AnalyticsManager.instance.logEvent(
                                    name: 'compare_remove_loan',
                                    parameters: {'index': i},
                                  );
                                  provider.removeLoan(i);
                                }
                              : null,
                        ),
                      );
                    }),

                    // Add Another Loan
                    if (provider.loanCount < 4) ...[
                      GestureDetector(
                        onTap: () {
                          AnalyticsManager.instance.logEvent(name: 'compare_add_loan');
                          provider.addLoan();
                        },
                        child: DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            radius: Radius.circular(AppSize.r14),
                            color: const Color(0xffC4CAD2),
                            strokeWidth: 1.5,
                            dashPattern: const [6, 4],
                          ),
                          child: Container(
                            height: AppSize.h50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSize.r14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: context.themeTextColors.descriptionColor,
                                  size: AppSize.sp20,
                                ),
                                SizedBox(width: AppSize.w8),
                                Text(
                                  'Add Another Loan',
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontSize: AppSize.sp14,
                                    color: context.themeTextColors.descriptionColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSize.h20),
                    ],

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Reset',
                            isOutlined: true,
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              AnalyticsManager.instance.logEvent(name: 'compare_refresh');
                              provider.refresh();
                            },
                          ),
                        ),
                         Expanded(
                          child: AppButton(
                            text: 'Compare',
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (!provider.isInputValid) {
                                AnalyticsManager.instance.logEvent(
                                  name: 'compare_validation_failed',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill at least 2 loans with valid values.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              AnalyticsManager.instance.logEvent(name: 'compare_calculate');
                              provider.calculate();
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollController.jumpTo(0);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Results
                  if (provider.isCalculated) ...[
                    KeyedSubtree(
                      key: _resultKey,
                      child: const CompareResult(),
                    ),
                    SizedBox(height: AppSize.h16),

                    // Start New
                    AppButton(
                      text: 'Start New',
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        AnalyticsManager.instance.logEvent(name: 'compare_refresh');
                        provider.refresh();
                        _scrollController.jumpTo(0);
                      },
                    ),
                  ],

                  SizedBox(height: AppSize.h16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
