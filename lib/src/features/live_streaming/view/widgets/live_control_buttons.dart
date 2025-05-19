import 'package:flutter/material.dart';
import 'package:rrk_stream_app/src/features/live_streaming/provider/live_stream_provider.dart';


class LiveControlButtons extends StatelessWidget {
  final LiveStreamProvider liveStreamProvider;
  const LiveControlButtons({super.key, required this.liveStreamProvider});

  @override
  Widget build(BuildContext context) {
    return Positioned(bottom: 40, child:Row(
      children: [
        IconButton(
            onPressed: liveStreamProvider.onToggleMute,
            icon: Icon(
              liveStreamProvider.muted ? Icons.mic_off : Icons.mic,
              size: 30,
              color: Colors.blue,
            ),
        ),

        SizedBox(width: 10),

        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.red,
          child: IconButton(
            onPressed: ()=>liveStreamProvider.endLiveStream(context),
            icon: Icon(Icons.call_end, color: Colors.white),
          ),
        ),
        SizedBox(width: 10),

        IconButton(
          onPressed: liveStreamProvider.onSwitchCamera,
          icon: Icon(
            Icons.switch_camera_outlined,
            size: 30,
            color: Colors.blue,
          ),
        ),
      ],
    ));
  }
}
