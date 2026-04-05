// lib/features/settings/presentation/settings_screen.dart
// KriptoPilot — Settings screen
// API key/secret (flutter_secure_storage), risk params, language selector

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/binance_service.dart';
import '../../../shared/models/bot_config_model.dart';
import '../../dashboard/providers/dashboard_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyCtrl    = TextEditingController();
  final _apiSecretCtrl = TextEditingController();
  bool _apiKeyVisible    = false;
  bool _apiSecretVisible = false;
  bool _hasChanges = false;
  bool _isSaving = false;

  // Local copy of risk params for editing
  double _maxTradePct = 5.0;
  double _stopLossPct = 3.0;
  double _takeProfitPct = 6.0;
  double _minConfidence = 0.75;
  bool _useTestnet = true;
  String _tradingPair = 'BTC/USDT';

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    final binance = ref.read(binanceServiceProvider);
    final creds = await binance.loadCredentials();
    if (creds != null) {
      _apiKeyCtrl.text    = creds.apiKey;
      _apiSecretCtrl.text = creds.apiSecret;
    }
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _apiSecretCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final botConfigAsync = ref.watch(botConfigProvider);

    return botConfigAsync.when(
      data: (config) {
        if (config != null && !_hasChanges) {
          // Initialize from config (only once)
          _maxTradePct  = config.maxTradePct;
          _stopLossPct  = config.stopLossPct;
          _takeProfitPct = config.takeProfitPct;
          _minConfidence = config.minConfidence;
          _useTestnet   = config.useTestnet;
          _tradingPair  = config.tradingPairs.first;
        }

        return Scaffold(
          appBar: AppBar(title: Text(s.settingsTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── API Configuration ─────────────────────────────────────
              _SectionHeader(title: s.settingsSectionApi),
              const SizedBox(height: 8),

              // API Key
              TextField(
                controller: _apiKeyCtrl,
                obscureText: !_apiKeyVisible,
                onChanged: (_) => setState(() => _hasChanges = true),
                decoration: InputDecoration(
                  labelText: s.binanceApiKey,
                  suffixIcon: IconButton(
                    icon: Icon(_apiKeyVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _apiKeyVisible = !_apiKeyVisible),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // API Secret
              TextField(
                controller: _apiSecretCtrl,
                obscureText: !_apiSecretVisible,
                onChanged: (_) => setState(() => _hasChanges = true),
                decoration: InputDecoration(
                  labelText: s.binanceApiSecret,
                  suffixIcon: IconButton(
                    icon: Icon(_apiSecretVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _apiSecretVisible = !_apiSecretVisible),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(s.apiKeysSavedSecurely,
                  style: AppTheme.labelSmall.copyWith(color: AppTheme.colorGreen)),
              const SizedBox(height: 16),

              // Testnet toggle
              _SettingsTile(
                title: s.testnetToggle,
                subtitle: s.testnetDescription,
                trailing: Switch(
                  value: _useTestnet,
                  onChanged: (v) {
                    _confirmTestnetSwitch(context, s, v);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ── Trading Configuration ─────────────────────────────────
              _SectionHeader(title: s.settingsSectionTrading),
              const SizedBox(height: 8),

              // Trading pair dropdown
              _SettingsTile(
                title: s.tradingPair,
                trailing: DropdownButton<String>(
                  value: _tradingPair,
                  dropdownColor: AppTheme.bgCard,
                  underline: const SizedBox.shrink(),
                  items: ['BTC/USDT', 'ETH/USDT'].map((pair) {
                    return DropdownMenuItem(
                      value: pair,
                      child: Text(pair, style: AppTheme.titleMedium),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() { _tradingPair = v; _hasChanges = true; });
                  },
                ),
              ),

              _SettingsTile(
                title: s.analysisInterval,
                subtitle: s.analysisIntervalValue,
              ),
              const SizedBox(height: 24),

              // ── Risk Management ───────────────────────────────────────
              _SectionHeader(title: s.settingsSectionRisk),
              const SizedBox(height: 8),

              _SliderSetting(
                label: s.maxTradePercent,
                value: _maxTradePct,
                min: 1, max: 10, divisions: 18,
                format: (v) => '${v.toStringAsFixed(1)}%',
                hint: s.maxTradePercentHint,
                onChanged: (v) => setState(() { _maxTradePct = v; _hasChanges = true; }),
              ),
              const SizedBox(height: 16),

              _SliderSetting(
                label: s.stopLossPercent,
                value: _stopLossPct,
                min: 0.5, max: 5, divisions: 19,
                format: (v) => '${v.toStringAsFixed(1)}%',
                onChanged: (v) => setState(() { _stopLossPct = v; _hasChanges = true; }),
              ),
              const SizedBox(height: 16),

              _SliderSetting(
                label: s.takeProfitPercent,
                value: _takeProfitPct,
                min: 1, max: 15, divisions: 28,
                format: (v) => '${v.toStringAsFixed(1)}%',
                onChanged: (v) => setState(() { _takeProfitPct = v; _hasChanges = true; }),
              ),
              const SizedBox(height: 16),

              _SliderSetting(
                label: s.minConfidenceScore,
                value: _minConfidence,
                min: 0.50, max: 0.95, divisions: 18,
                format: (v) => '${(v * 100).toStringAsFixed(0)}%',
                hint: s.minConfidenceHint,
                onChanged: (v) => setState(() { _minConfidence = v; _hasChanges = true; }),
              ),
              const SizedBox(height: 24),

              // ── App Settings ──────────────────────────────────────────
              _SectionHeader(title: s.settingsSectionApp),
              const SizedBox(height: 8),

              _SettingsTile(
                title: s.settingsLanguage,
                trailing: const _LanguageSelector(),
              ),
              const SizedBox(height: 16),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.colorYellow.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.colorYellow.withOpacity(0.3)),
                ),
                child: Text(s.disclaimer,
                    style: AppTheme.labelSmall.copyWith(color: AppTheme.colorYellow)),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasChanges && !_isSaving
                      ? () => _saveSettings(context, s, config)
                      : null,
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(s.saveSettings),
                ),
              ),
              const SizedBox(height: 16),

              // Sign Out
              OutlinedButton(
                onPressed: () => Supabase.instance.client.auth.signOut(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.colorRed,
                  side: const BorderSide(color: AppTheme.colorRed),
                ),
                child: Text(s.settingsSignOut),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(S.of(context).settingsTitle)),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.colorGreen)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(S.of(context).settingsTitle)),
        body: Center(child: Text(S.of(context).commonError)),
      ),
    );
  }

  void _confirmTestnetSwitch(BuildContext context, S s, bool newValue) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.testnetToggle),
        content: Text(s.testnetDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() { _useTestnet = newValue; _hasChanges = true; });
            },
            child: Text(s.commonConfirm),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings(BuildContext context, S s, BotConfigModel? config) async {
    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      // Save API keys securely
      if (_apiKeyCtrl.text.isNotEmpty && _apiSecretCtrl.text.isNotEmpty) {
        await ref.read(binanceServiceProvider).saveCredentials(
          apiKey:    _apiKeyCtrl.text.trim(),
          apiSecret: _apiSecretCtrl.text.trim(),
        );
      }

      // Update bot config in Supabase
      if (config != null) {
        final updated = config.copyWith(
          useTestnet:   _useTestnet,
          tradingPairs: [_tradingPair],
          maxTradePct:  _maxTradePct,
          stopLossPct:  _stopLossPct,
          takeProfitPct: _takeProfitPct,
          minConfidence: _minConfidence,
        );
        await ref.read(botConfigProvider.notifier).updateConfig(updated);
      }

      setState(() { _hasChanges = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.settingsSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.commonError),
            backgroundColor: AppTheme.colorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(title,
          style: AppTheme.labelMedium.copyWith(color: AppTheme.colorGreen, letterSpacing: 0.8)),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsTile({required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bgBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTheme.labelSmall),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Slider Setting ───────────────────────────────────────────────────────────

class _SliderSetting extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final String? hint;
  final void Function(double) onChanged;

  const _SliderSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTheme.titleMedium),
            Text(format(value),
                style: AppTheme.labelLarge.copyWith(color: AppTheme.colorGreen)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.colorGreen,
          inactiveColor: AppTheme.bgBorder,
          onChanged: onChanged,
        ),
        if (hint != null)
          Text(hint!, style: AppTheme.labelSmall),
      ],
    );
  }
}

// ─── Language Selector ────────────────────────────────────────────────────────

class _LanguageSelector extends ConsumerWidget {
  const _LanguageSelector();

  static const _languages = [
    ('en', 'English'),
    ('tr', 'Türkçe'),
    ('es', 'Español'),
    ('de', 'Deutsch'),
    ('fr', 'Français'),
    ('pt', 'Português'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final current = _languages.firstWhere(
      (l) => l.$1 == locale.languageCode,
      orElse: () => ('en', 'English'),
    );

    return TextButton(
      onPressed: () => _showPicker(context, ref, locale.languageCode),
      child: Text(current.$2, style: AppTheme.titleMedium.copyWith(color: AppTheme.colorGreen)),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: _languages.map((lang) {
          final isSelected = lang.$1 == current;
          return ListTile(
            title: Text(lang.$2, style: AppTheme.titleMedium),
            trailing: isSelected
                ? const Icon(Icons.check, color: AppTheme.colorGreen)
                : null,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(lang.$1);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
