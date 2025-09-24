// lib/features/branches/data/branch_repository.dart
import 'dart:async';
import 'package:ecommerce_app/models/branches.dart';

abstract class BranchesRepository {
  Future<List<BranchModel>> fetchAll();
}

class MockBranchesRepository implements BranchesRepository {
  @override
  Future<List<BranchModel>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return const [
      BranchModel(
        nameEn: 'Downtown Branch',
        nameAr: 'فرع وسط البلد',
        workingDays: [1, 2, 3, 4, 5, 6], // Mon-Sat
        hoursFrom: '09:00',
        hoursTo: '18:00',
        address: 'King Hussein St, Amman',
        lat: 31.9552,
        lng: 35.9450,
      ),
      BranchModel(
        nameEn: 'Sweifieh Branch',
        nameAr: 'فرع الصويفية',
        workingDays: [1, 2, 3, 4, 5], // Mon-Fri
        hoursFrom: '10:00',
        hoursTo: '20:00',
        address: 'Sweifieh, Amman',
        lat: 31.9555,
        lng: 35.8600,
      ),
      BranchModel(
        nameEn: 'Abdoun Branch',
        nameAr: 'فرع عبدون',
        workingDays: [1, 2, 3, 4, 5, 6, 7], // Daily
        hoursFrom: '00:00',
        hoursTo: '23:59',
        address: 'Abdoun, Amman',
        lat: 31.9519,
        lng: 35.9019,
      ),
    ];
  }
}
