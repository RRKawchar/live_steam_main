// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:xebraa_stream/src/core/core.dart';
// import 'package:xebraa_stream/src/core/env/env.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:xebraa_stream/src/core/services/audio_file_picker_services.dart';
//
// class LiveStreamController extends GetxController {
//   late RtcEngine _engine;
//   late final AudioPlayer _audioPlayer;
//
//   final remoteUids = <int>[].obs;
//   final localUserJoined = false.obs;
//   final muted = false.obs;
//   final isPlaying = false.obs;
//   final audioFilePath = RxnString();
//
//   void toggleMute() => muted.value = !muted.value;
//
//   void _setPlaying(bool value) => isPlaying.value = value;
//
//   void _setAudioPath(String? path) => audioFilePath.value = path;
//
//   void _setLocalUserJoined(bool value) => localUserJoined.value = value;
//
//   void _addRemoteUid(int uid) => remoteUids.add(uid);
//
//   void _removeRemoteUid(int uid) => remoteUids.remove(uid);
//
//   RtcEngine get rtcEngine => _engine;
//
//   AudioPlayer get audioPlayer => _audioPlayer;
//
//   Future<void> initAgora({
//     required String channelName,
//     required bool isBroadcaster,
//   }) async {
//     await [Permission.microphone, Permission.camera].request();
//
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(RtcEngineContext(appId: Env.appId));
//
//     await _engine.enableVideo();
//     await _engine.setChannelProfile(
//       ChannelProfileType.channelProfileLiveBroadcasting,
//     );
//
//     if (isBroadcaster) {
//       await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//       await _engine.startPreview();
//     } else {
//       await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
//     }
//
//     _engine.registerEventHandler(RtcEngineEventHandler(
//       onJoinChannelSuccess: (connection, elapsed) {
//         Log.debug('Local user ${connection.localUid} joined');
//         _setLocalUserJoined(true);
//       },
//       onUserJoined: (connection, remoteUid, elapsed) {
//         Log.debug('Remote user $remoteUid joined');
//         _addRemoteUid(remoteUid);
//       },
//       onUserOffline: (connection, remoteUid, reason) {
//         Log.debug('Remote user $remoteUid left');
//         _removeRemoteUid(remoteUid);
//       },
//     ));
//
//     await _engine.joinChannel(
//       token: Env.token,
//       channelId: channelName,
//       uid: 0,
//       options: ChannelMediaOptions(
//         clientRoleType: isBroadcaster
//             ? ClientRoleType.clientRoleBroadcaster
//             : ClientRoleType.clientRoleAudience,
//         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//       ),
//     );
//   }
//
//   void onToggleMute() {
//     toggleMute();
//     _engine.muteLocalAudioStream(muted.value);
//   }
//
//   void onSwitchCamera() {
//     _engine.switchCamera();
//   }
//
//   void initAudioPlayer(){
//     _audioPlayer = AudioPlayer();
//   }
//
//   Future<void> pickAudioFile() async {
//     String? path = await AudioFilePickerServices.pick();
//     _setAudioPath(path);
//   }
//
//   Future<void> clearAudioFile() async {
//     _setAudioPath(null);
//     if (isPlaying.value) {
//       await stopAudio();
//     }
//   }
//
//   Future<void> playAudio() async {
//     final path = audioFilePath.value;
//     if (path == null) return;
//
//     try {
//       await _engine.startAudioMixing(
//         filePath: path,
//         loopback: false,
//         cycle: 1,
//       );
//       _setPlaying(true);
//     } catch (e) {
//       Log.debug("Error starting audio mixing: $e");
//     }
//   }
//
//   Future<void> stopAudio() async {
//     await _engine.stopAudioMixing();
//     _setPlaying(false);
//   }
//
//   void disposeEngine(){
//     _engine.leaveChannel();
//     _engine.release();
//   }
//
//   void disposeAudioPlayer(){
//     _audioPlayer.dispose();
//   }
// }