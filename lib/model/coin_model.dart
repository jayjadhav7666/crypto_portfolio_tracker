class Coin {
  final String id;
  final String symbol;
  final String name;
  final String? imageUrl;

  Coin({
    required this.id,
    required this.symbol,
    required this.name,
    this.imageUrl,
  });

  factory Coin.fromMap(Map<String, dynamic> m) {
    return Coin(
      id: (m['id'] ?? '') as String,
      symbol: (m['symbol'] ?? '') as String,
      name: (m['name'] ?? '') as String,
      imageUrl: m.containsKey('image') ? m['image'] as String? : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'symbol': symbol,
        'name': name,
        'image': imageUrl,
      };
}
