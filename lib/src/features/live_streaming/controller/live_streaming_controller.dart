import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/env/env.dart';

class LiveStreamingController extends GetxController{

  late TextEditingController audioFileController;
  late final AudioPlayer audioPlayer;
  late RtcEngine _engine;
  RxBool localUserJoined = false.obs;
  RxList<int> remoteUids = <int>[].obs;
  RxBool isPlaying = false.obs;
  RxBool muted = false.obs;
  RxString audioFilePath = "".obs;
  RxBool showUI = false.obs;

  RtcEngine get engine=>_engine;

  @override
  void onInit() {
    audioFileController=TextEditingController();
    super.onInit();
  }


  Future<void> _initAgora() async {
    await _requestPermissions();
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: kAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    await _engine.enableVideo();
    await _engine.setClientRole(
      role:ClientRoleType.clientRoleBroadcaster
    );
    await _engine.startPreview();


    _setupEventHandlers();

    await _engine.joinChannel(
      token: kToken,
      channelId: 'rrk-live',
      uid:0,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
      ),
    );
  }

  void _setupEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            localUserJoined(true);
          debugPrint("Local user ${connection.localUid} joined");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {

            if (!remoteUids.contains(remoteUid)) {
              remoteUids.add(remoteUid);
            }

          debugPrint("Remote user $remoteUid joined");
        },
        onUserOffline: (
            RtcConnection connection,
            int remoteUid,
            UserOfflineReasonType reason,
            ) {

            remoteUids.remove(remoteUid);

          debugPrint("Remote user $remoteUid left");
        },
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final permissions = [Permission.camera, Permission.microphone];
    final statuses = await permissions.request();
    if (statuses.values.any((status) => !status.isGranted)) {
      throw Exception('Permissions not granted');
    }
  }


}