

abstract class SharedPrefernceRepoistery {
  Future<void> setString(String key, String value);
  Future<void> removeString(String key);
  Future<String?> getString(String key);


}
