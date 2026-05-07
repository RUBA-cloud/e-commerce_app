class ApiConstants {
  ApiConstants._();

  // ── Base ──────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://your-api.com/api'; // ← change

  // ── Endpoints ─────────────────────────────────────────────────────────────
  static const String login          = '/auth/login';
  static const String register       = '/auth/register';
  static const String logout         = '/auth/logout';
  static const String refresh        = '/auth/refresh';   // ← added
  static const String products       = '/products';
  static const String productById    = '/products/{id}';
  static const String searchProducts = '/products/search';
  static const String categories     = '/categories';
  static const String cart           = '/cart/add';
  static const String removeCart     = '/cart/{itemId}';
  static const String orders         = '/orders';
  static const String profile        = '/profile';
  static const String uploadAvatar   = '/profile/avatar';

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout    = Duration(seconds: 30);

  // ── Headers ───────────────────────────────────────────────────────────────
  static const String contentType   = 'application/json';
  static const String acceptHeader  = 'application/json';
  static const String authHeader    = 'Authorization';
  static const String bearerPrefix  = 'Bearer ';

  // ── SharedPreferences keys ────────────────────────────────────────────────
  static const String accessTokenKey  = 'access_token';   // ← added
  static const String refreshTokenKey = 'refresh_token';  // ← added
  static const String userIdKey       = 'user_id';
  static const String userEmailKey    = 'user_email';
}