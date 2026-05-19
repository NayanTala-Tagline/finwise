import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';

/// App Version Widget
class AppVersion extends StatelessWidget {
  /// Constructor
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
          return const SizedBox();
        }
        return Padding(
          padding: EdgeInsets.all(AppSize.h10),
          child: Center(
            child: Text(
              'v${snapshot.requireData.version}.${snapshot.requireData.buildNumber}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                fontSize: AppSize.sp12,
              ),
            ),
          ),
        );
      },
    );
  }
}
