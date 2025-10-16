import 'dart:convert';
import 'package:crypto_portfolio_tracker/model/coin_model.dart';
import 'package:crypto_portfolio_tracker/model/holding_model.dart';
import 'package:crypto_portfolio_tracker/services/app_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinRepository {
  static const _coinListKey = 'coin_list_cache';
  static const _portfolioKey = 'portfolio_data';
  static const _pricesKey = 'prices_cache_v1';
  static const _pricesUpdatedAtKey = 'prices_updated_at_v1';

  final ApiService _api = ApiService();

  /// Load coin list from cache if present; otherwise fetch and cache it
  Future<Map<String, Coin>> getCoinListCached() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_coinListKey)) {
      final raw = prefs.getString(_coinListKey)!;
      final List parsed = jsonDecode(raw);
      final Map<String, Coin> map = {};
      for (var item in parsed) {
        final coin = Coin.fromMap(item);
        map[coin.id] = coin;
      }
      return map;
    } else {
      final list = await _api.fetchCoinList();
      final List<Map<String, dynamic>> serial =
          list.map((c) => c.toMap()).toList();
      await prefs.setString(_coinListKey, jsonEncode(serial));
      return {for (var c in list) c.id: c};
    }
  }

  /// Force refresh coin list from API and cache it
  Future<void> refreshCoinList() async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _api.fetchCoinList();
    final List<Map<String, dynamic>> serial =
        list.map((c) => c.toMap()).toList();
    await prefs.setString(_coinListKey, jsonEncode(serial));
  }

  Future<List<Holding>> loadPortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_portfolioKey)) return [];
    final raw = prefs.getString(_portfolioKey)!;
    final List parsed = jsonDecode(raw);
    return parsed.map((m) => Holding.fromMap(m)).toList();
  }

  Future<void> savePortfolio(List<Holding> holdings) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = holdings.map((h) => h.toMap()).toList();
    await prefs.setString(_portfolioKey, jsonEncode(serialized));
  }

  Future<Map<String, double>> fetchPricesForHoldings(List<Holding> holdings) {
    final ids = holdings.map((h) => h.coinId).toSet().toList();
    return _api.fetchPrices(ids);
  }

  Future<void> saveCachedPrices(Map<String, double> prices) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pricesKey, jsonEncode(prices));
    await prefs.setInt(
        _pricesUpdatedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<Map<String, double>> loadCachedPrices() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_pricesKey)) return {};
    final raw = prefs.getString(_pricesKey)!;
    final Map<String, dynamic> parsed = jsonDecode(raw);
    final Map<String, double> prices = {};
    parsed.forEach((k, v) {
      final num? n = v is num ? v : double.tryParse(v.toString());
      if (n != null) prices[k] = n.toDouble();
    });
    return prices;
  }

  Future<DateTime?> loadPricesLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_pricesUpdatedAtKey)) return null;
    final ms = prefs.getInt(_pricesUpdatedAtKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
