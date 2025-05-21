import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:rrk_stream_app/src/core/di/app_bindings.dart';
import 'package:rrk_stream_app/src/core/helpers/helper_method.dart';
import 'package:rrk_stream_app/src/core/routes/routes.dart';
import 'package:rrk_stream_app/src/core/routes/routes_name.dart';
import 'package:rrk_stream_app/src/core/utils/app_constants.dart';
import 'package:rrk_stream_app/src/features/home/provider/home_provider.dart';
import 'package:rrk_stream_app/src/features/home/view/page/home_page.dart';
import 'package:rrk_stream_app/src/features/live_streaming/provider/live_stream_provider.dart';

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



    return MaterialApp(
      title: AppConstants.kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: RoutesName.homePage,
      onGenerateRoute: AppRoutes.generateRoute,
      builder: EasyLoading.init(),
    );
    // return MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(
    //         create: (_)=>HomeProvider()
    //     ),
    //     ChangeNotifierProvider(
    //         create: (_)=>LiveStreamProvider()
    //     ),
    //   ],
    //   child: MaterialApp(
    //     title: AppConstants.kAppName,
    //     debugShowCheckedModeBanner: false,
    //     theme: ThemeData(
    //       colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //     ),
    //     initialRoute: RoutesName.homePage,
    //     onGenerateRoute: AppRoutes.generateRoute,
    //     builder: EasyLoading.init(),
    //   )
    // );
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


