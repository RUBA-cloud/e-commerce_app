import 'package:ecommerce_app/pages/app_root.dart';
import 'package:ecommerce_app/repostery%20/profile_repoiistery.dart';

import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
bool data = await ProfileRepository().loadUserFromPrefs();
 if(data) {
   
 }
  // Initialize FFI for desktop / tests

  runApp(const AppRoot());
}

