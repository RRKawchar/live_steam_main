import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rrk_stream_app/src/features/live_streaming/provider/live_stream_provider.dart';

class LiveAppbar extends StatelessWidget {
  final LiveStreamProvider streamProvider;
  const LiveAppbar({super.key, required this.streamProvider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Consumer<LiveStreamProvider>(builder: (_,strP,child){
          return TextButton.icon(
            onPressed: () {},
            label: Text(
              "${strP.remoteUids.length + (strP.localUserJoined ? 1 : 0)}",
              // "${_remoteUids.length + 1}",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            icon: Icon(Icons.person, color: Colors.grey, size: 25),
          );
        }),

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
}
