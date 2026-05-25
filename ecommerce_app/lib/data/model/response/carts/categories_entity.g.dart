// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoriesEntity _$CategoriesEntityFromJson(Map<String, dynamic> json) =>
    CategoriesEntity(
      json['status'] as String,
      json['message'] as String,
      CategoriesDataEntity.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CategoriesEntityToJson(CategoriesEntity instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

CategoriesDataEntity _$CategoriesDataEntityFromJson(
  Map<String, dynamic> json,
) => CategoriesDataEntity(
  (json['current_page'] as num).toInt(),
  (json['data'] as List<dynamic>)
      .map((e) => CategoriesDataDataEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['first_page_url'] as String,
  (json['from'] as num).toInt(),
  (json['last_page'] as num).toInt(),
  json['last_page_url'] as String,
  (json['links'] as List<dynamic>)
      .map((e) => CategoriesDataLinksEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['next_page_url'],
  json['path'] as String,
  (json['per_page'] as num).toInt(),
  json['prev_page_url'],
  (json['to'] as num).toInt(),
  (json['total'] as num).toInt(),
);

Map<String, dynamic> _$CategoriesDataEntityToJson(
  CategoriesDataEntity instance,
) => <String, dynamic>{
  'current_page': instance.currentPage,
  'data': instance.data,
  'first_page_url': instance.firstPageUrl,
  'from': instance.from,
  'last_page': instance.lastPage,
  'last_page_url': instance.lastPageUrl,
  'links': instance.links,
  'next_page_url': instance.nextPageUrl,
  'path': instance.path,
  'per_page': instance.perPage,
  'prev_page_url': instance.prevPageUrl,
  'to': instance.to,
  'total': instance.total,
};

CategoriesDataDataEntity _$CategoriesDataDataEntityFromJson(
  Map<String, dynamic> json,
) => CategoriesDataDataEntity(
  (json['id'] as num).toInt(),
  json['name_en'] as String,
  json['name_ar'] as String,
  (json['is_active'] as num).toInt(),
  json['image'],
  (json['user_id'] as num).toInt(),
  json['created_at'] as String,
  json['updated_at'] as String,
  (json['products'] as List<dynamic>)
      .map(
        (e) => CategoriesDataDataProductsEntity.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
);

Map<String, dynamic> _$CategoriesDataDataEntityToJson(
  CategoriesDataDataEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'is_active': instance.isActive,
  'image': instance.image,
  'user_id': instance.userId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'products': instance.products,
};

CategoriesDataDataProductsEntity _$CategoriesDataDataProductsEntityFromJson(
  Map<String, dynamic> json,
) => CategoriesDataDataProductsEntity(
  (json['id'] as num).toInt(),
  json['name_en'] as String,
  json['name_ar'] as String,
  json['description_en'] as String,
  json['description_ar'] as String,
  json['price'] as String,
  json['is_active'] as bool,
  (json['user_id'] as num).toInt(),
  (json['category_id'] as num).toInt(),
  json['created_at'] as String,
  json['updated_at'] as String,
  json['deleted_at'] as String?,
  (json['type_id'] as num).toInt(),
  (json['colors'] as List<dynamic>).map((e) => e as String).toList(),
  json['main_image'] as String,
  (json['size_id'] as num).toInt(),
  (json['images'] as List<dynamic>)
      .map(
        (e) => CategoriesDataDataProductsImagesEntity.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  (json['sizes'] as List<dynamic>)
      .map(
        (e) => CategoriesDataDataProductsSizesEntity.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  json['additionals'] as List<dynamic>,
  CategoriesDataDataProductsCategoryEntity.fromJson(
    json['category'] as Map<String, dynamic>,
  ),
  CategoriesDataDataProductsTypeEntity.fromJson(
    json['type'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$CategoriesDataDataProductsEntityToJson(
  CategoriesDataDataProductsEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'description_en': instance.descriptionEn,
  'description_ar': instance.descriptionAr,
  'price': instance.price,
  'is_active': instance.isActive,
  'user_id': instance.userId,
  'category_id': instance.categoryId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
  'type_id': instance.typeId,
  'colors': instance.colors,
  'main_image': instance.mainImage,
  'size_id': instance.sizeId,
  'images': instance.images,
  'sizes': instance.sizes,
  'additionals': instance.additionals,
  'category': instance.category,
  'type': instance.type,
};

CategoriesDataDataProductsImagesEntity
_$CategoriesDataDataProductsImagesEntityFromJson(Map<String, dynamic> json) =>
    CategoriesDataDataProductsImagesEntity(
      (json['id'] as num).toInt(),
      (json['product_id'] as num).toInt(),
      json['image_path'] as String,
      json['created_at'] as String,
      json['updated_at'] as String,
    );

Map<String, dynamic> _$CategoriesDataDataProductsImagesEntityToJson(
  CategoriesDataDataProductsImagesEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'image_path': instance.imagePath,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

CategoriesDataDataProductsSizesEntity
_$CategoriesDataDataProductsSizesEntityFromJson(Map<String, dynamic> json) =>
    CategoriesDataDataProductsSizesEntity(
      (json['id'] as num).toInt(),
      json['name_en'] as String,
      json['name_ar'] as String,
      json['is_active'] as bool,
      (json['user_id'] as num).toInt(),
      json['created_at'] as String,
      json['updated_at'] as String,
      json['image'] as String?,
      json['descripation'] as String?,
      (json['price'] as num).toInt(),
      CategoriesDataDataProductsSizesPivotEntity.fromJson(
        json['pivot'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$CategoriesDataDataProductsSizesEntityToJson(
  CategoriesDataDataProductsSizesEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'is_active': instance.isActive,
  'user_id': instance.userId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'image': instance.image,
  'descripation': instance.descripation,
  'price': instance.price,
  'pivot': instance.pivot,
};

CategoriesDataDataProductsSizesPivotEntity
_$CategoriesDataDataProductsSizesPivotEntityFromJson(
  Map<String, dynamic> json,
) => CategoriesDataDataProductsSizesPivotEntity(
  (json['product_id'] as num).toInt(),
  (json['size_id'] as num).toInt(),
);

Map<String, dynamic> _$CategoriesDataDataProductsSizesPivotEntityToJson(
  CategoriesDataDataProductsSizesPivotEntity instance,
) => <String, dynamic>{
  'product_id': instance.productId,
  'size_id': instance.sizeId,
};

CategoriesDataDataProductsCategoryEntity
_$CategoriesDataDataProductsCategoryEntityFromJson(Map<String, dynamic> json) =>
    CategoriesDataDataProductsCategoryEntity(
      (json['id'] as num).toInt(),
      json['name_en'] as String,
      json['name_ar'] as String,
      (json['is_active'] as num).toInt(),
      json['image'],
      (json['user_id'] as num).toInt(),
      json['created_at'] as String,
      json['updated_at'] as String,
    );

Map<String, dynamic> _$CategoriesDataDataProductsCategoryEntityToJson(
  CategoriesDataDataProductsCategoryEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'is_active': instance.isActive,
  'image': instance.image,
  'user_id': instance.userId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

CategoriesDataDataProductsTypeEntity
_$CategoriesDataDataProductsTypeEntityFromJson(Map<String, dynamic> json) =>
    CategoriesDataDataProductsTypeEntity(
      (json['id'] as num).toInt(),
      json['name_en'] as String,
      json['name_ar'] as String,
      json['is_active'] as bool,
      (json['user_id'] as num).toInt(),
      json['created_at'] as String,
      json['updated_at'] as String,
    );

Map<String, dynamic> _$CategoriesDataDataProductsTypeEntityToJson(
  CategoriesDataDataProductsTypeEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'is_active': instance.isActive,
  'user_id': instance.userId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

CategoriesDataLinksEntity _$CategoriesDataLinksEntityFromJson(
  Map<String, dynamic> json,
) => CategoriesDataLinksEntity(
  json['url'],
  json['label'] as String,
  json['page'],
  json['active'] as bool,
);

Map<String, dynamic> _$CategoriesDataLinksEntityToJson(
  CategoriesDataLinksEntity instance,
) => <String, dynamic>{
  'url': instance.url,
  'label': instance.label,
  'page': instance.page,
  'active': instance.active,
};
