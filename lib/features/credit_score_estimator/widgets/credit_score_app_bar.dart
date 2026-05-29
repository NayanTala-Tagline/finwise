import 'package:flutter/material.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';

class CreditScoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CreditScoreAppBar({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(AppSize.h56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 2)],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppSize.h56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: AppSize.w12,
                child: GestureDetector(
                  onTap: onBack,
                  behavior: HitTestBehavior.opaque,
                  child: Icon(Icons.arrow_back_ios, size: AppSize.sp22, color: Colors.black),
                ),
              ),
              Text(
                context.l10n.creditScoreEstimatorTitle,
                style: context.textTheme.titleSmall?.copyWith(fontSize: AppSize.sp18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
