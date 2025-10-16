import 'dart:convert';
import 'package:crypto_portfolio_tracker/model/coin_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const _base = 'https://api.coingecko.com/api/v3';

  /// Fetches the full coin list (id, symbol, name)
  Future<List<Coin>> fetchCoinList() async {
    final url = Uri.parse('$_base/coins/list');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Failed to fetch coin list');
    final List data = jsonDecode(res.body);
    return data.map((e) => Coin.fromMap(e)).toList();
  }

  /// Fetch current USD prices for given coin ids (comma separated)
  Future<Map<String, double>> fetchPrices(List<String> ids) async {
    if (ids.isEmpty) return {};
    final idsParam = ids.join(',');
    final url =
        Uri.parse('$_base/simple/price?ids=$idsParam&vs_currencies=usd');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Failed to fetch prices');
    final Map<String, dynamic> data = jsonDecode(res.body);
    final Map<String, double> prices = {};
    data.forEach((k, v) {
      if (v is Map && v['usd'] != null) {
        prices[k] = (v['usd'] as num).toDouble();
      }
    });
    return prices;
  }

  Future<Map<String, dynamic>> fetchCoinDetails(String id) async {
    final url = Uri.parse('$_base/coins/$id');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Failed to fetch details');
    return jsonDecode(res.body);
  }
}
