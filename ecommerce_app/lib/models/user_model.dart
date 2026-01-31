


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
   String? country;
    String? city;

  String? themee;
  String? imageProfile;
  bool? notificationEnabled;
  double?longtiude;
double?latiude;
  UserModel({
    required this.name,
    required this.email,
    required this.id,
    required this.address,
    required this.streetName,
    required this.phone,
    required this.imageProfile,
    required this.role,
    required this.accessToken,
    required this.notificationEnabled,
    required this.language,
    required  this.themee,
    required this.country ,
    required this.city,
  });
  static UserModel? currentUser;

  String? long ;

  String? lat;

  String? buildingNumber;

  
}
