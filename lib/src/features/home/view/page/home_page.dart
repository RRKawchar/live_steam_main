
import 'package:rrk_stream_app/src/core/core_export/home_export_path.dart';
import 'package:rrk_stream_app/src/features/live_streaming/view/page/live_stream_page_two.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   late TextEditingController _channelName;

  @override
  void initState() {
    _channelName=TextEditingController();
    super.initState();
  }


  @override
  void dispose() {
  _channelName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000619),
              Color(0xFF01445E),
              Color(0xFF002035),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Live Stream',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                KTextField(
                  hintText: "Enter channel name",
                  controller: _channelName,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    KCustomButton(
                        text: "Go Live",
                        backgroundColor:Colors.black54,
                        onPressed: ()=> _onLive(isBroadcaster: true)
                    ),

                    KCustomButton(
                      text: "Join Live",
                      backgroundColor: Colors.blueAccent,
                      onPressed: ()=> _onLive(isBroadcaster: false)
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );

  }



  Future<void> _onLive({required bool isBroadcaster})async{
    await [Permission.camera, Permission.microphone].request();
    if(_channelName.text.isEmpty){
        EasyLoading.showToast("Channel Name is required!");
        return;
    }
    // Navigator.push(context, MaterialPageRoute(builder: (_)=>LiveStreamingPage(
    //     isBroadCaster: isBroadcaster,
    //     channelName: _channelName.text.trim(),
    // )));

    Navigator.push(context, MaterialPageRoute(builder: (_)=>LiveStreamingPage(
      isBroadcaster: isBroadcaster,
      channelName: _channelName.text.trim(),
    )));
  }
}
