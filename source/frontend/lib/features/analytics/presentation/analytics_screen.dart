// lib/features/analytics/presentation/analytics_screen.dart
// KriptoPilot — Analytics screen with equity curve, win rate, pair performance

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/analytics_providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _timeRange = '7D';

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final statsAsync = ref.watch(analyticsStatsProvider);
    final equityAsync = ref.watch(equityCurveProvider(_timeRange));

    return Scaffold(
      appBar: AppBar(title: Text(s.analyticsTitle)),
      body: statsAsync.when(
        data: (stats) {
          if (stats.totalTrades < 5) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bar_chart_outlined, size: 64, color: AppTheme.textHint),
                    const SizedBox(height: 16),
                    Text(s.analyticsNeedMoreData, style: AppTheme.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(s.analyticsNeedMoreDataSubtitle, style: AppTheme.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('${stats.totalTrades}/5', style: AppTheme.headlineLarge.copyWith(color: AppTheme.colorGreen)),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Summary Cards ─────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SummaryCard(label: s.winRate,     value: '${stats.winRate.toStringAsFixed(1)}%',  color: stats.winRate >= 50 ? AppTheme.colorGreen : AppTheme.colorRed),
                    const SizedBox(width: 8),
                    _SummaryCard(label: s.totalPnl,    value: '${stats.totalPnl >= 0 ? '+' : ''}\$${stats.totalPnl.toStringAsFixed(2)}', color: stats.totalPnl >= 0 ? AppTheme.colorGreen : AppTheme.colorRed),
                    const SizedBox(width: 8),
                    _SummaryCard(label: s.totalTrades, value: stats.totalTrades.toString(), color: AppTheme.colorBlue),
                    const SizedBox(width: 8),
                    _SummaryCard(label: s.bestTrade,   value: '+\$${stats.bestTrade.toStringAsFixed(2)}',  color: AppTheme.colorGreen),
                    const SizedBox(width: 8),
                    _SummaryCard(label: s.worstTrade,  value: '\$${stats.worstTrade.toStringAsFixed(2)}',  color: AppTheme.colorRed),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Equity Curve ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.equityCurve, style: AppTheme.headlineMedium),
                  Row(
                    children: [
                      _TimeRangeButton(label: s.timeRange7d,  value: '7D',  current: _timeRange, onTap: (v) => setState(() => _timeRange = v)),
                      const SizedBox(width: 4),
                      _TimeRangeButton(label: s.timeRange30d, value: '30D', current: _timeRange, onTap: (v) => setState(() => _timeRange = v)),
                      const SizedBox(width: 4),
                      _TimeRangeButton(label: s.timeRangeAll, value: 'ALL', current: _timeRange, onTap: (v) => setState(() => _timeRange = v)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: equityAsync.when(
                  data: (points) => points.isEmpty
                      ? Center(child: Text(s.commonLoading, style: AppTheme.bodyMedium))
                      : _EquityChart(points: points),
                  loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.colorGreen)),
                  error: (e, _) => Center(child: Text(S.of(context).commonError, style: AppTheme.bodyMedium)),
                ),
              ),
              const SizedBox(height: 24),

              // ── Win/Loss Breakdown ────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.colorGreen.withOpacity(0.3), width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(s.wins, style: AppTheme.labelMedium),
                          const SizedBox(height: 4),
                          Text(stats.wins.toString(),
                              style: AppTheme.headlineLarge.copyWith(color: AppTheme.colorGreen)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.colorRed.withOpacity(0.3), width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(s.losses, style: AppTheme.labelMedium),
                          const SizedBox(height: 4),
                          Text(stats.losses.toString(),
                              style: AppTheme.headlineLarge.copyWith(color: AppTheme.colorRed)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.colorGreen)),
        error: (e, _) => Center(child: Text(S.of(context).commonError, style: AppTheme.bodyMedium)),
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bgBorder, width: 1),
      ),
      child: Column(
        children: [
          Text(label, style: AppTheme.labelSmall, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.titleLarge.copyWith(color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Time Range Button ────────────────────────────────────────────────────────

class _TimeRangeButton extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final void Function(String) onTap;

  const _TimeRangeButton({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.colorGreen.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppTheme.colorGreen : AppTheme.bgBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.labelSmall.copyWith(
            color: isSelected ? AppTheme.colorGreen : AppTheme.textHint,
          ),
        ),
      ),
    );
  }
}

// ─── Equity Chart ─────────────────────────────────────────────────────────────

class _EquityChart extends StatelessWidget {
  final List<FlSpot> points;
  const _EquityChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final isPositive = points.last.y >= points.first.y;
    final lineColor = isPositive ? AppTheme.colorGreen : AppTheme.colorRed;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.bgBorder,
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            color: lineColor,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withOpacity(0.1),
            ),
          ),
        ],
        backgroundColor: AppTheme.bgCard,
      ),
    );
  }
}
