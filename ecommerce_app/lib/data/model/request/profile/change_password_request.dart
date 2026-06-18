class ChangePasswordRequest {
  final String? currentPassword;
  final String? password;

  const ChangePasswordRequest({
    this.currentPassword,
    this.password,
  });

  Map<String, dynamic> toJson() => {
    if (currentPassword != null) 'current_password': currentPassword,
    if (password != null) 'password': password,

  };

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      currentPassword: json['current_password'] as String?,
      password: json['password'] as String?,
    );
  }

  ChangePasswordRequest copyWith({
    String? currentPassword,
    String? password,
  }) {
    return ChangePasswordRequest(
      currentPassword: currentPassword ?? this.currentPassword,
      password: password ?? this.password,
    );
  }

  @override
  String toString() =>
      'ChangePasswordRequest(currentPassword: [hidden], password: [hidden])';
}