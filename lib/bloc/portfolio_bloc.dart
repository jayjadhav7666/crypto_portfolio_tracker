import 'dart:async';
import 'package:crypto_portfolio_tracker/model/holding_model.dart';
import 'package:crypto_portfolio_tracker/repositories/crypto_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final CoinRepository repository;

  PortfolioBloc({required this.repository}) : super(PortfolioInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoadCoinList>(_onLoadCoinList);
    on<RefreshPrices>(_onRefreshPrices);
    on<AddHolding>(_onAddHolding);
    on<RemoveHolding>(_onRemoveHolding);
  }

  Future<void> _onAppStarted(
      AppStarted event, Emitter<PortfolioState> emit) async {
    emit(PortfolioLoading());
    try {
      final coinMap = await repository.getCoinListCached();
      final holdings = await repository.loadPortfolio();
      Map<String, double> prices;
      try {
        prices = await repository.fetchPricesForHoldings(holdings);
        await repository.saveCachedPrices(prices);
      } catch (_) {
        prices = await repository.loadCachedPrices();
      }
      emit(PortfolioLoaded(
        holdings: holdings,
        prices: prices,
        coinListPreview: {
          'count': coinMap.length,
        },
      ));
    } catch (e) {
      emit(PortfolioError('Failed to initialize: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCoinList(
      LoadCoinList event, Emitter<PortfolioState> emit) async {
    emit(PortfolioLoading());
    try {
      try {
        await repository.refreshCoinList();
      } catch (_) {}
      final coinMap = await repository.getCoinListCached();
      final holdings = await repository.loadPortfolio();
      Map<String, double> prices;
      try {
        prices = await repository.fetchPricesForHoldings(holdings);
        await repository.saveCachedPrices(prices);
      } catch (_) {
        prices = await repository.loadCachedPrices();
      }
      emit(
          PortfolioLoaded(holdings: holdings, prices: prices, coinListPreview: {
        'count': coinMap.length,
      }));
    } catch (e) {
      emit(PortfolioError('Failed to load coin list: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshPrices(
      RefreshPrices event, Emitter<PortfolioState> emit) async {
    final current = state;
    if (current is PortfolioLoaded) {
      emit(PortfolioLoading());
      try {
        final prices =
            await repository.fetchPricesForHoldings(current.holdings);
        await repository.saveCachedPrices(prices);
        emit(PortfolioLoaded(
            holdings: current.holdings,
            prices: prices,
            coinListPreview: current.coinListPreview));
      } catch (e) {
        final cached = await repository.loadCachedPrices();
        emit(PortfolioLoaded(
            holdings: current.holdings,
            prices: cached,
            coinListPreview: current.coinListPreview));
      }
    }
  }

  Future<void> _onAddHolding(
      AddHolding event, Emitter<PortfolioState> emit) async {
    final current = state;
    if (current is PortfolioLoaded) {
      try {
        final updated = List<Holding>.from(current.holdings);
        final idx = updated.indexWhere((h) => h.coinId == event.holding.coinId);
        if (idx >= 0) {
          final newQty = updated[idx].quantity + event.holding.quantity;
          updated[idx] = updated[idx].copyWith(quantity: newQty);
        } else {
          updated.add(event.holding);
        }
        await repository.savePortfolio(updated);
        final prices = await repository.fetchPricesForHoldings(updated);
        emit(PortfolioLoaded(
            holdings: updated,
            prices: prices,
            coinListPreview: current.coinListPreview));
      } catch (e) {
        emit(PortfolioError('Failed to add holding: ${e.toString()}'));
      }
    }
  }

  Future<void> _onRemoveHolding(
      RemoveHolding event, Emitter<PortfolioState> emit) async {
    final current = state;
    if (current is PortfolioLoaded) {
      try {
        final updated =
            current.holdings.where((h) => h.coinId != event.coinId).toList();
        await repository.savePortfolio(updated);
        final prices = await repository.fetchPricesForHoldings(updated);
        emit(PortfolioLoaded(
            holdings: updated,
            prices: prices,
            coinListPreview: current.coinListPreview));
      } catch (e) {
        emit(PortfolioError('Failed to remove holding: ${e.toString()}'));
      }
    }
  }
}
