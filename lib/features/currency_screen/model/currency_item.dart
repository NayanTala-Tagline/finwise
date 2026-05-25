class CurrencyItem {
  const CurrencyItem({
    required this.code,
    required this.symbol,
    required this.country,
  });

  final String code;
  final String symbol;
  final String country;

  static const List<CurrencyItem> all = [
    CurrencyItem(code: 'KSh', symbol: 'KSh', country: 'Kenya'),
    CurrencyItem(code: 'NGN', symbol: '₦', country: 'Nigeria'),
    CurrencyItem(code: 'PHP', symbol: '₱', country: 'Philippines'),
    CurrencyItem(code: 'TSh', symbol: 'TSh', country: 'Tanzania'),
    CurrencyItem(code: 'USD', symbol: r'$', country: 'US'),
    CurrencyItem(code: 'EUR', symbol: '€', country: 'Euro'),
    CurrencyItem(code: 'INR', symbol: '₹', country: 'India'),
    CurrencyItem(code: 'ZMW', symbol: 'ZK', country: 'Zambia'),
    CurrencyItem(code: 'UGX', symbol: 'UGX', country: 'Uganda'),
    CurrencyItem(code: 'THB', symbol: '฿', country: 'Thai'),
    CurrencyItem(code: 'GBP', symbol: '£', country: 'UK'),
    CurrencyItem(code: 'JPY', symbol: '¥', country: 'Japan'),
    CurrencyItem(code: 'CNY', symbol: '¥', country: 'China'),
    CurrencyItem(code: 'AED', symbol: 'د.إ', country: 'UAE'),
    CurrencyItem(code: 'SAR', symbol: '﷼', country: 'Saudi Arabia'),
    CurrencyItem(code: 'CAD', symbol: 'CA\$', country: 'Canada'),
    CurrencyItem(code: 'AUD', symbol: 'A\$', country: 'Australia'),
    CurrencyItem(code: 'CHF', symbol: 'CHF', country: 'Switzerland'),
    CurrencyItem(code: 'KRW', symbol: '₩', country: 'South Korea'),
    CurrencyItem(code: 'SGD', symbol: 'S\$', country: 'Singapore'),
    CurrencyItem(code: 'BRL', symbol: 'R\$', country: 'Brazil'),
    CurrencyItem(code: 'ZAR', symbol: 'R', country: 'South Africa'),
  ];
}
