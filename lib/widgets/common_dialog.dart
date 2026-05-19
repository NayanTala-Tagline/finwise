import 'package:flutter/material.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';
import 'app_button.dart';

Future<void> showMiningPowerDialog(BuildContext context, String title, String subTitle) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.r16)),
        backgroundColor: context.themeColors.cardColor,
        titlePadding: EdgeInsets.only(top: AppSize.h20, left: AppSize.w20, right: AppSize.w20),
        contentPadding: EdgeInsets.symmetric(horizontal: AppSize.w20, vertical: AppSize.h10),
        actionsPadding: EdgeInsets.only(bottom: AppSize.h16, left: AppSize.w20, right: AppSize.w20),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge?.copyWith(fontSize: AppSize.sp18),
        ),
        content: Text(
          subTitle,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            height: 1.4,
            fontSize: AppSize.sp12,
            color: context.themeTextColors.textColor,
          ),
        ),
        actions: [
          SizedBox(height: AppSize.w6),
          Container(
            decoration: BoxDecoration(
              color: context.themeColors.backgroundColor,
              borderRadius: BorderRadius.circular(AppSize.r10),
              border: Border.all(color: context.themeColors.borderColor2.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1), // faint outer glow
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: AppButton(
              text: 'Close', //'Close',
              onPressed: () => Navigator.pop(context),
              buttonColor: Colors.transparent,
              // borderColor: context.themeColors.borderSide,
              buttonStyle: ElevatedButton.styleFrom(shadowColor: context.themeColors.borderColor),
            ),
          ),
          SizedBox(height: AppSize.w6),
        ],
      );
    },
  );
}
