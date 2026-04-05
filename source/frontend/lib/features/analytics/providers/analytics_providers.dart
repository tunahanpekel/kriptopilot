// lib/features/analytics/providers/analytics_providers.dart
// KriptoPilot — Analytics state providers

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client.dart';
import '../../../features/dashboard/providers/dashboard_providers.dart';

// ─── Analytics Stats ──────────────────────────────────────────────────────────

class AnalyticsStats {
  final int totalTrades;
  final int wins;
  final int losses;
  final double winRate;
  final double totalPnl;
  final double bestTrade;
  final double worstTrade;
  final double avgConfidence;

  const AnalyticsStats({
    required this.totalTrades,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.totalPnl,
    required this.bestTrade,
    required this.worstTrade,
    required this.avgConfidence,
  });
}

final analyticsStatsProvider = FutureProvider<AnalyticsStats>((ref) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) {
    return const AnalyticsStats(
      totalTrades: 0, wins: 0, losses: 0, winRate: 0,
      totalPnl: 0, bestTrade: 0, worstTrade: 0, avgConfidence: 0,
    );
  }

  final rows = await supabase
      .from('trades')
      .select('realized_pnl, claude_confidence')
      .eq('user_id', userId)
      .eq('status', 'closed')
      .is_('deleted_at', null);

  if (rows.isEmpty) {
    return const AnalyticsStats(
      totalTrades: 0, wins: 0, losses: 0, winRate: 0,
      totalPnl: 0, bestTrade: 0, worstTrade: 0, avgConfidence: 0,
    );
  }

  int wins = 0;
  int losses = 0;
  double totalPnl = 0;
  double bestTrade = double.negativeInfinity;
  double worstTrade = double.infinity;
  double totalConfidence = 0;

  for (final row in rows) {
    final pnl = row['realized_pnl'] != null
        ? (row['realized_pnl'] as num).toDouble()
        : 0.0;
    final conf = (row['claude_confidence'] as num).toDouble();
    totalPnl += pnl;
    totalConfidence += conf;
    if (pnl > 0) wins++;
    else losses++;
    if (pnl > bestTrade) bestTrade = pnl;
    if (pnl < worstTrade) worstTrade = pnl;
  }

  final total = rows.length;

  return AnalyticsStats(
    totalTrades: total,
    wins: wins,
    losses: losses,
    winRate: total > 0 ? (wins / total) * 100 : 0,
    totalPnl: totalPnl,
    bestTrade: bestTrade.isNegativeInfinity ? 0 : bestTrade,
    worstTrade: worstTrade.isInfinite ? 0 : worstTrade,
    avgConfidence: total > 0 ? totalConfidence / total : 0,
  );
});

// ─── Equity Curve ─────────────────────────────────────────────────────────────

final equityCurveProvider =
    FutureProvider.family<List<FlSpot>, String>((ref, timeRange) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  final config = await ref.watch(botConfigProvider.future);
  if (config == null) return [];

  DateTime since;
  switch (timeRange) {
    case '30D':
      since = DateTime.now().subtract(const Duration(days: 30));
    case 'ALL':
      since = DateTime(2020);
    default: // 7D
      since = DateTime.now().subtract(const Duration(days: 7));
  }

  final rows = await supabase
      .from('portfolio_snapshots')
      .select('total_usdt, snapshot_at')
      .eq('user_id', userId)
      .eq('is_testnet', config.useTestnet)
      .gte('snapshot_at', since.toIso8601String())
      .order('snapshot_at', ascending: true);

  if (rows.isEmpty) return [];

  return rows.asMap().entries.map((entry) {
    final total = (entry.value['total_usdt'] as num).toDouble();
    return FlSpot(entry.key.toDouble(), total);
  }).toList();
});
