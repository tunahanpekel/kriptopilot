// ignore_for_file: constant_identifier_names
//
// KriptoPilot app configuration.
// Credentials injected via --dart-define at build time.
//
// Run locally:
//   flutter run \
//     --dart-define=APP_ENV=dev \
//     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=eyJ...

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  AppConfig._();

  // ── Environment ───────────────────────────────────────────────────────────
  static const String _env =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static AppEnvironment get environment {
    switch (_env) {
      case 'prod':    return AppEnvironment.prod;
      case 'staging': return AppEnvironment.staging;
      default:        return AppEnvironment.dev;
    }
  }

  static bool get isDev     => environment == AppEnvironment.dev;
  static bool get isStaging => environment == AppEnvironment.staging;
  static bool get isProd    => environment == AppEnvironment.prod;

  // ── App Identity ──────────────────────────────────────────────────────────
  static const String appName      = 'KriptoPilot';
  static const String packageId    = 'com.kriptopilot.app';
  static const String privacyUrl   = 'https://kriptopilot.app/privacy';
  static const String termsUrl     = 'https://kriptopilot.app/terms';
  static const String supportEmail = 'support@kriptopilot.app';

  // ── Supabase ──────────────────────────────────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_ANON_KEY',
  );

  // ── Claude API ────────────────────────────────────────────────────────────
  // NOTE: Claude API key is used by the Edge Function server-side only.
  // It is set as a Supabase secret, NOT stored in the Flutter app.
  static const String claudeModel = 'claude-sonnet-4-6';

  // ── Binance ───────────────────────────────────────────────────────────────
  // Base URLs — testnet vs mainnet selected at runtime from bot_config
  static const String binanceMainnetBaseUrl = 'https://api.binance.com/api/v3';
  static const String binanceTestnetBaseUrl = 'https://testnet.binance.vision/api/v3';

  // ── Risk Defaults ─────────────────────────────────────────────────────────
  static const double defaultMaxTradePct    = 5.0;
  static const double defaultStopLossPct    = 3.0;
  static const double defaultTakeProfitPct  = 6.0;
  static const double defaultMinConfidence  = 0.75;

  // ── Analysis ──────────────────────────────────────────────────────────────
  static const int analysisIntervalMinutes = 15;

  // ── Validation ────────────────────────────────────────────────────────────
  static void assertProductionConfig() {
    assert(
      supabaseUrl.isNotEmpty && !supabaseUrl.startsWith('https://YOUR'),
      'SUPABASE_URL --dart-define ile set edilmemis!',
    );
    assert(
      supabaseAnonKey.isNotEmpty && !supabaseAnonKey.startsWith('YOUR'),
      'SUPABASE_ANON_KEY --dart-define ile set edilmemis!',
    );
  }
}
