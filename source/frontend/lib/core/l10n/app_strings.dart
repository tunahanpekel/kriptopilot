// lib/core/l10n/app_strings.dart
// KriptoPilot — Localization
// Supported: en, tr, es, de, fr, pt
// ZERO hardcoded strings in UI — all strings go through S.of(context)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Locale Provider ──────────────────────────────────────────────────────────

const _kLangKey = 'app_language';
const _supportedLangs = ['en', 'tr', 'es', 'de', 'fr', 'pt'];

String _deviceLang() {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return _supportedLangs.contains(code) ? code : 'en';
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _load();
    return Locale(_deviceLang());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLangKey);
    if (saved != null) state = Locale(saved);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, languageCode);
  }
}

// ─── String lookup ────────────────────────────────────────────────────────────

class S {
  const S._(this._locale);
  final Locale _locale;
  String get _lang => _locale.languageCode;
  bool get _tr => _lang == 'tr';
  bool get _es => _lang == 'es';
  bool get _de => _lang == 'de';
  bool get _fr => _lang == 'fr';
  bool get _pt => _lang == 'pt';

  static S of(BuildContext context) => S._(Localizations.localeOf(context));

  // ── Common ────────────────────────────────────────────────────────────────
  String get commonOk          => _tr ? 'Tamam'       : _es ? 'Aceptar'   : _de ? 'OK'          : _fr ? 'OK'          : _pt ? 'OK'           : 'OK';
  String get commonCancel      => _tr ? 'İptal'       : _es ? 'Cancelar'  : _de ? 'Abbrechen'   : _fr ? 'Annuler'     : _pt ? 'Cancelar'     : 'Cancel';
  String get commonSave        => _tr ? 'Kaydet'      : _es ? 'Guardar'   : _de ? 'Speichern'   : _fr ? 'Enregistrer' : _pt ? 'Salvar'       : 'Save';
  String get commonContinue    => _tr ? 'Devam Et'    : _es ? 'Continuar' : _de ? 'Weiter'      : _fr ? 'Continuer'   : _pt ? 'Continuar'   : 'Continue';
  String get commonBack        => _tr ? 'Geri'        : _es ? 'Atrás'     : _de ? 'Zurück'      : _fr ? 'Retour'      : _pt ? 'Voltar'       : 'Back';
  String get commonLoading     => _tr ? 'Yükleniyor'  : _es ? 'Cargando'  : _de ? 'Laden...'    : _fr ? 'Chargement'  : _pt ? 'Carregando'  : 'Loading...';
  String get commonError       => _tr ? 'Hata'        : _es ? 'Error'     : _de ? 'Fehler'      : _fr ? 'Erreur'      : _pt ? 'Erro'         : 'Error';
  String get commonRetry       => _tr ? 'Tekrar Dene' : _es ? 'Reintentar': _de ? 'Wiederholen' : _fr ? 'Réessayer'   : _pt ? 'Tentar novamente': 'Try Again';
  String get commonConfirm     => _tr ? 'Onayla'      : _es ? 'Confirmar' : _de ? 'Bestätigen'  : _fr ? 'Confirmer'   : _pt ? 'Confirmar'   : 'Confirm';
  String get commonPageNotFound=> _tr ? 'Sayfa Bulunamadı': _es ? 'Página no encontrada': _de ? 'Seite nicht gefunden': _fr ? 'Page introuvable': _pt ? 'Página não encontrada': 'Page Not Found';
  String get commonGoHome      => _tr ? 'Ana Sayfaya Dön': _es ? 'Ir al inicio': _de ? 'Zur Startseite': _fr ? 'Aller à l\'accueil': _pt ? 'Ir para o início': 'Go Home';

  // ── Navigation / Tab Labels ───────────────────────────────────────────────
  String get tabDashboard  => _tr ? 'Pano'       : _es ? 'Panel'      : _de ? 'Dashboard'  : _fr ? 'Tableau'     : _pt ? 'Painel'       : 'Dashboard';
  String get tabTrades     => _tr ? 'İşlemler'   : _es ? 'Operaciones': _de ? 'Trades'     : _fr ? 'Trades'      : _pt ? 'Operações'    : 'Trades';
  String get tabAnalytics  => _tr ? 'Analitik'   : _es ? 'Analíticas' : _de ? 'Analytik'   : _fr ? 'Analyses'    : _pt ? 'Analytics'    : 'Analytics';
  String get tabSettings   => _tr ? 'Ayarlar'    : _es ? 'Ajustes'    : _de ? 'Einstellungen': _fr ? 'Paramètres': _pt ? 'Configurações': 'Settings';

