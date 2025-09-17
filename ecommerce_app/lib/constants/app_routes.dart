import 'package:ecommerce_app/pages/main_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class AppRoutes {
  static const home = '/';
  static const details = '/details';
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
  ];
}
