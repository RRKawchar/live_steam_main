import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/env/env.dart';
import '../../../core/helpers/helper_method.dart';
import '../../../core/service/audio_file_picker_service.dart';
import '../../home/controller/home_controller.dart';

class LiveStreamingController extends GetxController{
  final HomeController homeController=Get.find<HomeController>();
  late TextEditingController audioFileController;
  late final AudioPlayer audioPlayer;
  late RtcEngine _engine;
  RxBool localUserJoined = false.obs;
  RxList<int> remoteUids = <int>[].obs;
  RxBool isPlaying = false.obs;
  RxBool muted = false.obs;
  RxString audioFilePath = "".obs;
  RxBool showUI = false.obs;
  RxBool isPaused = false.obs;

  RtcEngine get engine=>_engine;


  void onSwitchCamera() {
    engine.switchCamera();
  }


  void onToggleMute() {
      muted.value = !muted.value;
      _engine.muteLocalAudioStream(muted.value);
      update();
  }


  void pickAudioFile() async {
    String? path = await AudioFilePickerService.pickedFile();
      audioFilePath.value = path!;
    kPrint("Audio File Path: $audioFilePath");
    audioFileController.text = _convertAudioFileName();
    update();
  }


  String _convertAudioFileName() {
    String text = "";
    if (audioFilePath.value.isNotEmpty) {
      text = audioFilePath.value.split('/').last;
    }
    return text;
  }

  @override
  void onInit() {
    audioFileController=TextEditingController();
    kPrint("isBroadCaster : ${homeController.isBroadcaster}");
    kPrint("ChannelName : ${homeController.channelName}");
    super.onInit();
     initAgora();
     initAudioPlayer();
  }


  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    audioPlayer.dispose();
    super.dispose();
  }


  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
  }

  Future<void> playAudio() async {
    final path = audioFilePath.value;
    if (path.isEmpty) return;

    try {
      if (isPaused.value) {
        await _engine.resumeAudioMixing();
        isPaused.value = false;
      } else {
        await _engine.startAudioMixing(filePath: path, loopback: false, cycle: 1);
      }
      isPlaying.value = true;
      update();
    } catch (e) {
      kPrint("Error playing/resuming audio mixing: $e");
    }
  }


  Future<void> stopAudio() async {
    await _engine.stopAudioMixing();
      isPlaying.value = false;
      isPaused.value=false;
      update();
  }

  Future<void> pauseAudio() async {
    await _engine.pauseAudioMixing();
    isPaused.value = true;
    isPlaying.value = false;
    update();
  }

  Future<void> initAgora() async {
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
      role:homeController.isBroadcaster?
      ClientRoleType.clientRoleBroadcaster
      :ClientRoleType.clientRoleAudience
    );

    if(homeController.isBroadcaster){
      try{
        await _engine.startPreview();
      }catch(e){
       kPrint(e.toString());
      }
    }

    _setupEventHandlers();

    await _engine.joinChannel(
      token: kToken,
      channelId: homeController.channelName!,
      uid:homeController.isBroadcaster?0:0,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType:homeController.isBroadcaster?
        ClientRoleType.clientRoleBroadcaster:
        ClientRoleType.clientRoleAudience,
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
              update();
            }

          debugPrint("Remote user $remoteUid joined");
        },
        onUserOffline: (
            RtcConnection connection,
            int remoteUid,
            UserOfflineReasonType reason,
            ) {

            remoteUids.remove(remoteUid);
            update();
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



  void endLiveStream() async {
    await engine.leaveChannel();
    await engine.release();
     Get.back();
  }




}