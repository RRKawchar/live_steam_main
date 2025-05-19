import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/env/env.dart';
import '../../../core/helpers/helper_method.dart';
import '../../../core/service/audio_file_picker_service.dart';

class LiveStreamProvider with ChangeNotifier{
   TextEditingController audioFileController=TextEditingController();

  late AudioPlayer _audioPlayer;
  late RtcEngine _engine;
  bool _localUserJoined = false;
  final List<int> _remoteUids = <int>[];
   bool _isPlaying = false;
   bool _muted = false;
   String _audioFilePath = "";
   bool _showUI = false;
   bool _isPaused = false;

  RtcEngine get engine=>_engine;
  bool get localUserJoined=>_localUserJoined;
  List<int> get remoteUids=>_remoteUids;
  bool get isPlaying=>_isPlaying;
  bool get muted=>_muted;
  String get audioFilePath=> _audioFilePath;
  bool get showUI=>_showUI;
  bool get isPaused=> _isPaused;
  AudioPlayer get audioPlayer=>_audioPlayer;


  void onSwitchCamera() {
    _engine.switchCamera();
    notifyListeners();
  }

  void onToggleMute() {
    _muted = !_muted;
    _engine.muteLocalAudioStream(_muted);
    notifyListeners();
  }

   void toggleUI() {
     _showUI = !_showUI;
     notifyListeners();
   }


  void pickAudioFile() async {
    String? path = await AudioFilePickerService.pickedFile();
    if(path !=null){
      _audioFilePath = path;
      kPrint("Audio File Path: $_audioFilePath");
      audioFileController.text = _convertAudioFileName();
      notifyListeners();
    }
  }

   String _convertAudioFileName() {
     if (_audioFilePath.isNotEmpty) {
      return _audioFilePath.split('/').last;
     }
     return '';
   }


   void initAudioPlayer() {
     _audioPlayer = AudioPlayer();
   }


   Future<void> playAudio() async {
    notifyListeners();
     final path = _audioFilePath;
     if (path.isEmpty) return;

     try {
       if (_isPaused) {
         await _engine.resumeAudioMixing();
         _isPaused = false;
         notifyListeners();
       } else {
         await _engine.startAudioMixing(filePath: path, loopback: false, cycle: 1);
       }
       _isPlaying = true;
       notifyListeners();
     } catch (e) {
       kPrint("Error playing/resuming audio mixing: $e");
     }
   }


   Future<void> stopAudio() async {
     await _engine.stopAudioMixing();
     _isPlaying = false;
     _isPaused=false;
     notifyListeners();
   }

   Future<void> pauseAudio() async {
     await _engine.pauseAudioMixing();
     _isPaused = true;
     _isPlaying = false;
     notifyListeners();
   }






   Future<void> initAgora({ required bool isBroadcaster,required String channelName}) async {
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
         role:isBroadcaster?
         ClientRoleType.clientRoleBroadcaster
             :ClientRoleType.clientRoleAudience
     );

     if(isBroadcaster){
       try{
         await _engine.startPreview();
       }catch(e){
         kPrint(e.toString());
       }
     }

     _setupEventHandlers();

     await _engine.joinChannel(
       token: kToken,
       channelId: channelName,
       uid:isBroadcaster?0:0,
       options: ChannelMediaOptions(
         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
         clientRoleType:isBroadcaster?
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
           _localUserJoined=true;
           notifyListeners();
           debugPrint("Local user ${connection.localUid} joined");
         },
         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {

           if (!_remoteUids.contains(remoteUid)) {
             _remoteUids.add(remoteUid);
             notifyListeners();
           }

           debugPrint("Remote user $remoteUid joined");
         },
         onUserOffline: (
             RtcConnection connection,
             int remoteUid,
             UserOfflineReasonType reason,
             ) {

           _remoteUids.remove(remoteUid);
          notifyListeners();
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



   void endLiveStream(BuildContext context) async {
     await _engine.leaveChannel();
     await _engine.release();
     notifyListeners();
       Navigator.pop(context);
   }


   void disposeEngine() {
     _engine.leaveChannel();
     _engine.release();
     _localUserJoined = false;
     _remoteUids.clear();
     _audioPlayer.dispose();
     _audioFilePath = "";
     _isPlaying = false;
     _isPaused = false;
     _showUI = false;
     _muted = false;
   }


   void clearAudioFilePath() {
     _audioFilePath = "";
     notifyListeners();
   }



}