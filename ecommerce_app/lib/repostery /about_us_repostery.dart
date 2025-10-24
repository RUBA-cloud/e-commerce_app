// lib/features/about/data/about_repository.dart
import 'dart:async';
import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/models/about_us.dart';
import 'package:ecommerce_app/services/get_services.dart';
import 'package:ecommerce_app/services/pusher_service.dart';

abstract class AboutRepository {
  Future<AboutUsInfoModel?> fetch();
  Future<void> saveDataSql();
  Future<void> loadDataSql();
}

class MockAboutRepository implements AboutRepository {
  @override
  Future<AboutUsInfoModel?> fetch() async {
    await Future.delayed(const Duration(milliseconds: 400));
    var result = await PusherService().nextCompanyInfo();
    if (result == null) {
      print("Fetch");
      var apiAboutUs = await GetService.I.getJson(companyInfo);
      if (apiAboutUs.statusCode == 200) {
        return AboutUsInfoModel.fromJson(apiAboutUs.data!["data"]);
      }
    }
    return null;
  }

  @override
  Future<void> loadDataSql() {
    // TODO: implement loadDataSql
    throw UnimplementedError();
  }

  @override
  Future<void> saveDataSql() {
    // TODO: implement saveDataSql
    throw UnimplementedError();
  }
}
