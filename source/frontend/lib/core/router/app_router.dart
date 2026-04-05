// lib/core/router/app_router.dart
// KriptoPilot — GoRouter setup
// Routes: onboarding → shell (dashboard | trades | analytics | settings)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/trades/presentation/trades_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/main_shell.dart';

part 'app_router.g.dart';

// ─── Route paths ──────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const root       = '/';
  static const onboarding = '/onboarding';
  static const dashboard  = '/dashboard';
  static const trades     = '/trades';
  static const analytics  = '/analytics';
  static const settings   = '/settings';
}

// ─── Auth state stream ────────────────────────────────────────────────────────

@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}

// ─── Router ───────────────────────────────────────────────────────────────────

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authNotifier = _AuthChangeNotifier(ref);
  late final GoRouter router;

  ref.listen(authStateProvider, (_, next) {
    final event = next.valueOrNull?.event;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (event == AuthChangeEvent.signedIn) {
        router.go(AppRoutes.dashboard);
      } else if (event == AuthChangeEvent.signedOut) {
        router.go(AppRoutes.onboarding);
      }
    });
  });

  router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: false,
    refreshListenable: authNotifier,

    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthenticated = session != null;
      final goingTo = state.matchedLocation;

      const publicRoutes = {AppRoutes.root, AppRoutes.onboarding};

      if (!isAuthenticated && !publicRoutes.contains(goingTo)) {
        return AppRoutes.onboarding;
      }
      if (isAuthenticated && goingTo == AppRoutes.onboarding) {
        return AppRoutes.dashboard;
      }
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (_, __) => AppRoutes.dashboard,
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => _fadeTransition(
              state: state,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.trades,
            name: 'trades',
            pageBuilder: (context, state) => _fadeTransition(
              state: state,
              child: const TradesScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            name: 'analytics',
            pageBuilder: (context, state) => _fadeTransition(
              state: state,
              child: const AnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => _fadeTransition(
              state: state,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.colorRed),
            const SizedBox(height: 16),
            Text(S.of(context).commonPageNotFound,
                style: const TextStyle(color: AppTheme.textPrimary)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: Text(S.of(context).commonGoHome),
            ),
          ],
        ),
      ),
    ),
  );

  return router;
}

// ─── Transition helpers ───────────────────────────────────────────────────────

CustomTransitionPage<void> _fadeTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

// ─── Auth change listenable ───────────────────────────────────────────────────

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
