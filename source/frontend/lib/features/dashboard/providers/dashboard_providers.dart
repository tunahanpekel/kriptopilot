// lib/features/dashboard/providers/dashboard_providers.dart
// KriptoPilot — Dashboard state providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../../../core/services/binance_service.dart';
import '../../../shared/models/bot_config_model.dart';
import '../../../shared/models/position_model.dart';
import '../../../shared/models/trade_model.dart';

// ─── Balance Provider ─────────────────────────────────────────────────────────

final balanceProvider = FutureProvider<
    ({double total, double free, double locked, double dailyPnl, double dailyPnlPct})>((ref) async {
  final binance = ref.watch(binanceServiceProvider);
  final config  = await ref.watch(botConfigProvider.future);

  if (config == null) {
    return (total: 0.0, free: 0.0, locked: 0.0, dailyPnl: 0.0, dailyPnlPct: 0.0);
  }

  final balance = await binance.getBalance(useTestnet: config.useTestnet);

  // Get daily P&L from portfolio snapshots
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) {
    return (
      total: balance.total,
      free: balance.free,
      locked: balance.locked,
      dailyPnl: 0.0,
      dailyPnlPct: 0.0,
    );
  }

  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final snapshots = await supabase
      .from('portfolio_snapshots')
      .select('total_usdt, snapshot_at')
      .eq('user_id', userId)
      .eq('is_testnet', config.useTestnet)
      .gte('snapshot_at', yesterday.toIso8601String())
      .order('snapshot_at', ascending: true)
      .limit(1);

  double dailyPnl = 0;
  double dailyPnlPct = 0;
  if (snapshots.isNotEmpty) {
    final oldTotal = (snapshots.first['total_usdt'] as num).toDouble();
    if (oldTotal > 0) {
      dailyPnl    = balance.total - oldTotal;
      dailyPnlPct = (dailyPnl / oldTotal) * 100;
    }
  }

  // Save current snapshot
  await supabase.from('portfolio_snapshots').insert({
    'user_id':    userId,
    'is_testnet': config.useTestnet,
    'total_usdt': balance.total,
    'free_usdt':  balance.free,
    'locked_usdt': balance.locked,
    'daily_pnl':  dailyPnl,
    'daily_pnl_pct': dailyPnlPct,
  });

  return (
    total: balance.total,
    free: balance.free,
    locked: balance.locked,
    dailyPnl: dailyPnl,
    dailyPnlPct: dailyPnlPct,
  );
});

// ─── Open Positions Provider ──────────────────────────────────────────────────

final openPositionsProvider = StreamProvider<List<PositionModel>>((ref) {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return Stream.value([]);

  return supabase
      .from('positions')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .map((rows) => rows
          .where((r) => r['status'] == 'open')
          .map(PositionModel.fromJson)
          .toList());
});

// ─── Recent Trades Provider ───────────────────────────────────────────────────

final recentTradesProvider = FutureProvider<List<TradeModel>>((ref) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  final rows = await supabase
      .from('trades')
      .select()
      .eq('user_id', userId)
      .isFilter('deleted_at', null)
      .order('opened_at', ascending: false)
      .limit(3);

  return rows.map(TradeModel.fromJson).toList();
});

// ─── Bot Config Provider ──────────────────────────────────────────────────────

final botConfigProvider =
    AsyncNotifierProvider<BotConfigNotifier, BotConfigModel?>(() {
  return BotConfigNotifier();
});

class BotConfigNotifier extends AsyncNotifier<BotConfigModel?> {
  @override
  Future<BotConfigModel?> build() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final rows = await supabase
        .from('bot_config')
        .select()
        .eq('user_id', userId)
        .limit(1);

    if (rows.isEmpty) {
      // Create default config for new user
      final defaultConfig = BotConfigModel.defaultConfig(userId);
      final inserted = await supabase
          .from('bot_config')
          .insert(defaultConfig.toJson())
          .select()
          .single();
      return BotConfigModel.fromJson(inserted);
    }

    return BotConfigModel.fromJson(rows.first);
  }

  Future<void> toggleBot(bool isRunning) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('bot_config')
        .update({'is_running': isRunning})
        .eq('user_id', userId);

    state = AsyncData(state.value?.copyWith(isRunning: isRunning));
  }

  Future<void> updateConfig(BotConfigModel updated) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('bot_config')
        .update(updated.toJson())
        .eq('user_id', userId);

    state = AsyncData(updated);
  }
}
