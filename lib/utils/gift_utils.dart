// import 'package:btc_mining_tracker/features/reward_module/provider/daily_reward_provider.dart';

class GiftUtils {
  /// Calculates the status string for the "Next Gift In" field.
  /// Returns "Gift available" or a countdown timer (HH:MM:SS).
  // static String getNextGiftStatus(DailyRewardProvider provider) {
  //   // ✅ FIX: Use Local time instead of UTC to align with device clock
  //   final now = DateTime.now(); 

  //   // ------------------------------------------------
  //   // 1. Daily Limit Reached (16/16) -> Wait for Next Local Midnight
  //   // ------------------------------------------------
  //   if (provider.giftsOpenedToday >= 16) {
  //     // Target: Next Local Midnight (Start of the next day)
  //     final tomorrow = DateTime(now.year, now.month, now.day + 1);
  //     final diff = tomorrow.difference(now);
      
  //     if (diff.isNegative) return "00:00:00"; 
  //     return _formatDuration(diff);
  //   }

  //   // ------------------------------------------------
  //   // 2. Batch Cooldown (4/4 opened) -> Wait 30 Mins
  //   // ------------------------------------------------
  //   // Check if batch limit reached and we have a last open time
  //   if (provider.batchOpened >= 4 && provider.lastGiftOpenUtc != null) {
  //     // Convert the stored UTC time to Local time for accurate comparison
  //     final lastOpenLocal = provider.lastGiftOpenUtc!.toLocal();
  //     final unlockTime = lastOpenLocal.add(const Duration(minutes: 30));
      
  //     if (now.isBefore(unlockTime)) {
  //       final diff = unlockTime.difference(now);
  //       return _formatDuration(diff);
  //     }
  //   }

  //   // ------------------------------------------------
  //   // 3. Available
  //   // ------------------------------------------------
  //   return "Gift available"; 
  // }

  /// Helper to format Duration to HH:MM:SS
  // static String _formatDuration(Duration d) {
  //   final h = d.inHours.toString().padLeft(2, '0');
  //   final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  //   final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  //   return "$h:$m:$s";
  // }
}