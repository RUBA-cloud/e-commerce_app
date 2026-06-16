// lib/constant/pusher_config.dart

class PusherConfig {
  PusherConfig._();

  static const String appKey  = '33708d4364fab09314c6';
  static const String cluster = 'ap2';

  // If using Pusher hosted service leave host empty ('') —
  // pusher_client uses cluster to resolve the host automatically.
  // If using a self-hosted Soketi server set host to your server URL.
  static const String host      = '';     // e.g. 'soketi.yourserver.com' or ''
  static const int    wsPort    = 443;    // 443 for TLS, 6001 for local Soketi
  static const bool   encrypted = true;   // false only for local dev
}