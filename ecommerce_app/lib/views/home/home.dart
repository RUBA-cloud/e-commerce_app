import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.aboutUs),
                child: Text("about_us".tr),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.profile),
                child: Text("profile".tr),
              ),
            ],
          ),
        ),
        body: Column(children: [Text("data")]),
      ),
    );
  }
}
