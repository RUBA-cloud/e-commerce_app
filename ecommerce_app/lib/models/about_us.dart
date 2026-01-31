
class AboutUsInfoModel {
  final String companyName;
  final String tagline;

  final String missionEn;
  final String missionAr;

  final String visionEn;
  final String visionAr;
  final String descriptionEn;
  final String descriptionAr;

  final List<String> values;

  final String email;
  final String phone;
  final String address;
  final String website;
  final Map<String, String> social;

  const AboutUsInfoModel({
    required this.companyName,
    required this.tagline,
    required this.missionEn,
    required this.missionAr,
    required this.visionEn,
    required this.visionAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.values,
    required this.email,
    required this.phone,
    required this.address,
    required this.website,
    required this.social,
  });

  /// payload here is the **company** object from your API:
  /// e.g. `AboutUsInfoModel.fromJson(response.data['company'])`
  static AboutUsInfoModel fromJson(Map<String, dynamic> payload) {
    final dynamic rawValues = payload['values'];
    final List<String> values;
    if (rawValues is List) {
      values = rawValues.map((e) => e.toString()).toList();
    } else if (rawValues is String && rawValues.trim().isNotEmpty) {
      values = rawValues.split(',').map((e) => e.trim()).toList();
    } else {
      values = <String>[];
    }

    final Map<String, String> social = {};
    if (payload['facebook'] != null &&
        payload['facebook'].toString().isNotEmpty) {
      social['facebook'] = payload['facebook'].toString();
    }
    if (payload['instagram'] != null &&
        payload['instagram'].toString().isNotEmpty) {
      social['instagram'] = payload['instagram'].toString();
    }
    if (payload['twitter'] != null &&
        payload['twitter'].toString().isNotEmpty) {
      social['twitter'] = payload['twitter'].toString();
    }

    return AboutUsInfoModel(
      companyName: payload['name_en']?.toString() ?? '',
      tagline:
          payload['tagline']?.toString() ?? payload['mission_en']?.toString() ?? '',
      missionEn: payload['mission_en']?.toString() ?? '',
      missionAr: payload['mission_ar']?.toString() ?? '',
      visionEn: payload['vision_en']?.toString() ?? '',
      visionAr: payload['vision_ar']?.toString() ?? '',
      descriptionEn: payload['about_us_en']?.toString() ?? '',
      descriptionAr: payload['about_us_ar']?.toString() ?? '',
      values: values,
      email: payload['email']?.toString() ?? '',
      phone: payload['phone']?.toString() ?? '',
      address: payload['address_en']?.toString() ?? '',
      website: payload['website']?.toString() ??
          payload['facebook']?.toString() ??
          '',
      social: social,
    );
  }

  /// This will be saved as JSON in SQLite
  Map<String, dynamic> toJson() {
    return {
      'name_en': companyName,
      'tagline': tagline,
      'mission_en': missionEn,
      'mission_ar': missionAr,
      'vision_en': visionEn,
      'vision_ar': visionAr,
      'about_us_en': descriptionEn,
      'about_us_ar': descriptionAr,
      'values': values,
      'email': email,
      'phone': phone,
      'address_en': address,
      'website': website,
      'facebook': social['facebook'],
      'instagram': social['instagram'],
      'twitter': social['twitter'],
    };
  }
}
