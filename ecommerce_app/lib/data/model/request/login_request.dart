// lib/models/requests/login_request.dart

class LoginRequest {
  final String email;
  final String password;
  final String country;
  final String city;

  const LoginRequest({
    required this.email,
    required this.password,
    required this.country,
    required this.city,
  });

  Map<String, dynamic> toJson() => {
    'email':    email,
    'password': password,
    'country':  country,
    'city':     city,
  };
}