
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rrk_stream_app/src/features/live_streaming/provider/live_stream_provider.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/widgets/audio_player_widget.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/widgets/live_control_buttons.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/widgets/video_preview_widget.dart';

import '../widgets/live_appbar.dart';

class LiveStreamingPage extends StatefulWidget {
  final bool isBroadCaster;
  final String channelName;
  const LiveStreamingPage({super.key, required this.isBroadCaster, required this.channelName,});

  @override
  State<LiveStreamingPage> createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage> {
  late LiveStreamProvider _streamProvider;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _streamProvider = Provider.of<LiveStreamProvider>(context, listen: false);
      _streamProvider.initAgora(
        isBroadcaster: widget.isBroadCaster,
        channelName: widget.channelName,
      );
      _streamProvider.initAudioPlayer();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _streamProvider.disposeEngine();
    _initialized = false;
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
        title: Consumer<LiveStreamProvider>(builder: (_,streamProvider,child){
          return  streamProvider.showUI?
          SizedBox.shrink():
          LiveAppbar(streamProvider: streamProvider);
        }),
      ),
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: Consumer<LiveStreamProvider>(
          builder: (_,streamProvider,child){
           return GestureDetector(
             onTap: (){
               streamProvider.toggleUI();
             },
             child: Stack(
               alignment: Alignment.bottomCenter,
               children: [
                 VideoPreviewWidget(
                     isBroadCaster: widget.isBroadCaster,
                     channelName: widget.channelName,
                 ),
                  if(! streamProvider.showUI)...[
                    AudioPlayerWidget(),
                    LiveControlButtons(liveStreamProvider: streamProvider)
                  ]

               ],
             ),
           );
          }
      )

    );
  }
}
