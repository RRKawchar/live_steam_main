import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:rrk_stream_app/src/features/live_streaming/controller/live_streaming_controller.dart';
import 'package:rrk_stream_app/src/features/live_streaming/provider/live_stream_provider.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/widgets/audio_player_widget.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/widgets/live_appbar.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/widgets/live_control_buttons.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/widgets/video_preview_widget.dart';
import '../../../home/controller/home_controller.dart';

class LiveStreamingPage extends StatefulWidget {
  final bool isBroadCaster;
  final String channelName;
  const LiveStreamingPage({super.key, required this.isBroadCaster, required this.channelName,});

  @override
  State<LiveStreamingPage> createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        final streamProvider = Provider.of<LiveStreamProvider>(context, listen: false);

        streamProvider.initAgora(
          isBroadcaster: widget.isBroadCaster,
          channelName: widget.channelName,
        );
        streamProvider.initAudioPlayer();
    });
  }

  @override
  void dispose() {
    final streamProvider = Provider.of<LiveStreamProvider>(context, listen: false);
    streamProvider.disposeEngine();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        // title: Obx(()=> streamingController.showUI.value ?
        // SizedBox.shrink():
        // LiveAppbar(streamingController: streamingController),)
      ),
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () {
          //streamingController.showUI.value = !streamingController.showUI.value;
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // VideoPreviewWidget(
            //   streamingController: streamingController,
            //   homeController: homeController,
            // ),

            VideoPreviewWidget(
              isBroadCaster: widget.isBroadCaster,
              channelName: widget.channelName,
            ),

            streamingController.showUI.value
                ? SizedBox.shrink()
                : AudioPlayerWidget(
              streamingController: streamingController,
            ),
            //
            // streamingController.showUI.value
            //     ? SizedBox.shrink()
            //     : LiveControlButtons(
            //   streamingController: streamingController,
            // ),

          ],
        ),
      )
    );
  }
}
