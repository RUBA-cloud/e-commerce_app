
import 'package:ecommerce_app/domain/repoistery/shared_preference_repoistery.dart';
import 'package:injectable/injectable.dart';

@singleton
class SharedPrefsClearUseCase {
  final SharedPrefernceRepoistery _prefs;
  SharedPrefsClearUseCase (this._prefs);
  Future<void> execute() => _prefs.clearData();
}