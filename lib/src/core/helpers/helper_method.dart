
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

kPrint(dynamic text){
if (kDebugMode) {
  print(text);
}
}


void kHideKeyboard(){
  FocusManager.instance.primaryFocus?.unfocus();
}