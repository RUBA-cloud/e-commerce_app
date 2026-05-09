import 'package:ecommerce_app/domain/repoistery/shared_preference_repoistery.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@Singleton(as: SharedPrefernceRepoistery)
class SharedPrefencesImp implements SharedPrefernceRepoistery {
  final SharedPreferences _prefs;

  SharedPrefencesImp(this._prefs);
  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> removeString(String key) {
    // TODO: implement removeString
    throw UnimplementedError();
  }

  @override
  Future<void> setString(String key, String value) async{
   await _prefs.setString(key, value);
  }


  
}