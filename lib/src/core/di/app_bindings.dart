import 'package:get/get.dart';
import 'package:rrk_stream_app/src/features/live_streaming/controller/live_streaming_controller.dart';

class AppBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=>LiveStreamingController(),fenix: true);
  }

}