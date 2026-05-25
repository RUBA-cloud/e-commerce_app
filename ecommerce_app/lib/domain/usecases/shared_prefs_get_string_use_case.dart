
import 'package:ecommerce_app/domain/repoistery/shared_preference_repoistery.dart';
import 'package:injectable/injectable.dart';

@singleton
class SharedPrefsGetStringUseCase {
  final SharedPrefernceRepoistery _prefs;
  SharedPrefsGetStringUseCase (this._prefs);
  Future<String?> execute(String key) => _prefs.getString(key);
}