import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

SpeedDialChild labeledSpeedDialChild(
  BuildContext context, {
  required String label,
  void Function()? onTap,
  required Icon icon,
}) {
  return SpeedDialChild(
      elevation: 1.0,
      onTap: onTap,
      labelWidget: Container(
        decoration: BoxDecoration(
            color:
                Theme.of(context).floatingActionButtonTheme.backgroundColor ??
                    const Color(0xff81c784),
            borderRadius: BorderRadius.circular(30)),
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                    color: Theme.of(context)
                        .floatingActionButtonTheme
                        .foregroundColor),
              ),
              const SizedBox(
                width: 6,
              ),
              icon
            ],
          ),
        ),
      ));
}
