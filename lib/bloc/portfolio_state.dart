import 'package:crypto_portfolio_tracker/model/holding_model.dart';


abstract class PortfolioState {}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final List<Holding> holdings;
  final Map<String, double> prices; // coinId -> price
  final Map<String, dynamic>? coinListPreview; // optional small preview

  PortfolioLoaded({
    required this.holdings,
    required this.prices,
    this.coinListPreview,
  });
}

class PortfolioError extends PortfolioState {
  final String message;
  PortfolioError(this.message);
}
