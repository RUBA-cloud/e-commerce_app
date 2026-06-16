// ─── SharedPrefKeys ───────────────────────────────────────────
// Add the new profile-related keys below the existing ones.
class SharedPrefKeys {
  // ── Auth ─────────────────────────────────────────────────────
  static const isSaved    = 'isSaved';
  static const accessToken = 'accessToken';
  static const refreshToken = 'refreshToken';
  static const userId      = 'userId';
  static const userEmail   = 'userEmail';
  static const userName    = 'userName';
  static const language    = 'language';
  static const theme       = 'theme';

  // ── Profile (added) ──────────────────────────────────────────
  static const userPhone   = 'userPhone';
  static const userAvatar  = 'userAvatar';
  static const userCountry = 'userCountry';
  static const userCity    = 'userCity';
  static const userStreet  = 'userStreet';
  static const userAddress = 'userAddress';
}