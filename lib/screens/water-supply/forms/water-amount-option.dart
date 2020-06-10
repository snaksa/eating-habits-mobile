import 'package:flutter/material.dart';

class WaterAmountOption extends StatelessWidget {
  final Function onTap;
  final String empty;
  final String full;
  final bool selected;
  final String text;

  WaterAmountOption({this.empty, this.full, this.onTap, this.selected, this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            Image.asset(
              selected ? this.full : this.empty,
              height: 100,
            ),
            Text(this.text),
          ],
        ),
      ),
    );
  }
}
