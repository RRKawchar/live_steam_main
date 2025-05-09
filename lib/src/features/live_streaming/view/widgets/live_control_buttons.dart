import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/live_streaming_controller.dart';

class LiveControlButtons extends StatelessWidget {
  final LiveStreamingController streamingController;
  const LiveControlButtons({super.key, required this.streamingController});

  @override
  Widget build(BuildContext context) {
    return Positioned(bottom: 40, child:Row(
      children: [
        IconButton(
            onPressed: streamingController.onToggleMute,
            icon: Obx(()=>Icon(
              streamingController.muted.value ? Icons.mic_off : Icons.mic,
              size: 30,
              color: Colors.blue,
            ),)
        ),

        SizedBox(width: 10),

        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.red,
          child: IconButton(
            onPressed: streamingController.endLiveStream,
            icon: Icon(Icons.call_end, color: Colors.white),
          ),
        ),
        SizedBox(width: 10),

        IconButton(
          onPressed: streamingController.onSwitchCamera,
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