  // ── Onboarding ────────────────────────────────────────────────────────────
  String get onboarding1Title    => _tr ? 'Yapay zekan uyurken trade yapar'   : _es ? 'Tu IA opera mientras duermes'      : _de ? 'Deine KI handelt, während du schläfst' : _fr ? 'Votre IA trade pendant votre sommeil' : _pt ? 'Sua IA opera enquanto você dorme'        : 'Your AI trades while you sleep';
  String get onboarding1Subtitle => _tr ? 'Claude her 15 dakikada RSI, MACD ve Bollinger Bands analiz eder.' : _es ? 'Claude analiza RSI, MACD y Bandas de Bollinger cada 15 minutos.' : _de ? 'Claude analysiert RSI, MACD und Bollinger Bands alle 15 Minuten.' : _fr ? 'Claude analyse RSI, MACD et Bandes de Bollinger toutes les 15 minutes.' : _pt ? 'Claude analisa RSI, MACD e Bandas de Bollinger a cada 15 minutos.' : 'Claude analyzes RSI, MACD, and Bollinger Bands every 15 minutes.';
  String get onboarding2Title    => _tr ? 'Her trade\'in neden olduğunu tam gör'   : _es ? 'Entiende cada operación al detalle'   : _de ? 'Verstehe jeden Trade bis ins Detail'       : _fr ? 'Comprenez chaque trade en détail'          : _pt ? 'Veja exatamente por que cada trade acontece'  : 'See exactly why every trade happens';
  String get onboarding2Subtitle => _tr ? 'Claude her alım/satım kararını sade dille açıklar. Kara kutu yok.' : _es ? 'Claude explica cada decisión de compra/venta en lenguaje claro. Sin cajas negras.' : _de ? 'Claude erklärt jede Kauf-/Verkaufsentscheidung in klarer Sprache. Keine Black Box.' : _fr ? 'Claude explique chaque décision d\'achat/vente en langage clair. Aucune boîte noire.' : _pt ? 'Claude explica cada decisão de compra/venda em linguagem simples. Sem caixa preta.' : 'Claude explains each buy/sell decision in plain language. No black boxes.';
  String get onboarding3Title    => _tr ? 'Testnet\'te başla. Risk sıfır.'          : _es ? 'Empieza en testnet. Sin riesgo.'          : _de ? 'Starte im Testnet. Kein Risiko.'             : _fr ? 'Démarrez sur testnet. Zéro risque.'            : _pt ? 'Comece no testnet. Risco zero.'                 : 'Start on testnet. Risk nothing.';
  String get onboarding3Subtitle => _tr ? 'Gerçek para trade etmeden önce Binance Testnet\'te pratik yap.' : _es ? 'Practica con Binance Testnet antes de operar con dinero real.' : _de ? 'Übe mit Binance Testnet, bevor du mit echtem Geld handelst.' : _fr ? 'Pratiquez avec Binance Testnet avant de trader avec de l\'argent réel.' : _pt ? 'Pratique com o Binance Testnet antes de operar com dinheiro real.' : 'Practice with Binance Testnet before trading real money. Switch when ready.';
  String get onboardingConnectApi => _tr ? 'Binance API Bağla'   : _es ? 'Conectar API de Binance'   : _de ? 'Binance-API verbinden'    : _fr ? 'Connecter l\'API Binance'   : _pt ? 'Conectar API da Binance'   : 'Connect Binance API';
  String get onboardingSkip       => _tr ? 'Geç'                 : _es ? 'Omitir'                    : _de ? 'Überspringen'             : _fr ? 'Passer'                     : _pt ? 'Pular'                     : 'Skip';
  String get onboardingGetStarted => _tr ? 'Başla'               : _es ? 'Comenzar'                  : _de ? 'Loslegen'                 : _fr ? 'Commencer'                  : _pt ? 'Começar'                   : 'Get Started';

