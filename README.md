## Crypto Portfolio Tracker

An offline-friendly Flutter app to track your cryptocurrency holdings with a clean Material 3 UI, bottom-sheet asset picker, and cached data for reliable startup without internet.

---

### App setup

- Ensure you have the following installed:
  - Flutter SDK (3.6.x or compatible)
  - Android Studio/Xcode for platform toolchains (as needed)
  - A device or emulator/simulator

- Clone the repository, then install dependencies:

```bash
flutter --version
flutter pub get
```

No API keys are required. The app uses the public CoinGecko API.

---

### How to run

- Android (emulator or device):

```bash
flutter run -d android
```

- iOS (simulator or device; macOS only):

```bash
flutter run -d ios
```

- Web:

```bash
flutter run -d chrome
```

- Windows/macOS/Linux desktop (if enabled in your Flutter install):

```bash
flutter run -d windows   # or macos, linux
```

Build release APK (Android):

```bash
flutter build apk --release
```

---

### Recorded demo (public link)

- Video link: https://drive.google.com/drive/folders/1mvU4zdxRXW5_FsLBM4b8U_9bqz48BJbi?usp=drive_link

Suggested demo flow:
- Launch the app online; show initial coin list load and adding an asset via the bottom sheet.
- Show portfolio updates and prices.
- Close the app, disable network, reopen the app; demonstrate holdings and last-known prices still showing offline.


### Architectural choices

- State management: `flutter_bloc` with a `PortfolioBloc` that orchestrates startup, refresh, and add/remove holding flows.
- Repository pattern: `CoinRepository` abstracts data sources (network + local storage) and provides:
  - Cached coin list (SharedPreferences)
  - Portfolio persistence (SharedPreferences)
  - Last-known prices caching with timestamp (SharedPreferences)
- Offline strategy:
  - On startup and refresh, the bloc attempts to fetch live prices; on failure, it falls back to cached prices.
  - Holdings and the coin list are always loaded from local cache first for fast, reliable startup.
- Networking: `ApiService` calls CoinGecko endpoints for coin list and current USD prices.
- UI/UX:
  - Material 3 theme with `colorSchemeSeed` for consistent styling.
  - Enhanced add-asset  with search, selection, and quantity input.

---

### Third-party libraries

- flutter_bloc: State management for predictable, testable flows.
- http: Simple HTTP client for REST calls to CoinGecko.
- intl: Currency formatting for portfolio totals.
- shared_preferences: Lightweight local storage for coin list, holdings, and last-known prices.

All versions are defined in `pubspec.yaml`.

---

### Key files

- `lib/main.dart`: App bootstrap, theme, and providers.
- `lib/bloc/portfolio_bloc.dart`: Business logic for loading data, refreshing prices, and portfolio mutations.
- `lib/repositories/crypto_repository.dart`: Data access layer; caches and persistence.
- `lib/services/app_services.dart`: API client for CoinGecko.
- `lib/ui/home_screen.dart`: Main portfolio UI and bottom sheet trigger.
- `lib/ui/add_asset_sheet.dart`: Asset picker and quantity input bottom sheet.
- `lib/widgets/holding_card.dart`: Holding display component.

---

### Offline behavior details

- The app persists:
  - Portfolio: list of holdings
  - Coin list: id/symbol/name
  - Last-known prices: coinId → USD price (+ lastUpdated timestamp)
- On network failure, prices fall back to the cached values so the portfolio remains visible offline.

---

### Troubleshooting

- If coin list is empty on a fresh install, run online once to seed the cache.
- If builds fail, ensure Flutter and platform SDKs are up to date:

```bash
flutter doctor -v
```



This project is provided as-is for demonstration purposes.
