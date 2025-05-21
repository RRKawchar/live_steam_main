import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rrk_stream_app/src/core/env/env.dart';
import 'package:rrk_stream_app/src/core/service/audio_file_picker_service.dart';

part 'live_stream_event.dart';
part 'live_stream_state.dart';

class LiveStreamBloc extends Bloc<LiveStreamEvent, LiveStreamState> {
  late final RtcEngine _engine;
  late final AudioPlayer _audioPlayer;
  final String channelName;
  final bool isBroadcaster;


  RtcEngine get engine => _engine;

  LiveStreamBloc({
    required this.channelName,
    required this.isBroadcaster,
  }) : super(LiveStreamInitial()) {
    _audioPlayer = AudioPlayer();

    on<InitializeStream>(_onInitializeStream);
    on<ToggleMute>(_onToggleMute);
    on<SwitchCamera>(_onSwitchCamera);
    on<PickAudioFile>(_onPickAudioFile);
    on<PlayAudio>(_onPlayAudio);
    on<StopAudio>(_onStopAudio);
    on<EndStream>(_onEndStream);
    on<ToggleUI>(_onToggleUI);
  }

  Future<void> _onInitializeStream(
      InitializeStream event,
      Emitter<LiveStreamState> emit,
      ) async {
    try {
      emit(LiveStreamLoading());
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
        role: isBroadcaster
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
      );

      _setupEventHandlers(emit);

      if (isBroadcaster) {
        try {
          await _engine.startPreview();
        } catch (e) {
          emit(LiveStreamError(e.toString()));
        }
      }

      await _engine.joinChannel(
        token: kToken,
        channelId: channelName,
        uid: isBroadcaster ? 0 : 0,
        options: ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: isBroadcaster
              ? ClientRoleType.clientRoleBroadcaster
              : ClientRoleType.clientRoleAudience,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
        ),
      );

      emit(
        LiveStreamReady(
          isBroadcaster: isBroadcaster,
          localUserJoined: isBroadcaster,
          remoteUids: [],
          isPlaying: false,
          muted: false,
          audioFilePath: "",
          showUI: false,
        ),
      );
    } catch (e) {
      emit(LiveStreamError(e.toString()));
    }
  }

  void _setupEventHandlers(Emitter<LiveStreamState> emit) {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          if (state is LiveStreamReady) {
            emit((state as LiveStreamReady).copyWith(
              localUserJoined: true,
            ));
          }
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          if (state is LiveStreamReady) {
            final currentState = state as LiveStreamReady;
            if (!currentState.remoteUids.contains(remoteUid)) {
              emit(currentState.copyWith(
                remoteUids: List.from(currentState.remoteUids)..add(remoteUid),
              ));
            }
          }
        },
        onUserOffline: (
            RtcConnection connection,
            int remoteUid,
            UserOfflineReasonType reason,
            ) {
          if (state is LiveStreamReady) {
            final currentState = state as LiveStreamReady;
            emit(currentState.copyWith(
              remoteUids: List.from(currentState.remoteUids)..remove(remoteUid),
            ));
          }
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

  Future<void> _onToggleMute(
      ToggleMute event,
      Emitter<LiveStreamState> emit,
      ) async {
    if (state is LiveStreamReady) {
      final currentState = state as LiveStreamReady;
      await _engine.muteLocalAudioStream(!currentState.muted);
      emit(currentState.copyWith(muted: !currentState.muted));
    }
  }

  Future<void> _onSwitchCamera(
      SwitchCamera event,
      Emitter<LiveStreamState> emit,
      ) async {
    await _engine.switchCamera();
  }

  Future<void> _onPickAudioFile(
      PickAudioFile event,
      Emitter<LiveStreamState> emit,
      ) async {
    if (state is LiveStreamReady) {
      final currentState = state as LiveStreamReady;
      final path = await AudioFilePickerService.pickedFile();
      if (path != null) {
        emit(currentState.copyWith(audioFilePath: path));
      }
    }
  }

  Future<void> _onPlayAudio(
      PlayAudio event,
      Emitter<LiveStreamState> emit,
      ) async {
    if (state is LiveStreamReady) {
      final currentState = state as LiveStreamReady;
      if (currentState.audioFilePath.isEmpty) return;

      try {
        await _engine.startAudioMixing(
          filePath: currentState.audioFilePath,
          loopback: false,
          cycle: 1,
        );
        emit(currentState.copyWith(isPlaying: true));
      } catch (e) {
        emit(LiveStreamError("Error starting audio mixing: $e"));
      }
    }
  }

  Future<void> _onStopAudio(
      StopAudio event,
      Emitter<LiveStreamState> emit,
      ) async {
    if (state is LiveStreamReady) {
      final currentState = state as LiveStreamReady;
      await _engine.stopAudioMixing();
      emit(currentState.copyWith(isPlaying: false));
    }
  }

  Future<void> _onEndStream(
      EndStream event,
      Emitter<LiveStreamState> emit,
      ) async {
    await _engine.leaveChannel();
    await _engine.release();
    await _audioPlayer.dispose();
  }

  Future<void> _onToggleUI(
      ToggleUI event,
      Emitter<LiveStreamState> emit,
      ) async {
    if (state is LiveStreamReady) {
      final currentState = state as LiveStreamReady;
      emit(currentState.copyWith(showUI: !currentState.showUI));
    }
  }

  @override
  Future<void> close() {
    _engine.leaveChannel();
    _engine.release();
    _audioPlayer.dispose();
    return super.close();
  }
}