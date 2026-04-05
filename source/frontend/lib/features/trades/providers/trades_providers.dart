// lib/features/trades/providers/trades_providers.dart
// KriptoPilot — Trades state providers

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client.dart';
import '../../../shared/models/trade_model.dart';

final tradesProvider = FutureProvider.family<List<TradeModel>, String>((ref, filter) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  var query = supabase
      .from('trades')
      .select()
      .eq('user_id', userId)
      .isFilter('deleted_at', null);

  switch (filter) {
    case 'buy':
      query = query.eq('action', 'buy');
    case 'sell':
      query = query.eq('action', 'sell');
    case 'profit':
      query = query.gt('realized_pnl', 0);
    case 'loss':
      query = query.lt('realized_pnl', 0);
  }

  final rows = await query.order('opened_at', ascending: false).limit(50);
  return rows.map(TradeModel.fromJson).toList();
});
