// lib/core/services/binance_service.dart
// KriptoPilot — Binance API service
// HMAC-SHA256 signing, testnet/mainnet switch, secure key storage

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// ─── Secure Storage Keys ──────────────────────────────────────────────────────

const _kBinanceApiKey    = 'binance_api_key';
const _kBinanceApiSecret = 'binance_api_secret';

// ─── Provider ─────────────────────────────────────────────────────────────────

final binanceServiceProvider = Provider<BinanceService>((ref) {
  return BinanceService();
});

// ─── Service ──────────────────────────────────────────────────────────────────

class BinanceService {
  BinanceService();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Key Management ────────────────────────────────────────────────────────

  Future<void> saveCredentials({
    required String apiKey,
    required String apiSecret,
  }) async {
    await _storage.write(key: _kBinanceApiKey,    value: apiKey);
    await _storage.write(key: _kBinanceApiSecret, value: apiSecret);
  }

  Future<({String apiKey, String apiSecret})?> loadCredentials() async {
    final apiKey    = await _storage.read(key: _kBinanceApiKey);
    final apiSecret = await _storage.read(key: _kBinanceApiSecret);
    if (apiKey == null || apiSecret == null) return null;
    return (apiKey: apiKey, apiSecret: apiSecret);
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _kBinanceApiKey);
    await _storage.delete(key: _kBinanceApiSecret);
  }

  Future<bool> hasCredentials() async {
    final creds = await loadCredentials();
    return creds != null;
  }

  // ── HMAC-SHA256 Signing ───────────────────────────────────────────────────

  String _sign(String queryString, String secret) {
    final key     = utf8.encode(secret);
    final message = utf8.encode(queryString);
    final hmac    = Hmac(sha256, key);
    final digest  = hmac.convert(message);
    return digest.toString();
  }

  // ── API Requests ──────────────────────────────────────────────────────────

  String _baseUrl(bool useTestnet) =>
      useTestnet
          ? 'https://testnet.binance.vision/api/v3'
          : 'https://api.binance.com/api/v3';

  // Get account balance
  Future<BinanceBalance> getBalance({required bool useTestnet}) async {
    final creds = await loadCredentials();
    if (creds == null) throw const BinanceException('No API credentials found');

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final queryString = 'timestamp=$timestamp';
    final signature = _sign(queryString, creds.apiSecret);

    final uri = Uri.parse(
      '${_baseUrl(useTestnet)}/account?$queryString&signature=$signature',
    );

    late http.Response response;
    try {
      response = await http.get(uri, headers: {
        'X-MBX-APIKEY': creds.apiKey,
      }).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const BinanceException('Request timed out — check your connection');
    }

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw BinanceException(error['msg'] as String? ?? 'Unknown Binance error');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final balances = (data['balances'] as List)
        .map((b) => b as Map<String, dynamic>)
        .toList();

    final usdt = balances.firstWhere(
      (b) => b['asset'] == 'USDT',
      orElse: () => {'free': '0', 'locked': '0'},
    );

    return BinanceBalance(
      free:   double.parse(usdt['free'] as String),
      locked: double.parse(usdt['locked'] as String),
    );
  }

  // Get current price for a symbol
  Future<double> getCurrentPrice(String symbol, {required bool useTestnet}) async {
    final binanceSymbol = symbol.replaceAll('/', '');
    final uri = Uri.parse(
      '${_baseUrl(useTestnet)}/ticker/price?symbol=$binanceSymbol',
    );

    late http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const BinanceException('Request timed out — check your connection');
    }
    if (response.statusCode != 200) {
      throw const BinanceException('Failed to fetch price');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return double.parse(data['price'] as String);
  }

  // Place market order
  Future<String> placeMarketOrder({
    required String symbol,
    required String side, // 'BUY' | 'SELL'
    required double quoteOrderQty, // USDT amount
    required bool useTestnet,
  }) async {
    final creds = await loadCredentials();
    if (creds == null) throw const BinanceException('No API credentials found');

    final binanceSymbol = symbol.replaceAll('/', '');
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final queryString = 'symbol=$binanceSymbol&side=$side&type=MARKET'
        '&quoteOrderQty=${quoteOrderQty.toStringAsFixed(2)}&timestamp=$timestamp';
    final signature = _sign(queryString, creds.apiSecret);

    final uri = Uri.parse('${_baseUrl(useTestnet)}/order');
    late http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {
          'X-MBX-APIKEY': creds.apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: '$queryString&signature=$signature',
      ).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const BinanceException('Request timed out — check your connection');
    }

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw BinanceException(error['msg'] as String? ?? 'Order placement failed');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['orderId'].toString();
  }
}

// ─── Data Classes ─────────────────────────────────────────────────────────────

class BinanceBalance {
  final double free;
  final double locked;
  double get total => free + locked;

  const BinanceBalance({required this.free, required this.locked});
}

class BinanceException implements Exception {
  final String message;
  const BinanceException(this.message);
  @override
  String toString() => 'BinanceException: $message';
}
