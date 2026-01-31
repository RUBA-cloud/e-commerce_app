import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:ecommerce_app/services/post_services.dart';

abstract class ChangePasswordRepository {
  Future<bool> changePassword(String oldPassword, String newPassword);
}

/// ✅ Real implementation (not mock)
class ChangePasswordRepositoryImpl implements ChangePasswordRepository {

  ChangePasswordRepositoryImpl({PostServices? postServices});
  
  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    // ✅ validation
    final oldP = oldPassword.trim();
    final newP = newPassword.trim();

    if (oldP.isEmpty || newP.isEmpty) return false;
    if (newP.length < 6) return false;
    if (oldP == newP) return false;

    try {
      final res = await PostServices.I.postJson(
        changePasswordApi,
        options: authOptions,
          json: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      // If your postJson returns an http Response (or Dio Response), it should have statusCode
      final status = res.statusCode;

      return status == 200 || status == 201;
    } catch (_) {
      return false;
    }
  }
}
