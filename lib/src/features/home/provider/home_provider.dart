import 'package:flutter/cupertino.dart';

class HomeProvider with ChangeNotifier{

  late bool isBroadcaster;
  String? channelName;

  void setData({required bool isBroadcaster,required String channelName}){
    this.isBroadcaster=isBroadcaster;
    this.channelName=channelName;
    notifyListeners();
  }

}