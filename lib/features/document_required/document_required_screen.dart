import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';

import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_summary_background.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class _DocType {
  const _DocType({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.items,
  });

  final String title;
  final SvgGenImage icon;
  final Color iconColor;
  final Color bgColor;
  final List<String> items;
}

class _FormatItem {
  const _FormatItem(this.icon, this.label, this.value);

  final SvgGenImage icon;
  final String label;
  final String value;
}

class _StepItem {
  const _StepItem(this.title, this.description);

  final String title;
  final String description;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class DocumentRequiredScreen extends StatefulWidget {
  const DocumentRequiredScreen({super.key});

  @override
  State<DocumentRequiredScreen> createState() => _DocumentRequiredScreenState();
}

class _DocumentRequiredScreenState extends State<DocumentRequiredScreen> {
  InlineAdManager? _inlineAd;

  @override
  void initState() {
    super.initState();
    _loadInline();
  }

  void _loadInline() {
    final data = RemoteConfigService.instance.documentsNative;
    if (!data.enabled || data.adId.isEmpty) return;
    _inlineAd = InlineAdManager(adData: data);
    unawaited(_inlineAd!.load());
  }

  @override
  void dispose() {
    unawaited(_inlineAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: context.themeColors.backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(onBack: () => NavigationHelper().handleBackPress(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSize.w16,
                  AppSize.h20,
                  AppSize.w16,
                  AppSize.h24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeading(title: 'Why Documents Are Important'),
                    SizedBox(height: AppSize.h12),
                    _WhyImportantCard(),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: 'Essential Document Checklist'),
                    SizedBox(height: AppSize.h12),
                    _DocTypeCard(
                      doc: _DocType(
                        title: 'Identity Proof',
                        icon: Assets.homeIcons.icCreditCard,
                        iconColor: context.themeColors.primary,
                        bgColor: const Color(0xFFEEF2FF),
                        items: [
                          'Aadhaar Card',
                          'PAN Card',
                          'Voter ID Card',
                          'Driving Licence',
                          'Passport (valid)',
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.h12),
                    _DocTypeCard(
                      doc: _DocType(
                        title: 'Address Proof',
                        icon: Assets.onboardingIcons.icHome,
                        iconColor: const Color(0xFF0D9488),
                        bgColor: const Color(0xFF0D9488).withValues(alpha: 0.08),
                        items: [
                          'Bill not older than 3 months',
                          'Rental / Lease Agreement',
                          'Possession letter',
                          'Bank statement with address',
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.h12),
                    _DocTypeCard(
                      doc: _DocType(
                        title: 'Income Proof (Salaried)',
                        icon: Assets.homeIcons.icDocuments,
                        iconColor: const Color(0xFF10B981),
                        bgColor: const Color(0xFF10B981).withValues(alpha: 0.08),
                        items: [
                          "Last 3 months' salary slips",
                          'Last 2 ITR',
                          '6 months bank statements',
                          'Employment certificate',
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.h12),
                    _DocTypeCard(
                      doc: _DocType(
                        title: 'Income Proof (Self-Employed)',
                        icon: Assets.requiredDocuments.icIncomeProof,
                        iconColor: const Color(0xFF7C3AED),
                        bgColor: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                        items: [
                          'ITR last 2–3 years',
                          '12 months bank statements',
                          'GST if applicable',
                          'Audited financial statements',
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: 'Property Documents (Home Loan)'),
                    SizedBox(height: AppSize.h12),
                    _DocTypeCard1(
                      items: [
                        'Sale deed / Agreement to Sale',
                        'Property tax receipts',
                        'Encumbrance Certificate',
                        'Building plan approval',
                        'NOC from builder/society',
                        'Chain of title documents',
                      ],
                    ),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: 'Vehicle Documents (Car Loan)'),
                    SizedBox(height: AppSize.h12),
                    _DocTypeCard1(
                      items: [
                        'Proforma invoice from dealer',
                        'Insurance quotation',
                        'Registration Certificate (for used cars)',
                        'RC transfer documents',
                        'Transfer quotation',
                        'Road tax receipt',
                      ],
                    ),

                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: 'Document Format Requirements'),
                    SizedBox(height: AppSize.h12),
                    _FormatRequirementsCard(),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: 'Quality Requirements'),
                    SizedBox(height: AppSize.h12),
                    _QualityRequirementsCard(),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: 'Verification Process'),
                    SizedBox(height: AppSize.h12),
                    _VerificationProcessCard(),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: 'Common Mistakes to Avoid'),
                    SizedBox(height: AppSize.h12),
                    _CommonMistakesCard(),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: 'Tips for Faster Approval'),
                    SizedBox(height: AppSize.h12),
                    _TipsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: AdSlot(ad: _inlineAd, safeAreaBottom: false),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppSummaryBackground(
      gradientColors: const [Color(0xFF059669), Color(0xFF0D9488)],
      borderRadius:   BorderRadius.only(
        bottomLeft: Radius.circular(AppSize.r24),
        bottomRight: Radius.circular(AppSize.r24),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSize.w16,
            AppSize.h8,
            AppSize.w16,
            AppSize.h24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: Assets.personalLoanIcons.icBack.svg(
                  width: AppSize.sp26,
                  height: AppSize.sp26,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              SizedBox(height: AppSize.h16),
              Text(
                'Required Documents',
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.themeTextColors.secondaryTextColor,
                    fontSize: AppSize.sp28,
                ),
              ),
              SizedBox(height: AppSize.h6),
              Text(
                'Everything you need for quick approval',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.themeTextColors.secondaryTextColor,
                  fontSize: AppSize.sp13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section heading ───────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: AppSize.sp16,
      ),
    );
  }
}

// ── Shared card decoration ────────────────────────────────────────────────────

BoxDecoration _cardDeco() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(AppSize.r16),
  boxShadow: const [
    BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2)),
  ],
);

// ── Why important card ────────────────────────────────────────────────────────

class _WhyImportantCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.h16),
      decoration: _cardDeco(),
      child: _WhyItem(
        icon: Assets.personalLoanIcons.icSecure,
        color: context.themeColors.primary,
        bgColor: const Color(0xFFEEF2FF),
        title: 'Verification & Trust',
        description:
            'Documents help lenders verify your identity, income, and repayment capacity. Complete and accurate documentation ensures faster processing and higher approval chances.',
      ),
    );
  }
}

