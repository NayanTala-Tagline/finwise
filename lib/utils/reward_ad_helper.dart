import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';

import '../widgets/loading_overlay/loading_overlay.dart';
import '../widgets/reward_ad_bottom_sheet.dart';

class RewardAdHelper {
  static Future<void> showRewardAdWithBottomSheet({
    required BuildContext context,
    required AdData adData,
    VoidCallback? onAdCompleted,
    VoidCallback? onAdCancelled,
  }) async {

    if (!adData.enabled) {
      onAdCompleted?.call();
      return;
    }
    bool shouldShowAd = false;
    
    // Show bottom sheet first
    await showRewardAdBottomSheet(
      context: context,
      onSupportUs: () {
        shouldShowAd = true;
      },
      onCancel: () {
        shouldShowAd = false;
        onAdCancelled?.call();
      },
    );
    
    // If user chose to support or timer expired, show the ad
    if (shouldShowAd && context.mounted) {
      await _showRewardAd(context, adData);
      onAdCompleted?.call();
    }
  }
  
  static Future<void> _showRewardAd(BuildContext context, AdData adData) async {
    try {
      LoadingOverlay.instance().show(context: context);

      final rewardAd = FullScreenAdManager(adData: adData);

      await rewardAd.load();
      await rewardAd.future();

      if (!context.mounted) return;

      await rewardAd.show(
        context: context,
        onUserEarnedReward: (_, _) {},
      );
      await Future.delayed(const Duration(milliseconds: 400));
    } finally {
      LoadingOverlay.instance().hide();
    }
  }
}
