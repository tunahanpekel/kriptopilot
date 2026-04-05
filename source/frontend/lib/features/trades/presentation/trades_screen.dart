// lib/features/trades/presentation/trades_screen.dart
// KriptoPilot — Trades history screen with Claude analysis detail

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/trade_model.dart';
import '../providers/trades_providers.dart';

class TradesScreen extends ConsumerStatefulWidget {
  const TradesScreen({super.key});

  @override
  ConsumerState<TradesScreen> createState() => _TradesScreenState();
}

class _TradesScreenState extends ConsumerState<TradesScreen> {
  String _filter = 'all'; // 'all' | 'buy' | 'sell' | 'profit' | 'loss'

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final tradesAsync = ref.watch(tradesProvider(_filter));

    return Scaffold(
      appBar: AppBar(title: Text(s.tradesTitle)),
      body: Column(
        children: [
          // ── Filter Chips ──────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(label: s.tradesFilterAll,    value: 'all',    current: _filter, onTap: (v) => setState(() => _filter = v)),
                const SizedBox(width: 8),
                _FilterChip(label: s.tradesBuy,          value: 'buy',    current: _filter, onTap: (v) => setState(() => _filter = v)),
                const SizedBox(width: 8),
                _FilterChip(label: s.tradesSell,         value: 'sell',   current: _filter, onTap: (v) => setState(() => _filter = v)),
                const SizedBox(width: 8),
                _FilterChip(label: s.tradesFilterProfit, value: 'profit', current: _filter, onTap: (v) => setState(() => _filter = v)),
                const SizedBox(width: 8),
                _FilterChip(label: s.tradesFilterLoss,   value: 'loss',   current: _filter, onTap: (v) => setState(() => _filter = v)),
              ],
            ),
          ),