  // ── Dashboard ────────────────────────────────────────────────────────────
  String get dashboardTitle       => _tr ? 'KriptoPilot'          : _es ? 'KriptoPilot'               : _de ? 'KriptoPilot'              : _fr ? 'KriptoPilot'                : _pt ? 'KriptoPilot'               : 'KriptoPilot';
  String get totalBalance         => _tr ? 'Toplam Bakiye'        : _es ? 'Balance total'             : _de ? 'Gesamtguthaben'           : _fr ? 'Solde total'                : _pt ? 'Saldo total'               : 'Total Balance';
  String get dailyPnl             => _tr ? 'Günlük K/Z'           : _es ? 'P&G diario'               : _de ? 'Tages-GuV'                : _fr ? 'P&L journalier'             : _pt ? 'L&P diário'               : 'Daily P&L';
  String get openPositions        => _tr ? 'Açık Pozisyonlar'     : _es ? 'Posiciones abiertas'       : _de ? 'Offene Positionen'        : _fr ? 'Positions ouvertes'         : _pt ? 'Posições abertas'          : 'Open Positions';
  String get recentTrades         => _tr ? 'Son İşlemler'         : _es ? 'Operaciones recientes'     : _de ? 'Letzte Trades'            : _fr ? 'Trades récents'             : _pt ? 'Operações recentes'        : 'Recent Trades';
  String get seeAll               => _tr ? 'Tümünü Gör'           : _es ? 'Ver todo'                  : _de ? 'Alle anzeigen'            : _fr ? 'Tout voir'                  : _pt ? 'Ver tudo'                  : 'See all';
  String get botRunning           => _tr ? 'Bot çalışıyor'        : _es ? 'Bot en marcha'             : _de ? 'Bot läuft'                : _fr ? 'Bot en cours'               : _pt ? 'Bot em execução'           : 'Bot is running';
  String get botStopped           => _tr ? 'Bot durduruldu'       : _es ? 'Bot detenido'              : _de ? 'Bot gestoppt'             : _fr ? 'Bot arrêté'                 : _pt ? 'Bot parado'                : 'Bot stopped';
  String get botNextCycle         => _tr ? 'Sonraki analiz: '     : _es ? 'Próximo análisis: '        : _de ? 'Nächste Analyse: '        : _fr ? 'Prochaine analyse: '         : _pt ? 'Próxima análise: '         : 'Next analysis in ';
  String get noOpenPositions      => _tr ? 'Açık pozisyon yok'    : _es ? 'Sin posiciones abiertas'   : _de ? 'Keine offenen Positionen' : _fr ? 'Aucune position ouverte'     : _pt ? 'Sem posições abertas'      : 'No open positions';
  String get testnetBadge         => _tr ? 'TESTNET'              : _es ? 'TESTNET'                   : _de ? 'TESTNET'                  : _fr ? 'TESTNET'                     : _pt ? 'TESTNET'                   : 'TESTNET';
  String get botStartConfirmTitle => _tr ? 'Botu başlat?'         : _es ? '¿Iniciar bot?'             : _de ? 'Bot starten?'             : _fr ? 'Démarrer le bot?'            : _pt ? 'Iniciar bot?'              : 'Start bot?';
  String get botStartConfirmBody  => _tr ? 'Bot her 15 dakikada analiz yapacak ve uygun sinyallerde işlem açacak.' : _es ? 'El bot analizará cada 15 minutos y abrirá operaciones cuando sea adecuado.' : _de ? 'Der Bot analysiert alle 15 Minuten und öffnet Trades bei passenden Signalen.' : _fr ? 'Le bot analysera toutes les 15 minutes et ouvrira des trades sur les signaux appropriés.' : _pt ? 'O bot analisará a cada 15 minutos e abrirá operações em sinais adequados.' : 'The bot will analyze every 15 minutes and open trades on suitable signals.';
  String get botStopConfirmTitle  => _tr ? 'Botu durdur?'         : _es ? '¿Detener bot?'             : _de ? 'Bot stoppen?'             : _fr ? 'Arrêter le bot?'             : _pt ? 'Parar bot?'               : 'Stop bot?';
  String get botStopConfirmBody   => _tr ? 'Mevcut açık pozisyonlar izlenmeye devam edecek.' : _es ? 'Las posiciones abiertas actuales seguirán siendo monitoreadas.' : _de ? 'Aktuelle offene Positionen werden weiterhin überwacht.' : _fr ? 'Les positions ouvertes actuelles continueront d\'être surveillées.' : _pt ? 'As posições abertas atuais continuarão sendo monitoradas.' : 'Current open positions will still be monitored.';
  String get errorLoadingBalance  => _tr ? 'Bakiye yüklenemedi'   : _es ? 'No se pudo cargar el saldo': _de ? 'Guthaben konnte nicht geladen werden': _fr ? 'Impossible de charger le solde': _pt ? 'Não foi possível carregar o saldo': 'Could not load balance';
  String dashboardEntryPrice(String price) => _tr ? 'Giriş: \$$price' : _es ? 'Entrada: \$$price' : _de ? 'Einstieg: \$$price' : _fr ? 'Entrée: \$$price' : _pt ? 'Entrada: \$$price' : 'Entry: \$$price';

