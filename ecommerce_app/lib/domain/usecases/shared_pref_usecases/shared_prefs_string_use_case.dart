
import 'package:ecommerce_app/domain/repoistery/shared_preference_repoistery.dart';
import 'package:injectable/injectable.dart';


@singleton
class SharedPrefsStringUseCase {
  final SharedPrefernceRepoistery _prefs;

  SharedPrefsStringUseCase(this._prefs);

  Future<void> execute(String key, String value) => _prefs.setString(key, value);
}