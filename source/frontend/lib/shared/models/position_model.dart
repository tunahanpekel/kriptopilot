// lib/shared/models/position_model.dart
// KriptoPilot — Open position data model

class PositionModel {
  final String id;
  final String userId;
  final String tradeId;
  final String pair;
  final String action;
  final bool isTestnet;
  final double entryPrice;
  final double quantity;
  final double usdtValue;
  final double stopLossPrice;
  final double takeProfitPrice;
  final double? currentPrice;
  final double? unrealizedPnl;
  final double? unrealizedPnlPct;
  final DateTime openedAt;
  final DateTime updatedAt;

  const PositionModel({
    required this.id,
    required this.userId,
    required this.tradeId,
    required this.pair,
    required this.action,
    required this.isTestnet,
    required this.entryPrice,
    required this.quantity,
    required this.usdtValue,
    required this.stopLossPrice,
    required this.takeProfitPrice,
    this.currentPrice,
    this.unrealizedPnl,
    this.unrealizedPnlPct,
    required this.openedAt,
    required this.updatedAt,
  });

  bool get isBuy => action == 'buy';
  bool get isProfit => (unrealizedPnl ?? 0) > 0;

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      id:               json['id'] as String,
      userId:           json['user_id'] as String,
      tradeId:          json['trade_id'] as String,
      pair:             json['pair'] as String,
      action:           json['action'] as String,
      isTestnet:        json['is_testnet'] as bool,
      entryPrice:       (json['entry_price'] as num).toDouble(),
      quantity:         (json['quantity'] as num).toDouble(),
      usdtValue:        (json['usdt_value'] as num).toDouble(),
      stopLossPrice:    (json['stop_loss_price'] as num).toDouble(),
      takeProfitPrice:  (json['take_profit_price'] as num).toDouble(),
      currentPrice:     json['current_price'] != null ? (json['current_price'] as num).toDouble() : null,
      unrealizedPnl:    json['unrealized_pnl'] != null ? (json['unrealized_pnl'] as num).toDouble() : null,
      unrealizedPnlPct: json['unrealized_pnl_pct'] != null ? (json['unrealized_pnl_pct'] as num).toDouble() : null,
      openedAt:         DateTime.parse(json['opened_at'] as String),
      updatedAt:        DateTime.parse(json['updated_at'] as String),
    );
  }
}