class _WhyItem extends StatelessWidget {
  const _WhyItem({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.description,
  });

  final SvgGenImage icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSize.w42,
          height: AppSize.h42,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Center(
            child: icon.svg(
              width: AppSize.sp22,
              height: AppSize.sp22,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        ),
        SizedBox(width: AppSize.w12),
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
              SizedBox(height: AppSize.h4),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.themeTextColors.descriptionColor,
                  fontSize: AppSize.sp12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Document type card ────────────────────────────────────────────────────────

class _DocTypeCard extends StatelessWidget {
  const _DocTypeCard({required this.doc});

  final _DocType doc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDeco(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSize.w16,
              AppSize.h14,
              AppSize.w16,
              AppSize.h12,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSize.sp8),
                  decoration: BoxDecoration(
                    color: doc.bgColor,shape: BoxShape.circle,
                   ),
                  child: doc.icon.svg(
                    width: AppSize.w20,
                    height: AppSize.h20,
                    colorFilter: ColorFilter.mode(
                      doc.iconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(width: AppSize.w10),
                Text(
                  doc.title,
                  style: context.textTheme.titleMedium?.copyWith(
                     fontSize: AppSize.sp15
                  ),
                ),
              ],
            ),
          ),
           ...List.generate(
            doc.items.length,
            (i) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.w16,
                vertical: AppSize.h5
              ),
              child: Row(
                children: [
                  Assets.personalLoanIcons.icRightCurcle.svg(
                    width: AppSize.sp20,
                    height: AppSize.sp20,
                    colorFilter: const ColorFilter.mode(Color(0xFF0D9488), BlendMode.srcIn),
                  ),
                  SizedBox(width: AppSize.w10),
                  Expanded(
                    child: Text(
                      doc.items[i],
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontSize: AppSize.sp13,
                        color: context.themeTextColors.descriptionColor
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSize.h4),
        ],
      ),
    );
  }
}

class _DocTypeCard1 extends StatelessWidget {
  const _DocTypeCard1({required this.items });

