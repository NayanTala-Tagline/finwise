import 'package:finwise/extension/ext_context.dart';
import 'package:finwise/utils/anaytics_manager.dart';
import 'package:flutter/material.dart';

import 'widgets/tools_grid.dart';
import 'widgets/tools_header.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'tools_screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ToolsHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: ToolsGrid.build(context),
            ),
          ),
        ],
      ),
    );
  }
}
