import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrk_stream_app/src/features/live_streaming/controller/live_streaming_controller.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/widgets/audio_player_widget.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/widgets/live_appbar.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/widgets/live_control_buttons.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/widgets/video_preview_widget.dart';
import '../../../home/controller/home_controller.dart';

class LiveStreamingPage extends StatelessWidget {
  const LiveStreamingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController=Get.find<HomeController>();
    final LiveStreamingController streamingController=Get.find<LiveStreamingController>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Obx(()=> streamingController.showUI.value ?
        SizedBox.shrink():
        LiveAppbar(streamingController: streamingController),)
      ),
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: Obx((){
        return GestureDetector(
          onTap: () {
              streamingController.showUI.value = !streamingController.showUI.value;
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
             VideoPreviewWidget(
               streamingController: streamingController,
               homeController: homeController,
             ),

              streamingController.showUI.value
                  ? SizedBox.shrink()
                  : AudioPlayerWidget(
                    streamingController: streamingController,
                  ),

              streamingController.showUI.value
                  ? SizedBox.shrink()
                  : LiveControlButtons(
                   streamingController: streamingController,
              ),

            ],
          ),
        );
      })
    );
  }
}
