import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrk_stream_app/src/core/extensions/build_context_extension.dart';
import 'package:rrk_stream_app/src/features/live_streaming/controller/live_streaming_controller.dart';

class AudioPlayerWidget extends StatelessWidget {
  final LiveStreamingController streamingController;
  const AudioPlayerWidget({super.key, required this.streamingController});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Obx(
          () =>
              streamingController.audioFilePath.value.isNotEmpty
                  ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    width: context.screenWidth * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            streamingController.audioFilePath.value = "";
                            streamingController.audioFileController.clear();
                            streamingController.stopAudio();
                          },
                          icon: Icon(Icons.clear, size: 28, color: Colors.red),
                        ),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            controller: streamingController.audioFileController,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Obx(
                          () => IconButton(
                            onPressed:
                                streamingController.isPlaying.value
                                    ? () {
                                     // streamingController.stopAudio();
                                      streamingController.pauseAudio();
                                    }
                                    : () {
                                      streamingController.playAudio();
                                    },
                            icon: Icon(
                              streamingController.isPlaying.value
                                  ? Icons.pause_circle_outline_outlined
                                  : Icons.play_circle_outline,
                              size: 32,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : ElevatedButton.icon(
                    onPressed: streamingController.pickAudioFile,
                    icon: Icon(Icons.audio_file_outlined),
                    label: Text('Choose Audio'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
        ),
      ),
    );
  }
}
