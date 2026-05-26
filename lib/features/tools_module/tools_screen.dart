import 'package:finwise/extension/ext_context.dart';
import 'package:flutter/material.dart';

import 'widgets/tools_grid.dart';
import 'widgets/tools_header.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

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