  // ── Trades ────────────────────────────────────────────────────────────────
  String get tradesTitle       => _tr ? 'İşlemler'      : _es ? 'Operaciones'       : _de ? 'Trades'         : _fr ? 'Trades'         : _pt ? 'Operações'       : 'Trades';
  String get tradesBuy         => _tr ? 'ALIŞ'          : _es ? 'COMPRA'            : _de ? 'KAUF'           : _fr ? 'ACHAT'          : _pt ? 'COMPRA'          : 'BUY';
  String get tradesSell        => _tr ? 'SATIŞ'         : _es ? 'VENTA'             : _de ? 'VERKAUF'        : _fr ? 'VENTE'          : _pt ? 'VENDA'           : 'SELL';
  String get tradesHold        => _tr ? 'BEKLE'         : _es ? 'MANTENER'          : _de ? 'HALTEN'         : _fr ? 'CONSERVER'      : _pt ? 'MANTER'          : 'HOLD';
  String get tradesOpen        => _tr ? 'AÇIK'          : _es ? 'ABIERTA'           : _de ? 'OFFEN'          : _fr ? 'OUVERTE'        : _pt ? 'ABERTA'          : 'OPEN';
  String get tradesClosed      => _tr ? 'KAPALI'        : _es ? 'CERRADA'           : _de ? 'GESCHLOSSEN'    : _fr ? 'FERMÉE'         : _pt ? 'FECHADA'         : 'CLOSED';
  String get tradesFilterAll   => _tr ? 'Tümü'          : _es ? 'Todas'             : _de ? 'Alle'           : _fr ? 'Toutes'         : _pt ? 'Todas'           : 'All';
  String get tradesFilterProfit=> _tr ? 'Kârlı'         : _es ? 'Con ganancia'      : _de ? 'Gewinn'         : _fr ? 'Profit'         : _pt ? 'Lucro'           : 'Profit';
  String get tradesFilterLoss  => _tr ? 'Zararlı'       : _es ? 'Con pérdida'       : _de ? 'Verlust'        : _fr ? 'Perte'          : _pt ? 'Perda'           : 'Loss';
  String get noTradesYet       => _tr ? 'Henüz işlem yok' : _es ? 'Aún sin operaciones' : _de ? 'Noch keine Trades' : _fr ? 'Aucune transaction encore' : _pt ? 'Sem operações ainda' : 'No trades yet';
  String get noTradesSubtitle  => _tr ? 'Bot ilk emrini gerçekleştirdikten sonra işlem geçmişin burada görünecek.' : _es ? 'Tu historial de operaciones aparecerá aquí después de que el bot ejecute su primera orden.' : _de ? 'Dein Handelsverlauf erscheint hier, nachdem der Bot seinen ersten Auftrag ausgeführt hat.' : _fr ? 'Votre historique de transactions apparaîtra ici après que le bot aura exécuté son premier ordre.' : _pt ? 'Seu histórico de operações aparecerá aqui após o bot executar sua primeira ordem.' : 'Your trade history will appear here after the bot executes its first order.';
  String get tradeEntryPrice   => _tr ? 'Giriş Fiyatı'  : _es ? 'Precio de entrada' : _de ? 'Einstiegspreis' : _fr ? 'Prix d\'entrée'  : _pt ? 'Preço de entrada': 'Entry Price';
  String get tradeExitPrice    => _tr ? 'Çıkış Fiyatı'  : _es ? 'Precio de salida'  : _de ? 'Ausstiegspreis' : _fr ? 'Prix de sortie'  : _pt ? 'Preço de saída'  : 'Exit Price';
  String get tradeStopLoss     => _tr ? 'Stop Loss'      : _es ? 'Stop Loss'         : _de ? 'Stop-Loss'      : _fr ? 'Stop Loss'       : _pt ? 'Stop Loss'       : 'Stop Loss';
  String get tradeTakeProfit   => _tr ? 'Take Profit'    : _es ? 'Take Profit'       : _de ? 'Take-Profit'    : _fr ? 'Take Profit'     : _pt ? 'Take Profit'     : 'Take Profit';
  String get tradeQuantity     => _tr ? 'Miktar'         : _es ? 'Cantidad'          : _de ? 'Menge'          : _fr ? 'Quantité'        : _pt ? 'Quantidade'      : 'Quantity';
  String get tradeId           => _tr ? 'İşlem ID'       : _es ? 'ID operación'      : _de ? 'Trade-ID'       : _fr ? 'ID trade'        : _pt ? 'ID operação'     : 'Trade ID';
  String get claudeAnalysis    => _tr ? 'Claude Analizi' : _es ? 'Análisis de Claude': _de ? 'Claude-Analyse'  : _fr ? 'Analyse Claude'  : _pt ? 'Análise Claude'  : 'Claude Analysis';
  String get claudeConfidence  => _tr ? 'Güven Skoru'    : _es ? 'Puntuación de confianza': _de ? 'Konfidenz' : _fr ? 'Score de confiance': _pt ? 'Pontuação de confiança': 'Confidence';
  String get claudeReason      => _tr ? 'Gerekçe'        : _es ? 'Razón'             : _de ? 'Begründung'     : _fr ? 'Raison'          : _pt ? 'Razão'           : 'Reason';
  String get tradeIndicators   => _tr ? 'Göstergeler'    : _es ? 'Indicadores'       : _de ? 'Indikatoren'    : _fr ? 'Indicateurs'     : _pt ? 'Indicadores'     : 'Indicators';
  String get tradesTestnet     => _tr ? 'TESTNET'        : _es ? 'TESTNET'           : _de ? 'TESTNET'        : _fr ? 'TESTNET'         : _pt ? 'TESTNET'         : 'TESTNET';
  String get tradesPnl         => _tr ? 'K/Z'            : _es ? 'P&G'               : _de ? 'GuV'            : _fr ? 'P&L'             : _pt ? 'L&P'             : 'P&L';

