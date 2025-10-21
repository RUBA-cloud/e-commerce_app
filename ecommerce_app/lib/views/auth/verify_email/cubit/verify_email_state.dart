// lib/features/auth/verify_email/verify_email_cubit.dart
class VerifyEmailState {
  final bool sending; // currently sending verification email
  final bool sent; // last send succeeded
  final String? error; // last error
  final int secondsLeft; // resend cooldown
  final bool checking; // checking verification status
  final bool verified; // user verified

  const VerifyEmailState({
    this.sending = false,
    this.sent = false,
    this.error,
    this.secondsLeft = 0,
    this.checking = false,
    this.verified = false,
  });

  VerifyEmailState copyWith({
    bool? sending,
    bool? sent,
    String? error,
    int? secondsLeft,
    bool? checking,
    bool? verified,
  }) {
    return VerifyEmailState(
      sending: sending ?? this.sending,
      sent: sent ?? this.sent,
      error: error, // pass null to clear
      secondsLeft: secondsLeft ?? this.secondsLeft,
      checking: checking ?? this.checking,
      verified: verified ?? this.verified,
    );
  }
}
