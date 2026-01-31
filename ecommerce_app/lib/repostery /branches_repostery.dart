// lib/features/branches/data/branch_repository.dart
import 'dart:async';
import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/models/branches.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:ecommerce_app/services/get_services.dart';
import 'package:ecommerce_app/services/sql/company_branch_sql.dart';


abstract class BranchesRepository {
  Future<List<BranchModel>> fetchAll();
  Future<void> saveToSql(List<BranchModel> branches);
  Future<List<BranchModel>> loadFromBranch();
}

/// Real implementation: fetch from API, cache in SQLite,
/// and use SQLite when offline.
class ApiBranchesRepository implements BranchesRepository {
  final CompanyBranchSql _local;

  ApiBranchesRepository({CompanyBranchSql? local})
      : _local = local ?? CompanyBranchSql.instance;

  @override
  Future<List<BranchModel>> fetchAll() async {
    try {
      // 1) Try to get data from API
      if(await checkConnectivity()){
      final result = await GetService.I.getList(getBranches);
      // result should be List<dynamic>
      final branches = result["company"]["data"]
          .map<BranchModel>(
            (e) => BranchModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      // 2) Save to SQLite after installation / whenever we get fresh data
      await saveToSql(branches);

      return branches;
    }
    else {
      loadFromBranch();
    }
    } catch (e) {
      // 3) If no internet or API error → fallback to SQLite cache
      final cached = await loadFromBranch();
      return cached;
    }
    return [];
  }

  @override
  Future<void> saveToSql(List<BranchModel> branches) async {
    await _local.saveBranches(branches);
  }

  @override
  Future<List<BranchModel>> loadFromBranch() async {
    return _local.loadBranches();
  }
}
