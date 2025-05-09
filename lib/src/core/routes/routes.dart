import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrk_stream_app/src/core/routes/routes_name.dart';
import 'package:rrk_stream_app/src/features/home/view/page/home_page.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/page/live_streaming_page.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.homePage:
        return MaterialPageRoute(builder: (_) => const HomePage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('No route defined')),
          ),
        );
    }
  }
}