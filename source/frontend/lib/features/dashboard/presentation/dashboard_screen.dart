// lib/features/dashboard/presentation/dashboard_screen.dart
// KriptoPilot — Dashboard screen
// Shows: balance, daily P&L, open positions, bot toggle, recent trades

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/position_model.dart';
import '../../../shared/models/bot_config_model.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);

    final balanceAsync = ref.watch(balanceProvider);
    final positionsAsync = ref.watch(openPositionsProvider);
    final botConfigAsync = ref.watch(botConfigProvider);
    final recentTradesAsync = ref.watch(recentTradesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.dashboardTitle),
        actions: [
          // Testnet badge
          botConfigAsync.whenOrNull(
            data: (config) => config?.useTestnet == true
                ? Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.colorYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.colorYellow, width: 1),
                    ),
                    child: Text(
                      s.testnetBadge,
                      style: AppTheme.labelSmall.copyWith(color: AppTheme.colorYellow),
                    ),
                  )
                : null,
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.colorGreen,
        onRefresh: () async {
          ref.invalidate(balanceProvider);
          ref.invalidate(openPositionsProvider);
          ref.invalidate(botConfigProvider);
          ref.invalidate(recentTradesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Balance Card ──────────────────────────────────────────────
            _BalanceCard(balanceAsync: balanceAsync),
            const SizedBox(height: 16),

            // ── Bot Control ───────────────────────────────────────────────
            botConfigAsync.when(
              data: (config) => config != null
                  ? _BotControlCard(config: config)
                  : const SizedBox.shrink(),
              loading: () => _ShimmerCard(height: 80),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // ── Open Positions ────────────────────────────────────────────
            Row(
              children: [
                Text(s.openPositions, style: AppTheme.headlineMedium),
              ],
            ),
            const SizedBox(height: 8),
            positionsAsync.when(
              data: (positions) => positions.isEmpty
                  ? _EmptyState(message: s.noOpenPositions)
                  : Column(
                      children: positions
                          .map((p) => _PositionCard(position: p))
                          .toList(),
                    ),
              loading: () => _ShimmerCard(height: 72),
              error: (e, _) => _ErrorState(message: s.commonError),
            ),
            const SizedBox(height: 16),

            // ── Recent Trades ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.recentTrades, style: AppTheme.headlineMedium),
                TextButton(
                  onPressed: () => context.go(AppRoutes.trades),
                  child: Text(s.seeAll,
                      style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.colorGreen)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            recentTradesAsync.when(
              data: (trades) => trades.isEmpty
                  ? _EmptyState(message: s.noTradesYet)
                  : Column(
                      children: trades
                          .map((t) => _TradeListItem(
                                pair: t.pair,
                                action: t.action,
                                pnl: t.realizedPnl,
                                pnlPct: t.realizedPnlPct,
                                date: t.openedAt,
                                isTestnet: t.isTestnet,
                              ))
                          .toList(),
                    ),
              loading: () => _ShimmerCard(height: 72),
              error: (e, _) => _ErrorState(message: s.commonError),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ─── Balance Card ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final AsyncValue<({double total, double free, double locked, double dailyPnl, double dailyPnlPct})> balanceAsync;

  const _BalanceCard({required this.balanceAsync});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder, width: 1),
      ),
      child: balanceAsync.when(
        data: (balance) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.totalBalance, style: AppTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              '\$${balance.total.toStringAsFixed(2)} USDT',
              style: AppTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(s.dailyPnl, style: AppTheme.labelMedium),
                const SizedBox(width: 8),
                Text(
                  '${balance.dailyPnl >= 0 ? '+' : ''}\$${balance.dailyPnl.toStringAsFixed(2)} '
                  '(${balance.dailyPnlPct >= 0 ? '+' : ''}${balance.dailyPnlPct.toStringAsFixed(2)}%)',
                  style: AppTheme.labelLarge.copyWith(
                    color: balance.dailyPnl >= 0
                        ? AppTheme.colorGreen
                        : AppTheme.colorRed,
                  ),
                ),
              ],
            ),
          ],
        ),
        loading: () => _shimmerLines(),
        error: (e, _) => Text(s.errorLoadingBalance,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.colorRed)),
      ),
    );
  }

  Widget _shimmerLines() {
    return Shimmer.fromColors(
      baseColor: AppTheme.bgSurface,
      highlightColor: AppTheme.bgBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 14, width: 100, color: Colors.white),
          const SizedBox(height: 8),
          Container(height: 32, width: 200, color: Colors.white),
          const SizedBox(height: 8),
          Container(height: 14, width: 150, color: Colors.white),
        ],
      ),
    );
  }
}

