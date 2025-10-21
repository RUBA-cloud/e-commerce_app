class UserModel {
  int? id;
  String? name;
  String? email;
  String? role;
  String? address;
  String? streetName;
  String? phone;
  String? accessToken;
  String? language;
  String? themee;
  String? imageProfile;
  UserModel({
    required this.name,
    required this.email,
    required this.id,
    required this.address,
    required this.streetName,
    required this.phone,
    required this.imageProfile,
    required this.role,
  });
  static UserModel? currentUser;
}
