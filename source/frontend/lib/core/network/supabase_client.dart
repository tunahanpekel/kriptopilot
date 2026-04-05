// lib/core/network/supabase_client.dart
// KriptoPilot — Supabase client accessor

import 'package:supabase_flutter/supabase_flutter.dart';

/// Global Supabase client shortcut.
SupabaseClient get supabase => Supabase.instance.client;
