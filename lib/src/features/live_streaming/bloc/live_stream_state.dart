part of 'live_stream_bloc.dart';

abstract class LiveStreamState extends Equatable {
  const LiveStreamState();

  @override
  List<Object> get props => [];
}

class LiveStreamInitial extends LiveStreamState {}

class LiveStreamLoading extends LiveStreamState {}

class LiveStreamReady extends LiveStreamState {
  final bool isBroadcaster;
  final bool localUserJoined;
  final List<int> remoteUids;
  final bool isPlaying;
  final bool muted;
  final String audioFilePath;
  final bool showUI;

  const LiveStreamReady({
    required this.isBroadcaster,
    required this.localUserJoined,
    required this.remoteUids,
    required this.isPlaying,
    required this.muted,
    required this.audioFilePath,
    required this.showUI,
  });

  @override
  List<Object> get props => [
    isBroadcaster,
    localUserJoined,
    remoteUids,
    isPlaying,
    muted,
    audioFilePath,
    showUI,
  ];

  LiveStreamReady copyWith({
    bool? isBroadcaster,
    bool? localUserJoined,
    List<int>? remoteUids,
    bool? isPlaying,
    bool? muted,
    String? audioFilePath,
    bool? showUI,
  }) {
    return LiveStreamReady(
      isBroadcaster: isBroadcaster ?? this.isBroadcaster,
      localUserJoined: localUserJoined ?? this.localUserJoined,
      remoteUids: remoteUids ?? this.remoteUids,
      isPlaying: isPlaying ?? this.isPlaying,
      muted: muted ?? this.muted,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      showUI: showUI ?? this.showUI,
    );
  }
}

class LiveStreamError extends LiveStreamState {
  final String message;

  const LiveStreamError(this.message);

  @override
  List<Object> get props => [message];
}