import 'package:flutter/material.dart';

class KCustomButton extends StatelessWidget {
  final String? text;
  final Color backgroundColor;
  final VoidCallback onPressed;
  const KCustomButton({super.key, this.text, required this.backgroundColor, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:backgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Text(text??"",style: TextStyle(
          fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold
      ),),
    );
  }
}

