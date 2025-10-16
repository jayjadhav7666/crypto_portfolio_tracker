// import 'package:crypto_portfolio_tracker/model/coin_model.dart';
// import 'package:crypto_portfolio_tracker/model/holding_model.dart';
// import 'package:crypto_portfolio_tracker/repositories/crypto_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class AddAssetSheet extends StatefulWidget {
//   const AddAssetSheet({super.key});

//   @override
//   State<AddAssetSheet> createState() => _AddAssetSheetState();
// }

// class _AddAssetSheetState extends State<AddAssetSheet> {
//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _qtyController = TextEditingController();
//   Map<String, Coin> _coinMap = {};
//   List<Coin> _filtered = [];
//   Coin? _selected;

//   bool _loading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _loadCoinList();
//     _searchController.addListener(_onSearch);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _qtyController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadCoinList() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final repo = RepositoryProvider.of<CoinRepository>(context);
//       final map = await repo.getCoinListCached();
//       setState(() {
//         _coinMap = map;
//         _filtered = map.values.take(200).toList(); // initial small preview
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _loading = false;
//       });
//     }
//   }

//   void _onSearch() {
//     final q = _searchController.text.toLowerCase().trim();
//     if (q.isEmpty) {
//       setState(() {
//         _filtered = _coinMap.values.take(200).toList();
//       });
//       return;
//     }
//     final results = _coinMap.values
//         .where((c) {
//           return c.name.toLowerCase().contains(q) ||
//               c.symbol.toLowerCase().contains(q);
//         })
//         .take(50)
//         .toList();
//     setState(() {
//       _filtered = results;
//     });
//   }

//   void _submit() {
//     final qtyStr = _qtyController.text.trim();
//     if (_selected == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Select a coin')));
//       return;
//     }
//     final qty = double.tryParse(qtyStr);
//     if (qty == null || qty <= 0) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Enter valid quantity')));
//       return;
//     }
//     final holding = Holding(
//       coinId: _selected!.id,
//       name: _selected!.name,
//       symbol: _selected!.symbol.toUpperCase(),
//       quantity: qty,
//     );
//     Navigator.of(context).pop(holding);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     return SafeArea(
//       child: DraggableScrollableSheet(
//         initialChildSize: 0.92,
//         minChildSize: 0.55,
//         maxChildSize: 0.95,
//         builder: (ctx, ctrl) => Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surface,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.06),
//                 blurRadius: 12,
//                 offset: const Offset(0, -2),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     height: 5,
//                     width: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(3),
//                     ),
//                     margin: const EdgeInsets.only(bottom: 12),
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     const Icon(Icons.add_circle_outline, size: 20),
//                     const SizedBox(width: 8),
//                     Text('Add Asset',
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleMedium
//                             ?.copyWith(fontWeight: FontWeight.w600)),
//                     const Spacer(),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.of(context).pop(),
//                       tooltip: 'Close',
//                     )
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: _searchController,
//                   textInputAction: TextInputAction.search,
//                   decoration: const InputDecoration(
//                     labelText: 'Search coin by name or symbol',
//                     prefixIcon: Icon(Icons.search),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 if (_loading) const LinearProgressIndicator(minHeight: 2),
//                 if (_error != null)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.error_outline,
//                             color: Colors.red, size: 18),
//                         const SizedBox(width: 6),
//                         Expanded(child: Text('Error: $_error')),
//                       ],
//                     ),
//                   ),
//                 Expanded(
//                   child: _filtered.isEmpty
//                       ? ListView(
//                           controller: ctrl,
//                           children: const [
//                             SizedBox(height: 40),
//                             Center(child: Text('No results')),
//                           ],
//                         )
//                       : ListView.separated(
//                           controller: ctrl,
//                           itemCount: _filtered.length,
//                           separatorBuilder: (_, __) => const Divider(height: 1),
//                           itemBuilder: (ctx, i) {
//                             final c = _filtered[i];
//                             final selected = _selected?.id == c.id;
//                             return ListTile(
//                               selected: selected,
//                               selectedTileColor:
//                                   colorScheme.primary.withOpacity(0.06),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               title: Text(c.name),
//                               subtitle: Text(c.symbol.toUpperCase()),
//                               trailing: selected
//                                   ? Icon(Icons.check_circle,
//                                       color: colorScheme.primary)
//                                   : const Icon(Icons.chevron_right),
//                               onTap: () {
//                                 setState(() {
//                                   _selected = c;
//                                   _searchController.text = c.name;
//                                 });
//                               },
//                             );
//                           },
//                         ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _qtyController,
//                         keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true),
//                         decoration: const InputDecoration(
//                           labelText: 'Quantity',
//                           prefixIcon: Icon(Icons.numbers),
//                           hintText: 'e.g. 0.5',
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     FilledButton.icon(
//                       onPressed: _submit,
//                       icon: const Icon(Icons.save),
//                       label: const Text('Save'),
//                       style: FilledButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 18, vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_portfolio_tracker/model/coin_model.dart';
import 'package:crypto_portfolio_tracker/model/holding_model.dart';
import 'package:crypto_portfolio_tracker/repositories/crypto_repository.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final FocusNode _qtyFocusNode = FocusNode();

  Map<String, Coin> _coinMap = {};
  List<Coin> _filtered = [];
  Coin? _selected;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCoinList();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    _qtyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCoinList() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = RepositoryProvider.of<CoinRepository>(context);
      final map = await repo.getCoinListCached();
      setState(() {
        _coinMap = map;
        _filtered = map.values.take(200).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    if (q.isEmpty) {
      setState(() {
        _filtered = _coinMap.values.take(200).toList();
      });
      return;
    }
    final results = _coinMap.values
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.symbol.toLowerCase().contains(q))
        .take(50)
        .toList();
    setState(() {
      _filtered = results;
    });
  }

  void _toggleSelection(Coin coin) {
    setState(() {
      if (_selected?.id == coin.id) {
        _selected = null; // remove selection if tapped again
        _qtyController.clear();
      } else {
        _selected = coin;
        _searchController.text = coin.name;
      }
    });
  }

  void _submit() {
    final qtyStr = _qtyController.text.trim();
    if (_selected == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select a coin')));
      return;
    }
    final qty = double.tryParse(qtyStr);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter valid quantity')));
      return;
    }

    final holding = Holding(
      coinId: _selected!.id,
      name: _selected!.name,
      symbol: _selected!.symbol.toUpperCase(),
      quantity: qty,
    );

    Navigator.of(context).pop(holding);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true, // ensures field stays above keyboard
      appBar: AppBar(
        title: const Text('Add Asset'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Search coin by name or symbol',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 8),
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 6),
                      Expanded(child: Text('Error: $_error')),
                    ],
                  ),
                ),
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(child: Text('No results'))
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final c = _filtered[i];
                          final selected = _selected?.id == c.id;
                          return ListTile(
                            selected: selected,
                            selectedTileColor:
                                colorScheme.primary.withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(c.name),
                            subtitle: Text(c.symbol.toUpperCase()),
                            trailing: selected
                                ? Icon(Icons.check_circle,
                                    color: colorScheme.primary)
                                : const Icon(Icons.chevron_right),
                            onTap: () => _toggleSelection(c),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selected != null
                    ? Row(
                        key: ValueKey(_selected!.id),
                        children: [
                          Expanded(
                            child: TextField(
                              focusNode: _qtyFocusNode,
                              controller: _qtyController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText:
                                    'Quantity for ${_selected!.symbol.toUpperCase()}',
                                prefixIcon: const Icon(Icons.numbers),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.save),
                            label: const Text('Save'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
