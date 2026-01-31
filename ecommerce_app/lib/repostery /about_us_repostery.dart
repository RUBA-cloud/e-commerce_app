// lib/features/about/data/about_repository.dart
import 'dart:async';

import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/models/about_us.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:ecommerce_app/services/get_services.dart';
import 'package:ecommerce_app/services/sql/about_us_repoistery.dart'; // contains AboutLocalDataSource

abstract class AboutRepository {
  Future<AboutUsInfoModel?> fetch();
  Future<AboutUsInfoModel?> realTimeData();

  Future<void> saveDataSql(AboutUsInfoModel model);
  Future<AboutUsInfoModel?> loadDataSql();
}
class MockAboutRepository implements AboutRepository {
  bool isLoadedForfirstTime = false;
 


  final AboutLocalDataSource local = AboutLocalDataSource.instance;

  @override
  Future<AboutUsInfoModel?> fetch() async {
    // First call: hit API, save to SQLite
    if (!isLoadedForfirstTime || await checkConnectivity()) {
      await Future.delayed(const Duration(milliseconds: 400));

      final apiAboutUs = await GetService.I.getJson(companyInfo);
      isLoadedForfirstTime = true;

      final data = AboutUsInfoModel.fromJson(
        apiAboutUs['company'] as Map<String, dynamic>,
      );

      await saveDataSql(data);
      return data;
    }

    // Next calls: try realtime → fallback to local cache
    final rt = await realTimeData();
    if (rt != null) {
      return rt;
    }

    return await loadDataSql();
  }

  @override
  Future<AboutUsInfoModel?> loadDataSql() async {
    // ✅ must be async to use await
    final cached = await local.loadAbout();
    return cached;
  }

  @override
  Future<void> saveDataSql(AboutUsInfoModel model) async {
    // ✅ method is async so `await` is allowed
    await local.saveAbout(model);
  }

  @override
  Future<AboutUsInfoModel?> realTimeData() async {
    // result expected like API: { status, message, company: {...} }
    // final result = await PusherService().nextCompanyInfo();

    // if (result == null) {
      // no broadcast → return cached data
      return await loadDataSql();
    


    // keep SQLite in sync with latest broadcast
    // await saveDataSql(result);

    // return result;
  }
}