  // ── Analytics ─────────────────────────────────────────────────────────────
  String get analyticsTitle        => _tr ? 'Analitik'         : _es ? 'Analíticas'           : _de ? 'Analytik'               : _fr ? 'Analyses'              : _pt ? 'Analytics'             : 'Analytics';
  String get winRate               => _tr ? 'Kazanma Oranı'    : _es ? 'Tasa de aciertos'      : _de ? 'Gewinnrate'             : _fr ? 'Taux de réussite'      : _pt ? 'Taxa de acerto'        : 'Win Rate';
  String get totalPnl              => _tr ? 'Toplam K/Z'       : _es ? 'P&G total'             : _de ? 'Gesamt-GuV'             : _fr ? 'P&L total'             : _pt ? 'L&P total'             : 'Total P&L';
  String get totalTrades           => _tr ? 'Toplam İşlem'     : _es ? 'Total operaciones'     : _de ? 'Gesamt-Trades'          : _fr ? 'Total trades'          : _pt ? 'Total operações'       : 'Total Trades';
  String get bestTrade             => _tr ? 'En İyi İşlem'     : _es ? 'Mejor operación'       : _de ? 'Bester Trade'           : _fr ? 'Meilleur trade'        : _pt ? 'Melhor operação'       : 'Best Trade';
  String get worstTrade            => _tr ? 'En Kötü İşlem'    : _es ? 'Peor operación'        : _de ? 'Schlechtester Trade'    : _fr ? 'Pire trade'            : _pt ? 'Pior operação'         : 'Worst Trade';
  String get equityCurve          => _tr ? 'Sermaye Eğrisi'    : _es ? 'Curva de equity'       : _de ? 'Equity-Kurve'           : _fr ? 'Courbe d\'équité'      : _pt ? 'Curva de equity'       : 'Equity Curve';
  String get wins                  => _tr ? 'Kazanç'           : _es ? 'Ganancias'             : _de ? 'Gewinne'                : _fr ? 'Gains'                 : _pt ? 'Ganhos'                : 'Wins';
  String get losses                => _tr ? 'Kayıp'            : _es ? 'Pérdidas'              : _de ? 'Verluste'               : _fr ? 'Pertes'                : _pt ? 'Perdas'                : 'Losses';
  String get timeRange7d           => _tr ? '7G'              : _es ? '7D'                    : _de ? '7T'                     : _fr ? '7J'                    : _pt ? '7D'                    : '7D';
  String get timeRange30d          => _tr ? '30G'             : _es ? '30D'                   : _de ? '30T'                    : _fr ? '30J'                   : _pt ? '30D'                   : '30D';
  String get timeRangeAll          => _tr ? 'Tümü'            : _es ? 'Todo'                  : _de ? 'Alle'                   : _fr ? 'Tout'                  : _pt ? 'Tudo'                  : 'All';
  String get analyticsNeedMoreData => _tr ? 'Analitik daha fazla veriye ihtiyaç duyuyor' : _es ? 'Analíticas necesitan más datos' : _de ? 'Analytics brauchen mehr Daten' : _fr ? 'Les analyses nécessitent plus de données' : _pt ? 'Analytics precisam de mais dados' : 'Analytics need more data';
  String get analyticsNeedMoreDataSubtitle => _tr ? 'Win rate ve equity curve görmek için en az 5 işlem tamamla.' : _es ? 'Completa al menos 5 operaciones para ver la tasa de aciertos y la curva de equity.' : _de ? 'Schließe mindestens 5 Trades ab, um Win-Rate und Equity-Kurve zu sehen.' : _fr ? 'Complétez au moins 5 trades pour voir le taux de réussite et la courbe d\'équité.' : _pt ? 'Complete pelo menos 5 operações para ver a taxa de acerto e a curva de equity.' : 'Complete at least 5 trades to see win rate and equity curve.';
  String get pairPerformance       => _tr ? 'Çift Performansı'  : _es ? 'Rendimiento por par'   : _de ? 'Paar-Performance'       : _fr ? 'Performance par paire' : _pt ? 'Desempenho por par'    : 'Pair Performance';

