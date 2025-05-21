part of 'live_stream_bloc.dart';

abstract class LiveStreamEvent extends Equatable {
  const LiveStreamEvent();

  @override
  List<Object> get props => [];
}

class InitializeStream extends LiveStreamEvent {
  final bool isBroadcaster;
  final String channelName;

  const InitializeStream({required this.isBroadcaster, required this.channelName});

  @override
  List<Object> get props => [isBroadcaster, channelName];
}

class ToggleMute extends LiveStreamEvent {}

class SwitchCamera extends LiveStreamEvent {}

class PickAudioFile extends LiveStreamEvent {}

class PlayAudio extends LiveStreamEvent {}

class StopAudio extends LiveStreamEvent {}

class EndStream extends LiveStreamEvent {}

class ToggleUI extends LiveStreamEvent {}