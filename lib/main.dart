import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:rrk_stream_app/src/core/di/app_bindings.dart';
import 'package:rrk_stream_app/src/core/helpers/helper_method.dart';
import 'package:rrk_stream_app/src/core/routes/routes.dart';
import 'package:rrk_stream_app/src/core/routes/routes_name.dart';
import 'package:rrk_stream_app/src/core/utils/app_constants.dart';

void main()async {

  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  HttpOverrides.global = MyHttpOverrides();

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {

    //for hide opened keyboard anywhere
    kHideKeyboard();


    return GetMaterialApp(
      title: AppConstants.kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialBinding: AppBindings(),
      initialRoute: RoutesName.homePage,
      getPages: Routes.routes,
      builder: EasyLoading.init(),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}