  final List<String> items;


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDeco(),
      child: Column(
        children: [
          ...List.generate(
         items.length,
            (i) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.w16,
                vertical: AppSize.h8,
              ),
              child: Row(
                children: [
                   Container(
                     padding: EdgeInsets.all(AppSize.sp2),
                     decoration: BoxDecoration(shape: BoxShape.circle,color: Color(0xff059669).withValues(alpha: 0.08)),
                     child: Icon(Icons.done,color: Color(0xff059669),size: AppSize.sp18,),
                   ),
                  SizedBox(width: AppSize.w10),
                  Expanded(
                    child: Text(
                      items[i],
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: AppSize.sp14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}



// ── Format requirements card ──────────────────────────────────────────────────

class _FormatRequirementsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _FormatItem(Assets.requiredDocuments.icFile, 'Accepted Formats', 'PDF, JPG, PNG'),
      _FormatItem(Assets.requiredDocuments.icIncomeProof, 'File Size', 'Max 5MB per file'),
      _FormatItem(Assets.tipsAdviceIcons.icClarity, 'Color Mode', 'Color or B&W'),
      _FormatItem(Assets.onboardingIcons.icMakeSmart, 'Resolution', 'Min 300 DPI'),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _FormatItemWidget(item: _FormatItem(Assets.requiredDocuments.icFile, 'Accepted Formats', 'PDF, JPG, PNG'),iconBgColor: Color(0xff10B981).withValues(alpha: 0.08),iconColor: Color(0xff10B981),)),
            SizedBox(width: AppSize.w14),
            Expanded(
              child: _FormatItemWidget(item: _FormatItem(Assets.requiredDocuments.icIncomeProof, 'File Size', 'Max 5MB per file',),iconBgColor: Color(0xff06B6D4).withValues(alpha: 0.08),iconColor: Color(0xff06B6D4)
              ),
            )
          ],
        ),
        SizedBox(height: AppSize.w14),
        Row(
          children: [
            Expanded(child: _FormatItemWidget(item:  _FormatItem(Assets.tipsAdviceIcons.icClarity, 'Color Mode', 'Color or B&W'),iconBgColor: Color(0xff8B5CF6).withValues(alpha: 0.08),iconColor: Color(0xff8B5CF6))),
            SizedBox(width: AppSize.w14),
            Expanded(
              child: _FormatItemWidget(item: _FormatItem(Assets.onboardingIcons.icMakeSmart, 'Resolution', 'Min 300 DPI'),iconBgColor: Color(0xffF59E0B).withValues(alpha: 0.08),iconColor: Color(0xffF59E0B)
              ),
            )
          ],
        )
      ],
    );
  }
}

class _FormatItemWidget extends StatelessWidget {
  const _FormatItemWidget({required this.item, required this.iconBgColor, required this.iconColor});