  // ── Settings ─────────────────────────────────────────────────────────────
  String get settingsTitle           => _tr ? 'Ayarlar'           : _es ? 'Ajustes'                : _de ? 'Einstellungen'           : _fr ? 'Paramètres'              : _pt ? 'Configurações'         : 'Settings';
  String get settingsSectionApi      => _tr ? 'API Yapılandırması': _es ? 'Configuración de API'    : _de ? 'API-Konfiguration'       : _fr ? 'Configuration API'       : _pt ? 'Configuração da API'   : 'API Configuration';
  String get settingsSectionTrading  => _tr ? 'İşlem Ayarları'   : _es ? 'Configuración de trading': _de ? 'Handelseinstellungen'    : _fr ? 'Paramètres de trading'   : _pt ? 'Configurações de trading': 'Trading Configuration';
  String get settingsSectionRisk     => _tr ? 'Risk Yönetimi'    : _es ? 'Gestión de riesgos'      : _de ? 'Risikomanagement'        : _fr ? 'Gestion des risques'     : _pt ? 'Gestão de risco'       : 'Risk Management';
  String get settingsSectionApp      => _tr ? 'Uygulama'         : _es ? 'Aplicación'              : _de ? 'App'                    : _fr ? 'Application'             : _pt ? 'Aplicativo'            : 'App';
  String get binanceApiKey           => _tr ? 'Binance API Anahtarı' : _es ? 'Clave API de Binance' : _de ? 'Binance-API-Schlüssel'  : _fr ? 'Clé API Binance'         : _pt ? 'Chave de API Binance'  : 'Binance API Key';
  String get binanceApiSecret        => _tr ? 'Binance API Secret'   : _es ? 'Secret API de Binance': _de ? 'Binance-API-Secret'     : _fr ? 'Secret API Binance'      : _pt ? 'Secret de API Binance' : 'Binance API Secret';
  String get testnetToggle           => _tr ? 'Testnet Modu'      : _es ? 'Modo testnet'           : _de ? 'Testnet-Modus'           : _fr ? 'Mode testnet'            : _pt ? 'Modo testnet'          : 'Testnet Mode';
  String get testnetDescription      => _tr ? 'Açık: Gerçek para riski yok. Testnet kullan.' : _es ? 'Activado: Sin riesgo de dinero real. Usa testnet.' : _de ? 'Ein: Kein echtes Geld-Risiko. Testnet verwenden.' : _fr ? 'Activé: Aucun risque d\'argent réel. Utiliser testnet.' : _pt ? 'Ativado: Sem risco de dinheiro real. Usar testnet.' : 'ON: No real money risk. Uses Binance Testnet.';
  String get tradingPair             => _tr ? 'İşlem Çifti'       : _es ? 'Par de trading'         : _de ? 'Handelspaar'             : _fr ? 'Paire de trading'        : _pt ? 'Par de negociação'     : 'Trading Pair';
  String get analysisInterval        => _tr ? 'Analiz Aralığı'    : _es ? 'Intervalo de análisis'   : _de ? 'Analyseintervall'        : _fr ? 'Intervalle d\'analyse'    : _pt ? 'Intervalo de análise'  : 'Analysis Interval';
  String get analysisIntervalValue   => _tr ? '15 dakika (sabit)'  : _es ? '15 minutos (fijo)'      : _de ? '15 Minuten (fest)'       : _fr ? '15 minutes (fixe)'       : _pt ? '15 minutos (fixo)'     : '15 minutes (fixed)';
  String get maxTradePercent         => _tr ? 'İşlem Başına Max %' : _es ? '% máx. por operación'  : _de ? 'Max % pro Trade'         : _fr ? '% max par trade'         : _pt ? '% máx por operação'    : 'Max % Per Trade';
  String get maxTradePercentHint     => _tr ? 'Bakiyenin %1–%10 arası' : _es ? '1%–10% del saldo' : _de ? '1%–10% des Guthabens'    : _fr ? '1%–10% du solde'         : _pt ? '1%–10% do saldo'       : '1%–10% of balance';
  String get stopLossPercent         => _tr ? 'Stop Loss %'        : _es ? '% Stop Loss'            : _de ? 'Stop-Loss %'             : _fr ? '% Stop Loss'             : _pt ? '% Stop Loss'           : 'Stop Loss %';
  String get takeProfitPercent       => _tr ? 'Take Profit %'      : _es ? '% Take Profit'          : _de ? 'Take-Profit %'           : _fr ? '% Take Profit'           : _pt ? '% Take Profit'         : 'Take Profit %';
  String get minConfidenceScore      => _tr ? 'Min Güven Skoru'    : _es ? 'Puntaje mín. confianza' : _de ? 'Min. Konfidenz-Score'    : _fr ? 'Score de confiance min.'  : _pt ? 'Pontuação mín. confiança': 'Min Confidence Score';
  String get minConfidenceHint       => _tr ? 'Claude bu skorun altında trade açmaz' : _es ? 'Claude no operará por debajo de este puntaje' : _de ? 'Claude handelt nicht unter diesem Score' : _fr ? 'Claude ne traderas pas en dessous de ce score' : _pt ? 'Claude não operará abaixo desta pontuação' : 'Claude will not trade below this score';
  String get saveSettings            => _tr ? 'Ayarları Kaydet'   : _es ? 'Guardar ajustes'         : _de ? 'Einstellungen speichern'  : _fr ? 'Enregistrer les paramètres': _pt ? 'Salvar configurações' : 'Save Settings';
  String get settingsSaved           => _tr ? 'Ayarlar kaydedildi' : _es ? 'Ajustes guardados'      : _de ? 'Einstellungen gespeichert': _fr ? 'Paramètres enregistrés'  : _pt ? 'Configurações salvas'  : 'Settings saved';
  String get settingsLanguage        => _tr ? 'Dil'               : _es ? 'Idioma'                  : _de ? 'Sprache'                 : _fr ? 'Langue'                  : _pt ? 'Idioma'                : 'Language';
  String get settingsSignOut         => _tr ? 'Çıkış Yap'         : _es ? 'Cerrar sesión'           : _de ? 'Abmelden'                : _fr ? 'Se déconnecter'          : _pt ? 'Sair'                  : 'Sign Out';
  String get apiKeysSavedSecurely    => _tr ? 'API anahtarları cihazında şifrelendi' : _es ? 'Claves API cifradas en tu dispositivo' : _de ? 'API-Schlüssel auf Gerät verschlüsselt' : _fr ? 'Clés API chiffrées sur votre appareil' : _pt ? 'Chaves de API criptografadas no dispositivo' : 'API keys encrypted on your device';

