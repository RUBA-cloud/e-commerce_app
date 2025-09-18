import 'package:ecommerce_app/views/auth/basic_auth.dart';
import 'package:ecommerce_app/views/auth/forget_password/forget_password_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class AppRoutes {
  static const home = '/';
  static const details = '/details';
  static const forgetPassword = '/forget-password';
  static const login = '/login';
  static const register = '/register';
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const BasicAuth(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.forgetPassword,
      page: () => ForgetPasswordPage(),
      transition: Transition.fadeIn,
    ),
  ];
}
