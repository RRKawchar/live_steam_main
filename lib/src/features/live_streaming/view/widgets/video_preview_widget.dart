import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrk_stream_app/src/features/home/controller/home_controller.dart';
import 'package:rrk_stream_app/src/features/live_streaming/controller/live_streaming_controller.dart';

class VideoPreviewWidget extends StatelessWidget {
  final LiveStreamingController streamingController;
  final HomeController homeController;
  const VideoPreviewWidget({super.key,
    required this.streamingController,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    return  Obx((){
      List<Widget> views = [];

      // Add local view for broadcaster
      if (homeController.isBroadcaster && streamingController.localUserJoined.value) {
        views.add(
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine:streamingController.engine,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
        );
      }

      // Add remote views
      for (var uid in streamingController.remoteUids) {
        views.add(
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: streamingController.engine,
              canvas: VideoCanvas(uid: uid),
              connection: RtcConnection(channelId: homeController.channelName),
            ),
          ),
        );
      }

      if (views.isEmpty) {
        return const Center(child: Text("Waiting for stream..."));
      }

      if (views.length == 1) {
        return Container(color: Colors.black, child: views[0]);
      }

      return GridView.builder(
        itemCount: views.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) => views[index],
      );
    });
  }
}


