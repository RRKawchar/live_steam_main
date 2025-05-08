import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:rrk_stream_app/src/core/extensions/build_context_extension.dart';
import 'package:rrk_stream_app/src/core/helpers/helper_method.dart';
import 'package:rrk_stream_app/src/core/service/audio_file_picker_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/env/env.dart';

class LiveStreamingPage extends StatefulWidget {
  final bool isBroadcaster;
  final String channelName;
  const LiveStreamingPage({super.key, required this.isBroadcaster, required this.channelName});

  @override
  State<LiveStreamingPage> createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage> {
  late TextEditingController _audioFileController;
  late final AudioPlayer _audioPlayer;
  late final RtcEngine _engine;
  bool _localUserJoined = false;
  final List<int> _remoteUids = [];
  bool isPlaying = false;
  bool muted = false;
  String audioFilePath = "";
  bool _showUI = false;

  void _pickAudioFile() async {
    String? path = await AudioFilePickerService.pickedFile();
    setState(() {
      audioFilePath = path!;
    });
    kPrint("Audio File Path: $audioFilePath");

    _audioFileController.text = _convertAudioFileName();
  }

  String _convertAudioFileName() {
    String text = "";
    if (audioFilePath.isNotEmpty) {
      text = audioFilePath.split('/').last;
    }
    return text;
  }

  void initAudioPlayer() {
    _audioPlayer = AudioPlayer();
  }

  Future<void> playAudio() async {
    final path = audioFilePath;
    setState(() {});
    if (path.isEmpty) return;

    try {
      await _engine.startAudioMixing(filePath: path, loopback: false, cycle: 1);

      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      kPrint("Error starting audio mixing: $e");
    }
  }

  Future<void> stopAudio() async {
    await _engine.stopAudioMixing();
    setState(() {
      isPlaying = false;
    });
  }

  void onToggleMute() {
    setState(() {
      muted = !muted;
      _engine.muteLocalAudioStream(muted);
    });
  }

  void onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  void initState() {
    _audioFileController = TextEditingController();
    super.initState();
    _initAgora();
    initAudioPlayer();
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
      role:
          widget.isBroadcaster
              ? ClientRoleType.clientRoleBroadcaster
              : ClientRoleType.clientRoleAudience,
    );

    _setupEventHandlers();
    if (widget.isBroadcaster) {
      try {
        await _engine.startPreview();
      } catch (e) {
        kPrint(e.toString());
      }
    }
    await _engine.joinChannel(
      token: kToken,
      channelId: widget.channelName,
      uid: widget.isBroadcaster ? 0 : 0,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType:
            widget.isBroadcaster
                ? ClientRoleType.clientRoleBroadcaster
                : ClientRoleType.clientRoleAudience,
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
      ),
    );
  }

  void _setupEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _localUserJoined = true;
          });
          debugPrint("Local user ${connection.localUid} joined");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            if (!_remoteUids.contains(remoteUid)) {
              _remoteUids.add(remoteUid);
            }
          });
          debugPrint("Remote user $remoteUid joined");
        },
        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
          setState(() {
            _remoteUids.remove(remoteUid);
          });
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

  void _endLiveStream() async {
    await _engine.leaveChannel();
    await _engine.release();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    _audioPlayer.dispose();
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
        title: _showUI ? SizedBox.shrink() : _buildAppBarWidget(),
      ),
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showUI = !_showUI;
          });
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _buildVideoView(),
            _showUI
                ? SizedBox.shrink()
                : Positioned(bottom: 100, child: _audioPlayerWidget()),

            _showUI
                ? SizedBox.shrink()
                : Positioned(bottom: 40, child: _liveControlWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoView() {
    List<Widget> views = [];

    // Add local view for broadcaster
    if (widget.isBroadcaster && _localUserJoined) {
      views.add(
        AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: _engine,
            canvas: const VideoCanvas(uid: 0),
          ),
        ),
      );
    }

    // Add remote views
    for (var uid in _remoteUids) {
      views.add(
        AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: uid),
            connection: RtcConnection(channelId: widget.channelName),
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

  Widget _buildAppBarWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () {},
          label: Text(
            "${_remoteUids.length + (_localUserJoined ? 1 : 0)}",
           // "${_remoteUids.length + 1}",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          icon: Icon(Icons.person, color: Colors.grey, size: 25),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xFFF70000),
          ),
          child: Text(
            "Live",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _audioPlayerWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child:
          audioFilePath.isNotEmpty
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
                        setState(() {
                          audioFilePath = "";
                          _audioFileController.clear();
                        });
                      },
                      icon: Icon(Icons.clear, size: 28, color: Colors.red),
                    ),
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        controller: _audioFileController,
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          isPlaying
                              ? () {
                                stopAudio();
                              }
                              : () {
                                playAudio();
                              },
                      icon: Icon(
                        isPlaying
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
                onPressed: _pickAudioFile,
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
    );
  }

  Widget _liveControlWidget() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            onToggleMute();
          },
          icon: Icon(
            muted ? Icons.mic_off : Icons.mic,
            size: 30,
            color: Colors.blue,
          ),
        ),

        SizedBox(width: 10),

        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.red,
          child: IconButton(
            onPressed: _endLiveStream,
            icon: Icon(Icons.call_end, color: Colors.white),
          ),
        ),
        SizedBox(width: 10),

        IconButton(
          onPressed: () {
            onSwitchCamera();
          },
          icon: Icon(
            Icons.switch_camera_outlined,
            size: 30,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
