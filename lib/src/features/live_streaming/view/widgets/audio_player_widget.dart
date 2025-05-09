import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrk_stream_app/src/core/extensions/build_context_extension.dart';
import 'package:rrk_stream_app/src/features/live_streaming/controller/live_streaming_controller.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/live_stream_provider.dart';

class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Consumer<LiveStreamProvider>(
          builder: (context, streamingProvider, child) {
            return streamingProvider.audioFilePath.isNotEmpty
                ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),
              width: MediaQuery.of(context).size.width * 0.8,
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
                      streamingProvider.audioFileController.clear();
                      streamingProvider.stopAudio();
                      streamingProvider.clearAudioFilePath();
                    },
                    icon: const Icon(Icons.clear, size: 28, color: Colors.red),
                  ),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: streamingProvider.audioFileController,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: streamingProvider.isPlaying
                        ? streamingProvider.pauseAudio
                        : streamingProvider.playAudio,
                    icon: Icon(
                      streamingProvider.isPlaying
                          ? Icons.pause_circle_outline_outlined
                          : Icons.play_circle_outline,
                      size: 32,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            )
                : ElevatedButton.icon(
              onPressed: streamingProvider.pickAudioFile,
              icon: const Icon(Icons.audio_file_outlined),
              label: const Text('Choose Audio'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }
}

