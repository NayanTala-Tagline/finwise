import 'package:flutter/foundation.dart';

import '../../../db/app_db.dart';
import '../../../di/injector.dart';
import '../model/currency_item.dart';

class CurrencyProvider with ChangeNotifier {
  CurrencyItem _selected = CurrencyItem.all.firstWhere(
    (c) => c.code == 'USD',
  );

  CurrencyItem get selected => _selected;
  String get symbol => _selected.symbol;
  String get code => _selected.code;

  CurrencyProvider() {
    _loadFromDB();
  }

  void _loadFromDB() {
    final db = Injector.instance<AppDB>();
    final savedCode = db.currencyCode;
    final match = CurrencyItem.all.where((c) => c.code == savedCode).toList();
    if (match.isNotEmpty) {
      _selected = match.first;
      notifyListeners();
    }
  }

  Future<void> setCurrency(CurrencyItem item) async {
    _selected = item;
    final db = Injector.instance<AppDB>();
    db.currencyCode = item.code;
    db.currencySymbol = item.symbol;
    notifyListeners();
  }
}
