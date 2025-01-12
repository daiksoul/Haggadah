import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:haggah/bible/struct.dart';

SpeedDialChild LabeledSpeedDialChild({required String label, void Function()? onTap, required Icon icon, Color? backgroundColor, Color? foregroundColor = Colors.white}){
  return SpeedDialChild(
    elevation: 1.0,
    onTap: onTap,
    labelWidget: Container(
      decoration: BoxDecoration(
        color: backgroundColor??HexColor('ff81c784'),
        borderRadius: BorderRadius.circular(30)
      ),
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: foregroundColor),),
            const SizedBox(width: 6,),
            icon
          ],
        ),
      ),
    )
  );
}