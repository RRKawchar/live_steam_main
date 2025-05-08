import 'package:get/get.dart';
import 'package:rrk_stream_app/src/core/routes/routes_name.dart';
import 'package:rrk_stream_app/src/features/home/view/page/home_page.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/page/live_streaming_page.dart';

class Routes{

  static List<GetPage> routes=[
    GetPage(name: RoutesName.homePage,page: ()=>const HomePage()),
    // GetPage(name: RoutesName.liveStreamingPage,page: ()=>const LiveStreamingPage(
    //     isBroadcaster: isBroadcaster, channelName: channelName
    // )),
  ];


}