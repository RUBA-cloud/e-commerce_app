class RegisterRequest {
  final String name;
  final String email;
  final String password;

  final String phone;
  final String country;
  final String city;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.country,
    required this.city,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'country': country,
        'city': city,
      };
}