  // ── Errors ───────────────────────────────────────────────────────────────
  String get errorApiKeyInvalid      => _tr ? 'API anahtarı tanınmadı — Ayarlar\'da anahtar ve secret\'ını kontrol et.' : _es ? 'Clave API no reconocida — Verifica tu clave y secreto en Configuración.' : _de ? 'API-Schlüssel nicht erkannt — Überprüfe Schlüssel und Secret in den Einstellungen.' : _fr ? 'Clé API non reconnue — Vérifiez votre clé et secret dans les Paramètres.' : _pt ? 'Chave de API não reconhecida — Verifique sua chave e secret nas Configurações.' : 'API key not recognized — Double-check your key and secret in Settings.';
  String get errorInsufficientBalance=> _tr ? 'Yetersiz bakiye — Fon ekle veya trade % oranını düşür.' : _es ? 'Saldo insuficiente — Añade fondos o reduce tu % en Configuración.' : _de ? 'Nicht genug Guthaben — Guthaben auffüllen oder Trade-% reduzieren.' : _fr ? 'Solde insuffisant — Ajoutez des fonds ou réduisez votre % dans les Paramètres.' : _pt ? 'Saldo insuficiente — Adicione fundos ou reduza seu %.' : 'Not enough balance — Add funds or lower your trade % in Settings.';
  String get errorRateLimit          => _tr ? 'Binance rate limit aşıldı — Bot 60 saniye duraklatıldı.' : _es ? 'Límite de velocidad de Binance alcanzado — Bot pausado 60 segundos.' : _de ? 'Binance-Ratenlimit erreicht — Bot für 60 Sekunden pausiert.' : _fr ? 'Limite de débit Binance atteinte — Bot mis en pause 60 secondes.' : _pt ? 'Limite de taxa da Binance atingido — Bot pausado 60 segundos.' : 'Binance rate limit reached — Bot paused for 60 seconds.';
  String get errorNoInternet         => _tr ? 'Binance\'e ulaşılamıyor — İnternet bağlantını kontrol et.' : _es ? 'No se puede conectar a Binance — Verifica tu conexión.' : _de ? 'Binance nicht erreichbar — Internetverbindung prüfen.' : _fr ? 'Impossible d\'atteindre Binance — Vérifiez votre connexion.' : _pt ? 'Não é possível alcançar a Binance — Verifique sua conexão.' : 'Can\'t reach Binance — Check your internet connection.';
  String get errorInvalidRiskPercent => _tr ? 'Risk % 1–10 arasında olmalı' : _es ? 'El % de riesgo debe ser 1–10' : _de ? 'Risiko-% muss 1–10 sein' : _fr ? 'Le % de risque doit être entre 1 et 10' : _pt ? '% de risco deve ser 1–10' : 'Risk % must be 1–10';

