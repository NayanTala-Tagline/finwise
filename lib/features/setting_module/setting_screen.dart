import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../utils/app_size.dart';
import '../../utils/remote_config.dart';
import '../../widgets/app_summary_background.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SettingsHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h20, AppSize.w16, AppSize.h24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                  _SectionTitle('Preferences'),
                  SizedBox(height: AppSize.h10),
                  _SettingGroup(
                    tiles: [
                      _SettingTile(
                        icon: Assets.onboardingIcons.icLanguage.svg(width: AppSize.w20, height: AppSize.h20, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                        title: 'Language',
                        badgeText: 'English',
                        onTap: () {},
                      ),
                      _SettingTile(
                        icon: Assets.onboardingIcons.icCurrency.svg(width: AppSize.w20, height: AppSize.h20, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                        title: 'Currency',
                        badgeText: 'INR',
                        onTap: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: AppSize.h20),
                  _SectionTitle('Security & Privacy'),
                  SizedBox(height: AppSize.h10),
                  _SettingGroup(
                    tiles: [
                      _SettingTile(
                        icon: Assets.requiredDocuments.icFile.svg(width: AppSize.w20, height: AppSize.h20, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                        title: 'Privacy Policy',
                        onTap: () async {
                          final url = Uri.tryParse(RemoteConfigService.instance.privacyPolicyUrl);
                          if (url != null) await launchUrl(url, mode: LaunchMode.externalApplication);
                        },
                      ),
                      _SettingTile(
                        icon: Assets.requiredDocuments.icFile.svg(width: AppSize.w20, height: AppSize.h20, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                        title: 'Terms of Service',
                        onTap: () async {
                          final url = Uri.tryParse(RemoteConfigService.instance.privacyPolicyUrl);
                          if (url != null) await launchUrl(url, mode: LaunchMode.externalApplication);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: AppSize.h20),
                  _SectionTitle('Support'),
                  SizedBox(height: AppSize.h10),
                  _SettingGroup(
                    tiles: [
                      _SettingTile(
                        icon: Assets.temperatureIcons.icHelpCenter.svg(width: AppSize.w20, height: AppSize.h20, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                        title: 'Help Center',
                        onTap: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: AppSize.h20),
                  _AppVersionCard(version: _version),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppSummaryBackground(
      gradientColors:   [context.themeColors.primary, Color(0xFF153885)],
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(AppSize.r24),
        bottomRight: Radius.circular(AppSize.r24),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSize.w20, AppSize.h16, AppSize.w20, AppSize.h24),
          child: Text(
            'Settings',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section title ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: AppSize.w4),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          fontSize: AppSize.sp13,
          fontWeight: FontWeight.w600,
          color: context.themeTextColors.descriptionColor,
        ),
      ),
    );
  }
}

// ─── Setting group (white card with dividers) ──────────────────────────────

class _SettingGroup extends StatelessWidget {
  const _SettingGroup({required this.tiles});
  final List<_SettingTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i < tiles.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: AppSize.w56,
                endIndent: 0,
                color: const Color(0xFFF1F5F9),
              ),
          ],
        ],
      ),
    );
  }
}

// ─── Setting tile ──────────────────────────────────────────────────────────

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badgeText,
  });

  final Widget icon;
  final String title;
  final VoidCallback onTap;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSize.r16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w16, vertical: AppSize.h14),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSize.sp10),
              decoration: BoxDecoration(
                color:   Color(0xFFF1F5F9),
                shape: BoxShape.circle,
               ),
              child: Center(child: icon),
            ),
            SizedBox(width: AppSize.w12),
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: AppSize.sp15,
                  fontWeight: FontWeight.w500,
                  color: context.themeTextColors.textColor,
                ),
              ),
            ),
            if (badgeText != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSize.w10, vertical: AppSize.h4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(AppSize.r20),
                ),
                child: Text(
                  badgeText!,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: AppSize.sp12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              SizedBox(width: AppSize.w6),
            ],
            Icon(Icons.chevron_right_rounded, size: AppSize.sp20, color: const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

// ─── App version card ──────────────────────────────────────────────────────

class _AppVersionCard extends StatelessWidget {
  const _AppVersionCard({required this.version});
  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w16, vertical: AppSize.h16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Version',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp15,
                    fontWeight: FontWeight.w600,
                    color: context.themeTextColors.textColor,
                  ),
                ),
                SizedBox(height: AppSize.h2),
                Text(
                  version.isNotEmpty ? 'Version $version' : 'Version —',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: AppSize.sp12,
                    color: context.themeTextColors.descriptionColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w14, vertical: AppSize.h8),
              decoration: BoxDecoration(
                color: context.themeColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSize.r20),
              ),
              child: Text(
                'Check for updates',
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: AppSize.sp12,
                  fontWeight: FontWeight.w600,
                  color: context.themeColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
