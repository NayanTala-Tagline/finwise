 import 'package:finwise/utils/app_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../extension/ext_context.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../utils/anaytics_manager.dart';
import '../../../../utils/navigation_helper.dart';

/// Bottom navigation bar view
class BottomNavView extends StatelessWidget {
  /// Default constructor
  const BottomNavView({required this.shell, super.key});

  /// The navigation shell
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <_BottomNavItemData>[
      _BottomNavItemData(
        icon: Assets.botombarIcons.icHome,
        label: 'Home',
      ),
      _BottomNavItemData(
        icon: Assets.botombarIcons.icTools,
        label: 'Tools',
      ),
      _BottomNavItemData(
        icon: Assets.botombarIcons.icCompare,
        label: 'Compare',
      ),
      _BottomNavItemData(
        icon: Assets.botombarIcons.icSettings,
        label: 'Setting',
      ),
    ];

    const branchNames = ['home', 'tools', 'compare', 'setting'];

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w12,vertical: AppSize.h8),
        margin: EdgeInsets.symmetric(horizontal: AppSize.w22, vertical: AppSize.h6),
        height: AppSize.h90,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xff000000).withValues(alpha: 0.25),
              blurRadius: AppSize.r50,
                offset: Offset(0, AppSize.sp25)
            ),
          ],
          borderRadius: BorderRadius.circular(AppSize.r20),
        ),
      // color: const Color(0xFF000000),
      child: Row(
        children: List.generate(items.length, (index) {
          final isSelected = shell.currentIndex == index;
          return Expanded(
            child: _BottomNavItem(
              data: items[index],
              isSelected: isSelected,
              onTap: () {
                AnalyticsManager.instance.logEvent(
                  name: 'bottom_nav_tap',
                  parameters: {'branch': branchNames[index]},
                );
                AnalyticsManager.instance.logScreenView(
                  screenName: '${branchNames[index]}_screen',
                );
                NavigationHelper().addBackTap(context);
                shell.goBranch(
                  index,
                  initialLocation: shell.currentIndex == index,
                );
              },
            ),
          );
        }),
      ),
      ),
    );
  }
}

class _BottomNavItemData {
  _BottomNavItemData({required this.icon, required this.label});

  final SvgGenImage icon;
  final String label;
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final _BottomNavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  static const _activeColor = Color(0xFFffffff);
  static const _inactiveColor = Color(0xFF64748B);
  static const _accentYellow = Color(0xFFF5D90A);
  static const _activeBg = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _activeColor : _inactiveColor;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
         decoration: BoxDecoration(
          color: isSelected ? context.themeColors.primary : null,
          borderRadius: BorderRadius.circular(AppSize.r20)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            data.icon.svg(
              width: 26,
              height: 26,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                data.label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