  // ── Auth ─────────────────────────────────────────────────────────────────
  String get authSignIn         => _tr ? 'Giriş Yap'   : _es ? 'Iniciar sesión' : _de ? 'Anmelden'   : _fr ? 'Se connecter'   : _pt ? 'Entrar'       : 'Sign In';
  String get authSignOut        => _tr ? 'Çıkış Yap'   : _es ? 'Cerrar sesión'  : _de ? 'Abmelden'   : _fr ? 'Se déconnecter': _pt ? 'Sair'          : 'Sign Out';
  String get authEmail          => _tr ? 'E-posta'     : _es ? 'Correo electrónico': _de ? 'E-Mail'   : _fr ? 'E-mail'        : _pt ? 'E-mail'       : 'Email';
  String get authPassword       => _tr ? 'Şifre'       : _es ? 'Contraseña'     : _de ? 'Passwort'   : _fr ? 'Mot de passe'  : _pt ? 'Senha'        : 'Password';
  String get authCreateAccount  => _tr ? 'Hesap Oluştur': _es ? 'Crear cuenta'   : _de ? 'Konto erstellen': _fr ? 'Créer un compte': _pt ? 'Criar conta': 'Create Account';
  String get authForgotPassword => _tr ? 'Şifremi Unuttum': _es ? 'Olvidé mi contraseña': _de ? 'Passwort vergessen': _fr ? 'Mot de passe oublié': _pt ? 'Esqueci a senha': 'Forgot Password';

  // ── Disclaimer ───────────────────────────────────────────────────────────
  String get disclaimer         => _tr ? 'KriptoPilot kişisel bir yardımcı araçtır. Kâr garantisi vermez. Kripto para ticareti ciddi risk içerir.' : _es ? 'KriptoPilot es una herramienta de asistencia personal. No garantiza ganancias. El trading de criptomonedas conlleva riesgos significativos.' : _de ? 'KriptoPilot ist ein persönliches Hilfsmittel. Es garantiert keine Gewinne. Der Kryptohandel ist mit erheblichen Risiken verbunden.' : _fr ? 'KriptoPilot est un outil d\'assistance personnel. Il ne garantit pas de bénéfices. Le trading de crypto-monnaies comporte des risques importants.' : _pt ? 'KriptoPilot é uma ferramenta de assistência pessoal. Não garante lucros. O trading de criptomoedas envolve riscos significativos.' : 'KriptoPilot is a personal assistant tool. It does not guarantee profits. Cryptocurrency trading involves significant risk.';
}