  final _FormatItem item;
  final Color iconBgColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w14 ,
        vertical: AppSize.h12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppSize.r10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.sp8),
            decoration: BoxDecoration(shape: BoxShape.circle,color: iconBgColor),
            child: item.icon.svg(
              width: AppSize.sp20,
              height: AppSize.sp20,
              colorFilter:   ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          SizedBox(height: AppSize.h10),
          Text(
            item.label,
            style: context.textTheme.titleSmall?.copyWith(
               fontSize: AppSize.sp13,
            ),
          ),
          SizedBox(height: AppSize.h3),
          Text(
            item.value,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.themeTextColors.descriptionColor,
               fontSize: AppSize.sp12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Quality requirements card ─────────────────────────────────────────────────

class _QualityRequirementsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      _StepItem('Clear & Legible', 'Text should be readable without zooming'),
      _StepItem(
        'Complete Document',
        'All information should be visible for multi-page',
      ),
      _StepItem('Proper Lighting', 'No shadows or glare on the document'),
      _StepItem(
        'Original or Certified',
        'Only attested copies or originals as specified',
      ),
    ];
    return Container(
      padding: EdgeInsets.all(AppSize.h16),
      decoration: _cardDeco(),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: EdgeInsets.only(
                  bottom: item != items.last ? AppSize.h12 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSize.sp2),
                      decoration: BoxDecoration(shape: BoxShape.circle,color: Color(0xff059669).withValues(alpha: 0.08)),
                      child: Icon(Icons.done,color: Color(0xff059669),size: AppSize.sp18,),
                    ),
                    SizedBox(width: AppSize.w10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontSize: AppSize.sp14
                             ),
                          ),
                          Text(
                            item.description,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.themeTextColors.descriptionColor,
                              fontSize: AppSize.sp12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Verification process card ─────────────────────────────────────────────────

class _VerificationProcessCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      _StepItem(
        'Document Upload',
        'Upload scanned/photographed documents via app or web portal',
      ),
      _StepItem(
        'Automated Check',
        'AI verifies document type, quality, and basic information',
      ),
      _StepItem(
        'Manual Review',
        'Loan officer reviews details and cross-checks with database',
      ),
      _StepItem(
        'Approval/Clarification',
        'Get approval or request for additional documents if needed',
      ),
    ];
    final icons = [
      Assets.homeIcons.icDocuments,
      Assets.personalLoanIcons.icInstantApproval,
      Assets.personalLoanIcons.icSecure,
      Assets.personalLoanIcons.icRightCurcle,
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isLast = i == steps.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : AppSize.h12),
          child: Container(
            padding: EdgeInsets.all(AppSize.h16),
            decoration: _cardDeco(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSize.w36,
                  height: AppSize.h36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.themeTextColors.primaryTextColor,
                        fontSize: AppSize.sp15,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSize.w12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          icons[i].svg(
                            width: AppSize.sp18,
                            height: AppSize.sp18,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF2563EB),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: AppSize.w6),
                          Expanded(
                            child: Text(
                              step.title,
                              style: context.textTheme.titleMedium?.copyWith(
                                 fontSize: AppSize.sp15
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSize.h4),
                      Text(
                        step.description,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.themeTextColors.descriptionColor,
                          fontSize: AppSize.sp12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Common mistakes card ──────────────────────────────────────────────────────

class _CommonMistakesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const mistakes = [
      'Expired documents (check validity dates)',
      'Blurry or unclear photocopies',
      'Missing signatures or attestations',
      'Incomplete address (missing required)',
      'Mismatched names across documents',
      'Old utility bills (>3 months)',
      'Uploading wrong file format',
    ];
    return Container(
      padding: EdgeInsets.all(AppSize.h16),
      decoration: _cardDeco(),
      child: Column(
        children: mistakes
            .map(
              (m) => Padding(
                padding: EdgeInsets.only(
                  bottom: m != mistakes.last ? AppSize.h10 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                       padding: EdgeInsets.all(AppSize.sp2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child:  Icon(Icons.close,color: Colors.red,size: AppSize.sp18,)
                      ),
                    ),
                    SizedBox(width: AppSize.w10),
                    Expanded(
                      child: Text(
                        m,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontSize: AppSize.sp14,
                          color: context.themeTextColors.descriptionColor
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Tips card ─────────────────────────────────────────────────────────────────

class _TipItem {
  const _TipItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.bgColor,
    this.highlighted = false,
  });

  final SvgGenImage icon;
  final String title;
  final String description;
  final Color color;
  final Color bgColor;
  final bool highlighted;
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tips = [
      _TipItem(
        icon: Assets.personalLoanIcons.icClock,
        title: 'Submit Early',
        description: 'Upload all documents at once rather than in multiple batches',
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
      ),
      _TipItem(
        icon: Assets.requiredDocuments.icDocumentRight,
        title: 'Double Check',
        description: 'Review all documents before upload to avoid rejection',
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        highlighted: true,
      ),
      _TipItem(
        icon: Assets.onboardingIcons.icStars,
        title: 'Use Good Scanner',
        description: 'High-quality scans reduce back-and-forth clarifications',
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
      ),
      _TipItem(
        icon: Assets.personalLoanIcons.icRightCurcle,
        title: 'Keep Originals Ready',
        description: 'Physical verification may be required for final approval',
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.1),
      ),
      _TipItem(
        icon: Assets.requiredDocuments.icImportantNote,
        title: 'Important Note',
        description:
            'Document requirements may vary by lender and loan type. Always check with your specific lender for their exact requirements. Keep multiple copies of all documents for your records.',
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEEF2FF),
      ),
    ];

    return Column(
      children: List.generate(tips.length, (i) {
        final tip = tips[i];
        final isLast = i == tips.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : AppSize.h12),
          child: Container(
            padding: EdgeInsets.all(AppSize.h16),
            decoration: tip.highlighted
                ? BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSize.r16),
                     boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  )
                : _cardDeco(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSize.w42,
                  height: AppSize.h42,
                  decoration: BoxDecoration(
                    color: tip.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: tip.icon.svg(
                      width: AppSize.sp22,
                      height: AppSize.sp22,
                      colorFilter: ColorFilter.mode(tip.color, BlendMode.srcIn),
                    ),
                  ),
                ),
                SizedBox(width: AppSize.w12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSize.h4),
                      Text(
                        tip.description,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.themeTextColors.descriptionColor,
                          fontSize: AppSize.sp12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
