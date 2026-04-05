// lib/shared/models/bot_config_model.dart
// KriptoPilot — Bot configuration model

class BotConfigModel {
  final String id;
  final String userId;
  final bool isRunning;
  final bool useTestnet;
  final List<String> tradingPairs;
  final double maxTradePct;
  final double stopLossPct;
  final double takeProfitPct;
  final double minConfidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BotConfigModel({
    required this.id,
    required this.userId,
    required this.isRunning,
    required this.useTestnet,
    required this.tradingPairs,
    required this.maxTradePct,
    required this.stopLossPct,
    required this.takeProfitPct,
    required this.minConfidence,
    required this.createdAt,
    required this.updatedAt,
  });

  BotConfigModel copyWith({
    bool? isRunning,
    bool? useTestnet,
    List<String>? tradingPairs,
    double? maxTradePct,
    double? stopLossPct,
    double? takeProfitPct,
    double? minConfidence,
  }) {
    return BotConfigModel(
      id: id,
      userId: userId,
      isRunning:    isRunning    ?? this.isRunning,
      useTestnet:   useTestnet   ?? this.useTestnet,
      tradingPairs: tradingPairs ?? this.tradingPairs,
      maxTradePct:  maxTradePct  ?? this.maxTradePct,
      stopLossPct:  stopLossPct  ?? this.stopLossPct,
      takeProfitPct: takeProfitPct ?? this.takeProfitPct,
      minConfidence: minConfidence ?? this.minConfidence,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory BotConfigModel.fromJson(Map<String, dynamic> json) {
    return BotConfigModel(
      id:            json['id'] as String,
      userId:        json['user_id'] as String,
      isRunning:     json['is_running'] as bool,
      useTestnet:    json['use_testnet'] as bool,
      tradingPairs:  List<String>.from(json['trading_pairs'] as List),
      maxTradePct:   (json['max_trade_pct'] as num).toDouble(),
      stopLossPct:   (json['stop_loss_pct'] as num).toDouble(),
      takeProfitPct: (json['take_profit_pct'] as num).toDouble(),
      minConfidence: (json['min_confidence'] as num).toDouble(),
      createdAt:     DateTime.parse(json['created_at'] as String),
      updatedAt:     DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id':        userId,
    'is_running':     isRunning,
    'use_testnet':    useTestnet,
    'trading_pairs':  tradingPairs,
    'max_trade_pct':  maxTradePct,
    'stop_loss_pct':  stopLossPct,
    'take_profit_pct': takeProfitPct,
    'min_confidence': minConfidence,
  };

  /// Default config for a new user
  factory BotConfigModel.defaultConfig(String userId) {
    return BotConfigModel(
      id:            '',
      userId:        userId,
      isRunning:     false,
      useTestnet:    true, // Safe default: always start on testnet
      tradingPairs:  ['BTC/USDT'],
      maxTradePct:   5.0,
      stopLossPct:   3.0,
      takeProfitPct: 6.0,
      minConfidence: 0.75,
      createdAt:     DateTime.now(),
      updatedAt:     DateTime.now(),
    );
  }
}
