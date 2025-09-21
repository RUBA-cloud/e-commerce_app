import 'package:ecommerce_app/views/aboutUs/about_us.dart';
import 'package:ecommerce_app/views/repostery%20/profile_repoiistery.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/views/auth/basic_auth.dart';
import 'package:ecommerce_app/views/auth/forget_password/forget_password_page.dart';
import 'package:ecommerce_app/views/auth/profile/profile.dart';
import 'package:ecommerce_app/views/home/home.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class AppRoutes {
  static const home = '/';
  static const details = '/details';
  static const forgetPassword = '/forget-password';
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
  static const aboutUs = '/aboutUs';
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.aboutUs,
      page: () => const AboutUsPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const BasicAuth(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.forgetPassword,
      page: () => ForgetPasswordPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => CustomProfileView(
        userModel: UserModel(
          name: 'runa',
          email: 'rubaahmedhammad@gmail.com',
          address: 'addredd',
          streetName: 'strre',
          phone: '07979797979',
          imageProfile: '',
        ),
        repo: ProfileRepository(),
      ),
      transition: Transition.fadeIn,
    ),
  ];
}
