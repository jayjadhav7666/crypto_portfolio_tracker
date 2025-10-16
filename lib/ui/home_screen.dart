import 'package:crypto_portfolio_tracker/bloc/portfolio_bloc.dart';
import 'package:crypto_portfolio_tracker/bloc/portfolio_event.dart';
import 'package:crypto_portfolio_tracker/bloc/portfolio_state.dart';
import 'package:crypto_portfolio_tracker/model/holding_model.dart';
import 'package:crypto_portfolio_tracker/widgets/holding_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_asset_sheet.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final currencyFmt = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: () {
              context.read<PortfolioBloc>().add(LoadCoinList());
            },
          )
        ],
      ),
      body: BlocBuilder<PortfolioBloc, PortfolioState>(
        builder: (context, state) {
          if (state is PortfolioLoading || state is PortfolioInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PortfolioError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(child: Text(state.message)),
              ],
            );
          } else if (state is PortfolioLoaded) {
            final holdings = state.holdings;
            final prices = state.prices;

            final total = holdings.fold<double>(
              0.0,
              (prev, h) {
                final price = prices[h.coinId] ?? 0.0;
                return prev + (price * h.quantity);
              },
            );

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PortfolioBloc>().add(RefreshPrices());
              },
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.indigo.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Portfolio Value',
                            style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          currencyFmt.format(total),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Holdings: ${holdings.length} | Coins cached: ${state.coinListPreview?['count'] ?? '-'}',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: holdings.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 40),
                                Icon(Icons.sentiment_dissatisfied,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 8),
                                Center(
                                  child: Text('No holdings yet. Tap + to add.'),
                                )
                              ],
                            )
                          : ListView.builder(
                              itemCount: holdings.length,
                              itemBuilder: (ctx, i) {
                                final h = holdings[i];
                                final price = prices[h.coinId] ?? 0.0;

                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: i == holdings.length - 1
                                          ? 80.0
                                          : 8.0),
                                  child: GestureDetector(
                                    onLongPress: () {
                                      _showRemoveDialog(context, h);
                                    },
                                    child: HoldingCard(
                                      holding: h,
                                      price: price,
                                      currencyFormatter: currencyFmt,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<Holding?>(
            MaterialPageRoute(
              builder: (ctx) => const AddAssetScreen(),
            ),
          );

          if (result != null) {
            context.read<PortfolioBloc>().add(AddHolding(result));
          }
        },
        label: const Text('Add Asset'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, Holding holding) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Asset'),
        content: Text('Are you sure you want to remove "${holding.name}"?'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(), // Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              context.read<PortfolioBloc>().add(RemoveHolding(holding.coinId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${holding.name} removed')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
