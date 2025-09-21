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
}
