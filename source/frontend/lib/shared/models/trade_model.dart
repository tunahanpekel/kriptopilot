// lib/shared/models/trade_model.dart
// KriptoPilot — Trade data model

class TradeModel {
  final String id;
  final String userId;
  final String pair;
  final String action; // 'buy' | 'sell'
  final bool isTestnet;
  final double entryPrice;
  final double? exitPrice;
  final double quantity;
  final double usdtValue;
  final double? realizedPnl;
  final double? realizedPnlPct;
  final String status; // 'open' | 'closed' | 'cancelled'
  final String? closeReason;
  final String? entryOrderId;
  final String? exitOrderId;
  final String claudeAction;
  final double claudeConfidence;
  final String claudeReason;
  final double? rsi14;
  final double? macdValue;
  final double? macdSignal;
  final double? macdHistogram;
  final double? bbUpper;
  final double? bbMiddle;
  final double? bbLower;
  final double? ema9;
  final double? ema21;
  final DateTime openedAt;
  final DateTime? closedAt;
  final DateTime createdAt;

  const TradeModel({
    required this.id,
    required this.userId,
    required this.pair,
    required this.action,
    required this.isTestnet,
    required this.entryPrice,
    this.exitPrice,
    required this.quantity,
    required this.usdtValue,
    this.realizedPnl,
    this.realizedPnlPct,
    required this.status,
    this.closeReason,
    this.entryOrderId,
    this.exitOrderId,
    required this.claudeAction,
    required this.claudeConfidence,
    required this.claudeReason,
    this.rsi14,
    this.macdValue,
    this.macdSignal,
    this.macdHistogram,
    this.bbUpper,
    this.bbMiddle,
    this.bbLower,
    this.ema9,
    this.ema21,
    required this.openedAt,
    this.closedAt,
    required this.createdAt,
  });

  bool get isOpen   => status == 'open';
  bool get isClosed => status == 'closed';
  bool get isBuy    => action == 'buy';
  bool get isProfit => (realizedPnl ?? 0) > 0;

  factory TradeModel.fromJson(Map<String, dynamic> json) {
    return TradeModel(
      id:               json['id'] as String,
      userId:           json['user_id'] as String,
      pair:             json['pair'] as String,
      action:           json['action'] as String,
      isTestnet:        json['is_testnet'] as bool,
      entryPrice:       (json['entry_price'] as num).toDouble(),
      exitPrice:        json['exit_price'] != null ? (json['exit_price'] as num).toDouble() : null,
      quantity:         (json['quantity'] as num).toDouble(),
      usdtValue:        (json['usdt_value'] as num).toDouble(),
      realizedPnl:      json['realized_pnl'] != null ? (json['realized_pnl'] as num).toDouble() : null,
      realizedPnlPct:   json['realized_pnl_pct'] != null ? (json['realized_pnl_pct'] as num).toDouble() : null,
      status:           json['status'] as String,
      closeReason:      json['close_reason'] as String?,
      entryOrderId:     json['entry_order_id'] as String?,
      exitOrderId:      json['exit_order_id'] as String?,
      claudeAction:     json['claude_action'] as String,
      claudeConfidence: (json['claude_confidence'] as num).toDouble(),
      claudeReason:     json['claude_reason'] as String,
      rsi14:            json['rsi_14'] != null ? (json['rsi_14'] as num).toDouble() : null,
      macdValue:        json['macd_value'] != null ? (json['macd_value'] as num).toDouble() : null,
      macdSignal:       json['macd_signal'] != null ? (json['macd_signal'] as num).toDouble() : null,
      macdHistogram:    json['macd_histogram'] != null ? (json['macd_histogram'] as num).toDouble() : null,
      bbUpper:          json['bb_upper'] != null ? (json['bb_upper'] as num).toDouble() : null,
      bbMiddle:         json['bb_middle'] != null ? (json['bb_middle'] as num).toDouble() : null,
      bbLower:          json['bb_lower'] != null ? (json['bb_lower'] as num).toDouble() : null,
      ema9:             json['ema_9'] != null ? (json['ema_9'] as num).toDouble() : null,
      ema21:            json['ema_21'] != null ? (json['ema_21'] as num).toDouble() : null,
      openedAt:         DateTime.parse(json['opened_at'] as String),
      closedAt:         json['closed_at'] != null ? DateTime.parse(json['closed_at'] as String) : null,
      createdAt:        DateTime.parse(json['created_at'] as String),
    );
  }
}
