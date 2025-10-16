import 'package:crypto_portfolio_tracker/model/holding_model.dart';
abstract class PortfolioEvent {}

class AppStarted extends PortfolioEvent {}

class LoadCoinList extends PortfolioEvent {}

class RefreshPrices extends PortfolioEvent {}

class AddHolding extends PortfolioEvent {
  final Holding holding;
  AddHolding(this.holding);
}

class RemoveHolding extends PortfolioEvent {
  final String coinId;
  RemoveHolding(this.coinId);
}
