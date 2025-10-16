import 'package:crypto_portfolio_tracker/model/holding_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HoldingCard extends StatelessWidget {
  final Holding holding;
  final double price;
  final NumberFormat currencyFormatter;

  const HoldingCard({
    super.key,
    required this.holding,
    required this.price,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final total = price * holding.quantity;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: ListTile(
        leading: CircleAvatar(
            child: Text(holding.symbol.substring(0, 1).toUpperCase())),
        title: Text('${holding.name} (${holding.symbol.toUpperCase()})'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantity: ${holding.quantity}'),
            Text('Price: ${currencyFormatter.format(price)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(currencyFormatter.format(total),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            // const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
