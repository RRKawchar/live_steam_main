import 'package:flutter/cupertino.dart';

extension BuildContextExtension on BuildContext{

  double get screenHeight => MediaQuery.of(this).size.height;

  double get screenWidth => MediaQuery.of(this).size.width;

  Size get screenSize => MediaQuery.of(this).size;
}