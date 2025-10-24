// lib/features/about/data/about_info.dart
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

  static AboutUsInfoModel fromJson(Map<String, dynamic> payload) {
    return AboutUsInfoModel(
      companyName: payload['companyName']?.toString() ?? '',
      tagline: payload['tagline']?.toString() ?? '',
      missionEn: payload['missionEn']?.toString() ?? '',
      missionAr: payload['missionAr']?.toString() ?? '',
      visionEn: payload['visionEn']?.toString() ?? '',
      visionAr: payload['visionAr']?.toString() ?? '',
      descriptionEn: payload['descriptionEn']?.toString() ?? '',
      descriptionAr: payload['descriptionAr']?.toString() ?? '',
      values: (payload['values'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      email: payload['email']?.toString() ?? '',
      phone: payload['phone']?.toString() ?? '',
      address: payload['address']?.toString() ?? '',
      website: payload['website']?.toString() ?? '',
      social: (payload['social'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')) ??
          <String, String>{},
    );
  }
}
