// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
//
// import '../../bloc/live_stream_bloc.dart';
// import '../../bloc/live_stream_state.dart';
//
//
// class VideoPreviewWidget extends StatelessWidget {
//   final bool isBroadCaster;
//   final String channelName;
//
//   const VideoPreviewWidget({
//     super.key,
//     required this.isBroadCaster,
//     required this.channelName,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LiveStreamBloc, LiveStreamState>(
//       builder: (context, state) {
//         final engine = state.engine;
//
//         if (engine == null) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         List<Widget> views = [];
//
//         if (isBroadCaster && state.localUserJoined) {
//           views.add(
//             AgoraVideoView(
//               controller: VideoViewController(
//                 rtcEngine: engine,
//                 canvas: const VideoCanvas(uid: 0),
//               ),
//             ),
//           );
//         }
//
//         for (var uid in state.remoteUids) {
//           views.add(
//             AgoraVideoView(
//               controller: VideoViewController.remote(
//                 rtcEngine: engine,
//                 canvas: VideoCanvas(uid: uid),
//                 connection: RtcConnection(channelId: channelName),
//               ),
//             ),
//           );
//         }
//
//         if (views.isEmpty) {
//           return const Center(child: Text("Waiting for stream..."));
//         }
//
//         if (views.length == 1) {
//           return Container(color: Colors.black, child: views[0]);
//         }
//
//         return GridView.builder(
//           itemCount: views.length,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             mainAxisSpacing: 4,
//             crossAxisSpacing: 4,
//             childAspectRatio: 1,
//           ),
//           itemBuilder: (context, index) => views[index],
//         );
//       },
//     );
//   }
// }