          // ── Trade List ────────────────────────────────────────────────
          Expanded(
            child: tradesAsync.when(
              data: (trades) => trades.isEmpty
                  ? _TradesEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: trades.length,
                      itemBuilder: (context, i) => _TradeCard(
                        trade: trades[i],
                        onTap: () => _showTradeDetail(context, trades[i]),
                      ),
                    ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.colorGreen),
              ),
              error: (e, _) => Center(
                child: Text(S.of(context).commonError,
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.colorRed)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTradeDetail(BuildContext context, TradeModel trade) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TradeDetailSheet(trade: trade),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final void Function(String) onTap;

  const _FilterChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.colorGreen.withOpacity(0.15)
              : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.colorGreen : AppTheme.bgBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: isSelected ? AppTheme.colorGreen : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Trade Card ───────────────────────────────────────────────────────────────

class _TradeCard extends ConsumerWidget {
  final TradeModel trade;
  final VoidCallback onTap;

  const _TradeCard({required this.trade, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final pnl = trade.realizedPnl;
    final isProfit = (pnl ?? 0) >= 0;
    final isOpen = trade.isOpen;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.bgBorder, width: 1),
        ),
        child: Row(
          children: [
            // Action badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: trade.isBuy
                    ? AppTheme.colorGreen.withOpacity(0.15)
                    : AppTheme.colorRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                trade.isBuy ? s.tradesBuy : s.tradesSell,
                style: AppTheme.labelSmall.copyWith(
                  color: trade.isBuy ? AppTheme.colorGreen : AppTheme.colorRed,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trade.pair, style: AppTheme.titleMedium),
                  Text(
                    '${trade.openedAt.day}/${trade.openedAt.month}/${trade.openedAt.year}',
                    style: AppTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isOpen)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.colorYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      s.tradesOpen,
                      style: AppTheme.labelSmall.copyWith(color: AppTheme.colorYellow),
                    ),
                  )
                else if (pnl != null) ...[
                  Text(
                    '${isProfit ? '+' : ''}\$${pnl.toStringAsFixed(2)}',
                    style: AppTheme.labelLarge.copyWith(
                      color: isProfit ? AppTheme.colorGreen : AppTheme.colorRed,
                    ),
                  ),
                  if (trade.realizedPnlPct != null)
                    Text(
                      '${isProfit ? '+' : ''}${trade.realizedPnlPct!.toStringAsFixed(2)}%',
                      style: AppTheme.labelSmall.copyWith(
                        color: isProfit ? AppTheme.colorGreen : AppTheme.colorRed,
                      ),
                    ),
                ],
                // Claude confidence
                Text(
                  '${(trade.claudeConfidence * 100).toStringAsFixed(0)}%',
                  style: AppTheme.labelSmall.copyWith(color: AppTheme.colorBlue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Trade Detail Sheet ───────────────────────────────────────────────────────

class _TradeDetailSheet extends ConsumerWidget {
  final TradeModel trade;
  const _TradeDetailSheet({required this.trade});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final isProfit = (trade.realizedPnl ?? 0) >= 0;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Row(
            children: [
              Text(trade.pair, style: AppTheme.headlineLarge),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trade.isBuy
                      ? AppTheme.colorGreen.withOpacity(0.15)
                      : AppTheme.colorRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trade.isBuy ? s.tradesBuy : s.tradesSell,
                  style: AppTheme.labelMedium.copyWith(
                    color: trade.isBuy ? AppTheme.colorGreen : AppTheme.colorRed,
                  ),
                ),
              ),
              if (trade.isTestnet) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.colorYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(s.tradesTestnet,
                      style: AppTheme.labelSmall.copyWith(color: AppTheme.colorYellow)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Price info
          _DetailRow(label: s.tradeEntryPrice, value: '\$${trade.entryPrice.toStringAsFixed(4)}'),
          if (trade.exitPrice != null)
            _DetailRow(label: s.tradeExitPrice, value: '\$${trade.exitPrice!.toStringAsFixed(4)}'),
          _DetailRow(label: s.tradeQuantity, value: '${trade.quantity.toStringAsFixed(6)} ${trade.pair.split('/').first}'),
          if (trade.realizedPnl != null)
            _DetailRow(
              label: s.tradesPnl,
              value: '${isProfit ? '+' : ''}\$${trade.realizedPnl!.toStringAsFixed(2)}',
              valueColor: isProfit ? AppTheme.colorGreen : AppTheme.colorRed,
            ),
          const SizedBox(height: 16),

          // Claude Analysis
          Text(s.claudeAnalysis, style: AppTheme.headlineMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.colorBlue.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(s.claudeConfidence, style: AppTheme.labelMedium),
                    const Spacer(),
                    Text(
                      '${(trade.claudeConfidence * 100).toStringAsFixed(0)}%',
                      style: AppTheme.labelLarge.copyWith(color: AppTheme.colorBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: trade.claudeConfidence,
                    backgroundColor: AppTheme.bgBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      trade.claudeConfidence >= 0.75
                          ? AppTheme.colorGreen
                          : trade.claudeConfidence >= 0.60
                              ? AppTheme.colorYellow
                              : AppTheme.colorRed,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(s.claudeReason, style: AppTheme.labelMedium),
                const SizedBox(height: 4),
                Text(trade.claudeReason, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Technical Indicators
          if (trade.rsi14 != null) ...[
            Text(s.tradeIndicators, style: AppTheme.headlineMedium),
            const SizedBox(height: 8),
            _IndicatorsGrid(trade: trade),
          ],

          const SizedBox(height: 16),
          Text(
            '${s.tradeId}: ${trade.id.substring(0, 8)}...',
            style: AppTheme.labelSmall,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMedium),
          Text(
            value,
            style: AppTheme.labelLarge.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _IndicatorsGrid extends StatelessWidget {
  final TradeModel trade;
  const _IndicatorsGrid({required this.trade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bgBorder, width: 1),
      ),
      child: Column(
        children: [
          // These labels are universal technical analysis abbreviations used
          // globally across all financial markets and languages. They are
          // intentionally not localized (ISO/industry standard terms).
          _IndRow('RSI(14)', trade.rsi14?.toStringAsFixed(2) ?? '-'),
          _IndRow('MACD', trade.macdValue?.toStringAsFixed(4) ?? '-'),
          _IndRow('MACD Signal', trade.macdSignal?.toStringAsFixed(4) ?? '-'),
          _IndRow('BB Upper', '\$${trade.bbUpper?.toStringAsFixed(4) ?? '-'}'),
          _IndRow('BB Lower', '\$${trade.bbLower?.toStringAsFixed(4) ?? '-'}'),
          _IndRow('EMA(9)', '\$${trade.ema9?.toStringAsFixed(4) ?? '-'}'),
          _IndRow('EMA(21)', '\$${trade.ema21?.toStringAsFixed(4) ?? '-'}'),
        ],
      ),
    );
  }
}

class _IndRow extends StatelessWidget {
  final String label;
  final String value;
  const _IndRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.labelMedium),
          Text(value, style: AppTheme.monoMedium),
        ],
      ),
    );
  }
}

class _TradesEmptyState extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textHint),
            const SizedBox(height: 16),
            Text(s.noTradesYet, style: AppTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(s.noTradesSubtitle,
                style: AppTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
