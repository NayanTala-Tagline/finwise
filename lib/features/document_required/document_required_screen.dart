import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';

import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../utils/anaytics_manager.dart';
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
    AnalyticsManager.instance.logScreenView(screenName: 'document_required_screen');
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
    final l10n = context.l10n;
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
                    _SectionHeading(title: l10n.docsWhyImportantTitle),
                    SizedBox(height: AppSize.h12),
                    _WhyImportantCard(),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: l10n.docsEssentialChecklistTitle),
                    SizedBox(height: AppSize.h12),
                    _DocTypeCard(
                      doc: _DocType(
                        title: l10n.docsIdentityProofTitle,
                        icon: Assets.homeIcons.icCreditCard,
                        iconColor: context.themeColors.primary,
                        bgColor: const Color(0xFFEEF2FF),
                        items: [
                          l10n.docsIdentityAadhaar,
                          l10n.docsIdentityPan,
                          l10n.docsIdentityVoterId,
                          l10n.docsIdentityDrivingLicence,
                          l10n.docsIdentityPassport,
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.h12),
                    _DocTypeCard(
                      doc: _DocType(
                        title: l10n.docsAddressProofTitle,
                        icon: Assets.onboardingIcons.icHome,
                        iconColor: const Color(0xFF0D9488),
                        bgColor: const Color(0xFF0D9488).withValues(alpha: 0.08),
                        items: [
                          l10n.docsAddressBill,
                          l10n.docsAddressRental,
                          l10n.docsAddressPossession,
                          l10n.docsAddressBankStatement,
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.h12),
                    _DocTypeCard(
                      doc: _DocType(
                        title: l10n.docsIncomeSalariedTitle,
                        icon: Assets.homeIcons.icDocuments,
                        iconColor: const Color(0xFF10B981),
                        bgColor: const Color(0xFF10B981).withValues(alpha: 0.08),
                        items: [
                          l10n.docsIncomeSalarySlips,
                          l10n.docsIncomeItr,
                          l10n.docsIncomeBankStatements,
                          l10n.docsIncomeEmploymentCert,
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.h12),
                    _DocTypeCard(
                      doc: _DocType(
                        title: l10n.docsIncomeSelfEmployedTitle,
                        icon: Assets.requiredDocuments.icIncomeProof,
                        iconColor: const Color(0xFF7C3AED),
                        bgColor: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                        items: [
                          l10n.docsIncomeSelfItr,
                          l10n.docsIncomeSelfBankStatements,
                          l10n.docsIncomeSelfGst,
                          l10n.docsIncomeSelfAuditedStatements,
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: l10n.docsPropertyTitle),
                    SizedBox(height: AppSize.h12),
                    _DocTypeCard1(
                      items: [
                        l10n.docsPropertySaleDeed,
                        l10n.docsPropertyTaxReceipts,
                        l10n.docsPropertyEncumbrance,
                        l10n.docsPropertyBuildingPlan,
                        l10n.docsPropertyNoc,
                        l10n.docsPropertyChainTitle,
                      ],
                    ),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: l10n.docsVehicleTitle),
                    SizedBox(height: AppSize.h12),
                    _DocTypeCard1(
                      items: [
                        l10n.docsVehicleInvoice,
                        l10n.docsVehicleInsurance,
                        l10n.docsVehicleRc,
                        l10n.docsVehicleRcTransfer,
                        l10n.docsVehicleTransferQuotation,
                        l10n.docsVehicleRoadTax,
                      ],
                    ),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: l10n.docsFormatRequirementsTitle),
                    SizedBox(height: AppSize.h12),
                    _FormatRequirementsCard(),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: l10n.docsQualityTitle),
                    SizedBox(height: AppSize.h12),
                    _QualityRequirementsCard(),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: l10n.docsVerificationTitle),
                    SizedBox(height: AppSize.h12),
                    _VerificationProcessCard(),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: l10n.docsMistakesTitle),
                    SizedBox(height: AppSize.h12),
                    _CommonMistakesCard(),
                    SizedBox(height: AppSize.h20),
                    _SectionHeading(title: l10n.docsTipsTitle),
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
    final l10n = context.l10n;
    return AppSummaryBackground(
      gradientColors: const [Color(0xFF059669), Color(0xFF0D9488)],
      borderRadius: BorderRadius.only(
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
                l10n.documentsRequiredTitle,
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.themeTextColors.secondaryTextColor,
                  fontSize: AppSize.sp28,
                ),
              ),
              SizedBox(height: AppSize.h6),
              Text(
                l10n.documentsRequiredSubtitle,
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
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.all(AppSize.h16),
      decoration: _cardDeco(),
      child: _WhyItem(
        icon: Assets.personalLoanIcons.icSecure,
        color: context.themeColors.primary,
        bgColor: const Color(0xFFEEF2FF),
        title: l10n.docsWhyVerificationTitle,
        description: l10n.docsWhyVerificationDesc,
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
                    color: doc.bgColor,
                    shape: BoxShape.circle,
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
                Flexible(
                  child: Text(
                    doc.title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: AppSize.sp15,
                    ),
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
                vertical: AppSize.h5,
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
                        color: context.themeTextColors.descriptionColor,
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
  const _DocTypeCard1({required this.items});

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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xff059669).withValues(alpha: 0.08),
                    ),
                    child: Icon(Icons.done, color: const Color(0xff059669), size: AppSize.sp18),
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
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FormatItemWidget(
                item: _FormatItem(Assets.requiredDocuments.icFile, l10n.docsFormatAccepted, l10n.docsFormatAcceptedValue),
                iconBgColor: const Color(0xff10B981).withValues(alpha: 0.08),
                iconColor: const Color(0xff10B981),
              ),
            ),
            SizedBox(width: AppSize.w14),
            Expanded(
              child: _FormatItemWidget(
                item: _FormatItem(Assets.requiredDocuments.icIncomeProof, l10n.docsFormatFileSize, l10n.docsFormatFileSizeValue),
                iconBgColor: const Color(0xff06B6D4).withValues(alpha: 0.08),
                iconColor: const Color(0xff06B6D4),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.w14),
        Row(
          children: [
            Expanded(
              child: _FormatItemWidget(
                item: _FormatItem(Assets.tipsAdviceIcons.icClarity, l10n.docsFormatColorMode, l10n.docsFormatColorModeValue),
                iconBgColor: const Color(0xff8B5CF6).withValues(alpha: 0.08),
                iconColor: const Color(0xff8B5CF6),
              ),
            ),
            SizedBox(width: AppSize.w14),
            Expanded(
              child: _FormatItemWidget(
                item: _FormatItem(Assets.onboardingIcons.icMakeSmart, l10n.docsFormatResolution, l10n.docsFormatResolutionValue),
                iconBgColor: const Color(0xffF59E0B).withValues(alpha: 0.08),
                iconColor: const Color(0xffF59E0B),
              ),
            ),
          ],
        ),
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
        horizontal: AppSize.w14,
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
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconBgColor),
            child: item.icon.svg(
              width: AppSize.sp20,
              height: AppSize.sp20,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
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
    final l10n = context.l10n;
    final items = [
      _StepItem(l10n.docsQualityClearLegible, l10n.docsQualityClearLegibleDesc),
      _StepItem(l10n.docsQualityCompleteDoc, l10n.docsQualityCompleteDocDesc),
      _StepItem(l10n.docsQualityProperLighting, l10n.docsQualityProperLightingDesc),
      _StepItem(l10n.docsQualityOriginalCertified, l10n.docsQualityOriginalCertifiedDesc),
    ];
    return Container(
      padding: EdgeInsets.all(AppSize.h16),
      decoration: _cardDeco(),
      child: Column(
        children: items
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < items.length - 1 ? AppSize.h12 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSize.sp2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xff059669).withValues(alpha: 0.08),
                      ),
                      child: Icon(Icons.done, color: const Color(0xff059669), size: AppSize.sp18),
                    ),
                    SizedBox(width: AppSize.w10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.title,
                            style: context.textTheme.titleMedium?.copyWith(fontSize: AppSize.sp14),
                          ),
                          Text(
                            entry.value.description,
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
    final l10n = context.l10n;
    final steps = [
      _StepItem(l10n.docsVerificationStep1Title, l10n.docsVerificationStep1Desc),
      _StepItem(l10n.docsVerificationStep2Title, l10n.docsVerificationStep2Desc),
      _StepItem(l10n.docsVerificationStep3Title, l10n.docsVerificationStep3Desc),
      _StepItem(l10n.docsVerificationStep4Title, l10n.docsVerificationStep4Desc),
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
                              style: context.textTheme.titleMedium?.copyWith(fontSize: AppSize.sp15),
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
    final l10n = context.l10n;
    final mistakes = [
      l10n.docsMistake1,
      l10n.docsMistake2,
      l10n.docsMistake3,
      l10n.docsMistake4,
      l10n.docsMistake5,
      l10n.docsMistake6,
      l10n.docsMistake7,
    ];
    return Container(
      padding: EdgeInsets.all(AppSize.h16),
      decoration: _cardDeco(),
      child: Column(
        children: mistakes
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < mistakes.length - 1 ? AppSize.h10 : 0,
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
                        child: Icon(Icons.close, color: Colors.red, size: AppSize.sp18),
                      ),
                    ),
                    SizedBox(width: AppSize.w10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontSize: AppSize.sp14,
                          color: context.themeTextColors.descriptionColor,
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
    final l10n = context.l10n;
    final tips = [
      _TipItem(
        icon: Assets.personalLoanIcons.icClock,
        title: l10n.docsTip1Title,
        description: l10n.docsTip1Desc,
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
      ),
      _TipItem(
        icon: Assets.requiredDocuments.icDocumentRight,
        title: l10n.docsTip2Title,
        description: l10n.docsTip2Desc,
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        highlighted: true,
      ),
      _TipItem(
        icon: Assets.onboardingIcons.icStars,
        title: l10n.docsTip3Title,
        description: l10n.docsTip3Desc,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
      ),
      _TipItem(
        icon: Assets.personalLoanIcons.icRightCurcle,
        title: l10n.docsTip4Title,
        description: l10n.docsTip4Desc,
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.1),
      ),
      _TipItem(
        icon: Assets.requiredDocuments.icImportantNote,
        title: l10n.docsImportantNoteTitle,
        description: l10n.docsImportantNoteDesc,
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
