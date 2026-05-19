import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../extension/ext_context.dart';
import '../loading_indicator.dart';
import 'loading_overlay_controller.dart';

/// Loading overlay is a singleton class that can be used to show loading indicator on top of the screen.
class LoadingOverlay {
  /// Returns the singleton instance of [LoadingOverlay]
  factory LoadingOverlay.instance() => _instance;

  LoadingOverlay._();

  static final LoadingOverlay _instance = LoadingOverlay._();

  LoadingOverlayController? _controller;

  /// flag to check if loader is on tree or not
  bool isShowing = false;

  /// Shows loading indicator on top of the screen.
  void show({required BuildContext context, String text = ''}) {
    if (_controller?.update(text) ?? false) {
      return;
    } else {
      _controller = _showOverlay(context: context, text: text);
    }
  }

  /// updates progress on overlay loading
  void progress(double? val) {
    _controller?.progress(val);
  }

  /// updates text shown on overlay loading
  void updateTitle(String text) {
    _controller?.update(text);
  }

  /// Hides loading indicator.
  void hide() {
    _controller?.close();
    _controller = null;
  }

  LoadingOverlayController? _showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final textController = StreamController<String>()
      ..add(text); // default string in stream
    final progressController = StreamController<double?>()
      ..add(null); // default string in stream

    // final renderBox = context.findRenderObject()! as RenderBox;
    // final screenSize = renderBox.size;

    showDialog<AlertDialog>(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        isShowing = true;
        return PopScope(
          canPop: false,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                StreamBuilder<double?>(
                  stream: progressController.stream,
                  builder: (context, snapshot) {
                    return LoadingIndicator(
                      progress: snapshot.data,
                      color: Colors.white,
                    );
                  },
                ),
                const SizedBox(height: 16),
                StreamBuilder(
                  stream: textController.stream,
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.hasData ? snapshot.requireData : '',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    return LoadingOverlayController(
      close: () {
        if (context.mounted && context.canPop()) {
          // Changing context.pop() to Navigator.of(context).pop()
          // Issue : Loading overlay pop issue [community feed-> Community feed list -> hide]
          context.pop();
          isShowing = false;
        }
        textController.close();
        progressController.close();
        return true;
      },
      update: (text) {
        textController.add(text);
        return true;
      },
      progress: (progress) {
        progressController.add(progress);
        return true;
      },
    );
  }
}
