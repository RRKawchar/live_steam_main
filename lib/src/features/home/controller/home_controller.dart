import 'package:get/get.dart';

class HomeController extends GetxController{
  late bool isBroadcaster;
  String? channelName;

  void setData({required bool isBroadcaster,required String channelName}){
    this.isBroadcaster=isBroadcaster;
    this.channelName=channelName;
  }


}