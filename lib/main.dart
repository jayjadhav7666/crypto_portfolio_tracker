import 'package:crypto_portfolio_tracker/bloc/portfolio_event.dart';
import 'package:crypto_portfolio_tracker/ui/splash_screen.dart';
import 'package:crypto_portfolio_tracker/repositories/crypto_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/portfolio_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = CoinRepository();
  runApp(MyApp(repository: repo));
}

class MyApp extends StatelessWidget {
  final CoinRepository repository;
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: repository,
      child: BlocProvider(
        create: (_) => PortfolioBloc(repository: repository)..add(AppStarted()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Crypto Portfolio Tracker',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.light,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              filled: true,
              fillColor: Color(0xFFF6F7FB),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
            ),
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
