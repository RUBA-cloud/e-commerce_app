import 'package:ecommerce_app/pages/app_root.dart';
import 'package:ecommerce_app/views/aboutUs/about_us.dart';
import 'package:ecommerce_app/views/branches/branches.dart';
import 'package:ecommerce_app/repostery%20/profile_repoiistery.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/views/auth/basic_auth.dart';
import 'package:ecommerce_app/views/auth/forget_password/forget_password_page.dart';
import 'package:ecommerce_app/views/auth/profile/profile.dart';
import 'package:ecommerce_app/views/home/home.dart';
import 'package:ecommerce_app/views/notification/notification.dart';
import 'package:ecommerce_app/views/orders/orders_page.dart';
import 'package:ecommerce_app/views/productDetails/product_details.dart';
import 'package:ecommerce_app/views/settings/settings.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class AppRoutes {
  static const home = '/';
  static const root = '/roots';
  static const details = '/details';
  static const forgetPassword = '/forget-password';
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
  static const aboutUs = '/aboutUs';
  static const branch = '/branches';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const orders = '/orders';
  static const ordersDetails = '/ordersDetails';
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
      name: AppRoutes.root,
      page: () => AppRoot(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.branch,
      page: () => BranchesPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => SettingsPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => NotificationPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.details,
      page: () => ProductDetailsPage(productId: "1"),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => OrdersPage(),
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
