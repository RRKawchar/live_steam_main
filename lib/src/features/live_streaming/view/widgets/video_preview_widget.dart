import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/live_stream_provider.dart';

class VideoPreviewWidget extends StatelessWidget {
  final bool isBroadCaster;
  final String channelName;
  const VideoPreviewWidget({super.key, required this.isBroadCaster, required this.channelName});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveStreamProvider>(
      builder: (context, streamProvider, _) {
        List<Widget> views = [];
        if (isBroadCaster && streamProvider.localUserJoined) {
          views.add(
            AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: streamProvider.engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
          );
        }

        // Remote views
        for (var uid in streamProvider.remoteUids) {
          views.add(
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: streamProvider.engine,
                canvas: VideoCanvas(uid: uid),
                connection: RtcConnection(channelId: channelName),
              ),
            ),
          );
        }

        // Return appropriate layout
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
      },
    );
  }
}



