import 'dart:async';
import 'dart:io';


import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/features/bottom_nav/ui/widgets/bottom_nav_view.dart';
import 'package:finwise/provider/open_ad_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import '../../../extension/ext_context.dart';
import '../../../extension/ext_string_alert.dart';
import '../../../utils/anaytics_manager.dart';
import '../../../utils/remote_config.dart';
import '../../../widgets/ad_slot.dart';


/// Bottom navigation page for managing bottom navigation
class BottomNavPage extends StatefulWidget {
  /// Default constructor
  const BottomNavPage({required this.child, this.showWalletDialog, super.key});

  /// The navigation shell
  final StatefulNavigationShell child;

  /// Want to show Wallet Feature dialog or not
  final bool? showWalletDialog;

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  final dashboardSfKey = GlobalKey<ScaffoldState>();

  DateTime? _currentBackPressTime;

  /// One native ad per bottom-nav branch (home / tools / compare / setting).
  /// All four are preloaded once when this page first mounts; the one matching
  /// the active branch is shown above the bar.
  final List<InlineAdManager?> _branchAds = List<InlineAdManager?>.filled(4, null);

  @override
  void initState() {
    super.initState();
    _loadBranchAds();
  }

  void _loadBranchAds() {
    final rc = RemoteConfigService.instance;
    final slots = <AdData>[
      rc.bottomHome,
      rc.bottomTool,
      rc.bottomCompare,
      rc.bottomSetting,
    ];
    for (var i = 0; i < slots.length; i++) {
      final data = slots[i];
      if (!data.enabled || data.adId.isEmpty) continue;
      final ad = InlineAdManager(adData: data);
      _branchAds[i] = ad;
      unawaited(ad.load());
    }
  }

  @override
  void dispose() {
    for (final ad in _branchAds) {
      unawaited(ad?.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      dialogStyle: UpgradeDialogStyle.material,
      cupertinoButtonTextStyle: context.textTheme.titleSmall,
      child: BackButtonListener(
        onBackButtonPressed: () async {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            if (widget.child.currentIndex == 0) {
              _handleBackPress(context);
            } else {
              widget.child.goBranch(0);
            }
            return true;
          }
          return false;
        },
        child: ChangeNotifierProvider(
          create: (context) => OpenAdProvider()..startOpenAdListener(),
          lazy: false,
          child: Scaffold(
            backgroundColor: context.themeColors.backgroundColor,
                key: dashboardSfKey,
              body: widget.child,
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom > 0
                   ? const SizedBox.shrink()
                   : Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         IndexedStack(
                           index: widget.child.currentIndex,
                           sizing: StackFit.loose,
                           children: [
                             for (var i = 0; i < _branchAds.length; i++)
                               AdSlot(
                                 key: ValueKey('bottom_nav_ad_$i'),
                                 ad: _branchAds[i],
                                 safeAreaBottom: false,
                               ),
                           ],
                         ),
                         BottomNavView(shell: widget.child),
                       ],
                     ),
            ),
        ),
      ),
    );
  }

  void _handleBackPress(BuildContext context) {
    if (_currentBackPressTime == null ||
        DateTime.now().difference(_currentBackPressTime!) >
            const Duration(seconds: 2)) {
      _currentBackPressTime = DateTime.now();
      context.l10n.exitAppAlert
          .showInfoAlert(duration: const Duration(seconds: 2));
      AnalyticsManager.instance.logEvent(name: "app_exit_attempted");
    } else {
      AnalyticsManager.instance.logEvent(name: "app_exit_confirmed");
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    }
  }
}