// ─── Bot Control Card ─────────────────────────────────────────────────────────

class _BotControlCard extends ConsumerWidget {
  final BotConfigModel config;
  const _BotControlCard({required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: config.isRunning ? AppTheme.colorGreen.withOpacity(0.5) : AppTheme.bgBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.smart_toy_outlined,
            color: config.isRunning ? AppTheme.colorGreen : AppTheme.textHint,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.isRunning ? s.botRunning : s.botStopped,
                  style: AppTheme.titleMedium.copyWith(
                    color: config.isRunning ? AppTheme.colorGreen : AppTheme.textSecondary,
                  ),
                ),
                Text(
                  config.tradingPairs.join(', '),
                  style: AppTheme.labelMedium,
                ),
              ],
            ),
          ),
          Switch(
            value: config.isRunning,
            onChanged: (value) => _toggleBot(context, ref, value),
          ),
        ],
      ),
    );
  }

  void _toggleBot(BuildContext context, WidgetRef ref, bool newValue) {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(newValue ? s.botStartConfirmTitle : s.botStopConfirmTitle),
        content: Text(newValue ? s.botStartConfirmBody : s.botStopConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(botConfigProvider.notifier).toggleBot(newValue);
            },
            child: Text(s.commonConfirm),
          ),
        ],
      ),
    );
  }
}

// ─── Position Card ────────────────────────────────────────────────────────────

class _PositionCard extends StatelessWidget {
  final PositionModel position;
  const _PositionCard({required this.position});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pnl = position.unrealizedPnl ?? 0;
    final pnlPct = position.unrealizedPnlPct ?? 0;
    final isProfit = pnl >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bgBorder, width: 1),
      ),
      child: Row(
        children: [
          _ActionBadge(action: position.action),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(position.pair, style: AppTheme.titleMedium),
                Text(
                  s.dashboardEntryPrice(position.entryPrice.toStringAsFixed(4)),
                  style: AppTheme.labelMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isProfit ? '+' : ''}\$${pnl.toStringAsFixed(2)}',
                style: AppTheme.labelLarge.copyWith(
                  color: isProfit ? AppTheme.colorGreen : AppTheme.colorRed,
                ),
              ),
              Text(
                '${isProfit ? '+' : ''}${pnlPct.toStringAsFixed(2)}%',
                style: AppTheme.labelSmall.copyWith(
                  color: isProfit ? AppTheme.colorGreen : AppTheme.colorRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Trade List Item ──────────────────────────────────────────────────────────

class _TradeListItem extends StatelessWidget {
  final String pair;
  final String action;
  final double? pnl;
  final double? pnlPct;
  final DateTime date;
  final bool isTestnet;

  const _TradeListItem({
    required this.pair,
    required this.action,
    this.pnl,
    this.pnlPct,
    required this.date,
    required this.isTestnet,
  });

  @override
  Widget build(BuildContext context) {
    final hasPnl = pnl != null;
    final isProfit = (pnl ?? 0) >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bgBorder, width: 1),
      ),
      child: Row(
        children: [
          _ActionBadge(action: action),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pair, style: AppTheme.titleMedium),
                Text(
                  '${date.day}/${date.month}/${date.year} '
                  '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                  style: AppTheme.labelSmall,
                ),
              ],
            ),
          ),
          if (hasPnl)
            Text(
              '${isProfit ? '+' : ''}\$${pnl!.toStringAsFixed(2)}',
              style: AppTheme.labelLarge.copyWith(
                color: isProfit ? AppTheme.colorGreen : AppTheme.colorRed,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Action Badge ─────────────────────────────────────────────────────────────

class _ActionBadge extends ConsumerWidget {
  final String action;
  const _ActionBadge({required this.action});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);

    Color color;
    String label;
    switch (action.toLowerCase()) {
      case 'buy':
        color = AppTheme.colorGreen;
        label = s.tradesBuy;
      case 'sell':
        color = AppTheme.colorRed;
        label = s.tradesSell;
      default:
        color = AppTheme.colorYellow;
        label = s.tradesHold;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: AppTheme.labelSmall.copyWith(color: color, letterSpacing: 0.5),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(message, style: AppTheme.bodyMedium),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(message,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.colorRed)),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double height;
  const _ShimmerCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.bgCard,
      highlightColor: AppTheme.bgSurface,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
