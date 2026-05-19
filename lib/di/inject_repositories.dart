import 'package:flutter/foundation.dart' show immutable;
import 'package:get_it/get_it.dart';

import '../db/app_db.dart';
import 'injector.dart';

/// Use Case injection
@immutable
class RepositoryInjector {
  /// Construct
  RepositoryInjector(this.instance) {
    _init();
  }

  /// GetIt instance
  final GetIt instance;

  void _init() {
    Injector.instance.isReady<AppDB>();
  }
}
