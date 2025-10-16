class Holding {
  final String coinId;
  final String name;
  final String symbol;
  final double quantity;

  Holding({
    required this.coinId,
    required this.name,
    required this.symbol,
    required this.quantity,
  });

  factory Holding.fromMap(Map<String, dynamic> m) {
    return Holding(
      coinId: m['coinId'] as String,
      name: m['name'] as String,
      symbol: m['symbol'] as String,
      quantity: (m['quantity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'coinId': coinId,
        'name': name,
        'symbol': symbol,
        'quantity': quantity,
      };

  Holding copyWith({double? quantity}) {
    return Holding(
      coinId: coinId,
      name: name,
      symbol: symbol,
      quantity: quantity ?? this.quantity,
    );
  }
}
