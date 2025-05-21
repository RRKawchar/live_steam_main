import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rrk_stream_app/src/core/extensions/build_context_extension.dart';
import 'package:rrk_stream_app/src/core/helpers/helper_method.dart';

import '../../bloc/live_stream_bloc.dart';

class LiveStreamingPage extends StatelessWidget {
  final bool isBroadcaster;
  final String channelName;

  const LiveStreamingPage({
    super.key,
    required this.isBroadcaster,
    required this.channelName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LiveStreamBloc(
        channelName: channelName,
        isBroadcaster: isBroadcaster,
      )..add(InitializeStream(
        isBroadcaster: isBroadcaster,
        channelName: channelName,
      )),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: BlocBuilder<LiveStreamBloc, LiveStreamState>(
            builder: (context, state) {
              if (state is LiveStreamReady) {
                return _buildAppBarWidget(context, state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        body: BlocBuilder<LiveStreamBloc, LiveStreamState>(
          builder: (context, state) {
            if (state is LiveStreamError) {
              return Center(child: Text(state.message));
            }
            if (state is LiveStreamReady) {
              return GestureDetector(
                onTap: () {
                  context.read<LiveStreamBloc>().add(ToggleUI());
                },
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    _buildVideoView(context, state),
                    if (!state.showUI) ...[
                      // Positioned(
                      //   bottom: 100,
                      //   child: _audioPlayerWidget(context, state),
                      // ),
                      Positioned(
                        bottom: 40,
                        child: _liveControlWidget(context, state),
                      ),
                    ],
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildVideoView(BuildContext context, LiveStreamReady state) {
    List<Widget> views = [];

    if (state.isBroadcaster && state.localUserJoined) {
      views.add(
        AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: context.read<LiveStreamBloc>().engine,
            canvas: const VideoCanvas(uid: 0),
          ),
        ),
      );
    }

    for (var uid in state.remoteUids) {
      views.add(
        AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: context.read<LiveStreamBloc>().engine,
            canvas: VideoCanvas(uid: uid),
            connection: RtcConnection(channelId: channelName),
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
  }

  Widget _buildAppBarWidget(BuildContext context, LiveStreamReady state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () {},
          label: Text(
            "${state.remoteUids.length + (state.localUserJoined ? 1 : 0)}",
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          icon: const Icon(Icons.person, color: Colors.grey, size: 25),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFFF70000),
          ),
          child: const Text(
            "Live",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // Widget _audioPlayerWidget(BuildContext context, LiveStreamReady state) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //     child: state.audioFilePath.isNotEmpty
  //         ? Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
  //       width: context.screenWidth * 0.8,
  //       decoration: BoxDecoration(
  //         color: Colors.white.withOpacity(0.9),
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: const [
  //           BoxShadow(
  //             color: Colors.black26,
  //             blurRadius: 8,
  //             offset: Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //           children: [
  //           IconButton(
  //           onPressed: () {
  //     context.read<LiveStreamBloc>().add(PickAudioFile());
  //     },
  //       icon: const Icon(Icons.clear, size: 28, color: Colors.red),
  //     ),
  //     // Expanded(
  //     //   child: Text(
  //     //     state.audioFilePath.split('/').last,
  //     //     style: const TextStyle(fontSize: 14),
  //     //   ),
  //     //   IconButton(
  //     //     onPressed: () {
  //     //       if (state.isPlaying) {
  //     //         context.read<LiveStreamBloc>().add(StopAudio());
  //     //       } else {
  //     //         context.read<LiveStreamBloc>().add(PlayAudio());
  //     //       }
  //     //     },
  //     //     icon: Icon(
  //     //       state.isPlaying
  //     //           ? Icons.pause_circle_outline_outlined
  //     //           : Icons.play_circle_outline,
  //     //       size: 32,
  //     //       color: Colors.green,
  //     //     ),
  //     //   ),
  //     //   ],
  //     // ),
  //   )
  //       : ElevatedButton.icon(
  //   onPressed: () {
  //   context.read<LiveStreamBloc>().add(PickAudioFile());
  //   },
  //   icon: const Icon(Icons.audio_file_outlined),
  //   label: const Text('Choose Audio'),
  //   style: ElevatedButton.styleFrom(
  //   shape: RoundedRectangleBorder(
  //   borderRadius: BorderRadius.circular(12),
  //   ),
  //   padding:
  //   const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  //   textStyle: const TextStyle(fontSize: 16),
  //   ),
  //   ),
  //   );
  // }

  Widget _liveControlWidget(BuildContext context, LiveStreamReady state) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            context.read<LiveStreamBloc>().add(ToggleMute());
          },
          icon: Icon(
            state.muted ? Icons.mic_off : Icons.mic,
            size: 30,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.red,
          child: IconButton(
            onPressed: () {
              context.read<LiveStreamBloc>().add(EndStream());
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.call_end, color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () {
            context.read<LiveStreamBloc>().add(SwitchCamera());
          },
          icon: const Icon(
            Icons.switch_camera_outlined,
            size: 30,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}