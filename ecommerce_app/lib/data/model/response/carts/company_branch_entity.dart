import 'package:json_annotation/json_annotation.dart';

part 'company_branch_entity.g.dart';

@JsonSerializable()
class CompanyBranchEntity {
  String status;
  String message;
  CompanyBranchBranchesEntity branches;

  CompanyBranchEntity(this.status, this.message, this.branches);

  factory CompanyBranchEntity.fromJson(Map<String, dynamic> json) =>
      _$CompanyBranchEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyBranchEntityToJson(this);
}

@JsonSerializable()
class CompanyBranchBranchesEntity {
  @JsonKey(name: 'current_page')
  int currentPage;
  List<CompanyBranchBranchesDataEntity> data;
  @JsonKey(name: 'first_page_url')
  String firstPageUrl;
  int from;
  @JsonKey(name: 'last_page')
  int lastPage;
  @JsonKey(name: 'last_page_url')
  String lastPageUrl;
  List<CompanyBranchBranchesLinksEntity> links;
  @JsonKey(name: 'next_page_url')
  dynamic nextPageUrl;
  String path;
  @JsonKey(name: 'per_page')
  int perPage;
  @JsonKey(name: 'prev_page_url')
  dynamic prevPageUrl;
  int to;
  int total;

  CompanyBranchBranchesEntity(
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  );

  factory CompanyBranchBranchesEntity.fromJson(Map<String, dynamic> json) =>
      _$CompanyBranchBranchesEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyBranchBranchesEntityToJson(this);
}

@JsonSerializable()
class CompanyBranchBranchesDataEntity {
  int id;
  @JsonKey(name: 'company_info_id')
  dynamic companyInfoId;
  @JsonKey(name: 'name_en')
  String nameEn;
  @JsonKey(name: 'name_ar')
  String nameAr;
  @JsonKey(name: 'is_active')
  bool isActive;
  String phone;
  String email;
  @JsonKey(name: 'address_en')
  String addressEn;
  @JsonKey(name: 'address_ar')
  String addressAr;
  dynamic location;
  dynamic image;
  @JsonKey(name: 'working_hours')
  dynamic workingHours;
  @JsonKey(name: 'working_hours_from')
  String workingHoursFrom;
  @JsonKey(name: 'working_hours_to')
  String workingHoursTo;
  @JsonKey(name: 'working_days')
  String workingDays;
  dynamic fax;
  @JsonKey(name: 'user_id')
  dynamic userId;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;
  @JsonKey(name: 'company_id')
  int companyId;

  CompanyBranchBranchesDataEntity(
    this.id,
    this.companyInfoId,
    this.nameEn,
    this.nameAr,
    this.isActive,
    this.phone,
    this.email,
    this.addressEn,
    this.addressAr,
    this.location,
    this.image,
    this.workingHours,
    this.workingHoursFrom,
    this.workingHoursTo,
    this.workingDays,
    this.fax,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.companyId,
  );

  factory CompanyBranchBranchesDataEntity.fromJson(Map<String, dynamic> json) =>
      _$CompanyBranchBranchesDataEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CompanyBranchBranchesDataEntityToJson(this);
}

@JsonSerializable()
class CompanyBranchBranchesLinksEntity {
  dynamic url;
  String label;
  dynamic page;
  bool active;

  CompanyBranchBranchesLinksEntity(
    this.url,
    this.label,
    this.page,
    this.active,
  );

  factory CompanyBranchBranchesLinksEntity.fromJson(
    Map<String, dynamic> json,
  ) => _$CompanyBranchBranchesLinksEntityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CompanyBranchBranchesLinksEntityToJson(this);
}
