import 'package:flutter/material.dart';

class NoRecords extends StatefulWidget {
  final double availableHeight;
  NoRecords(this.availableHeight, {Key key}) : super(key: key);

  @override
  _NoRecordsState createState() => _NoRecordsState();
}

class _NoRecordsState extends State<NoRecords> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 100),
      height: widget.availableHeight != null ? widget.availableHeight : double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Image.asset(
            'assets/images/arrow-2.png',
            color: Theme.of(context).primaryColor,
            height: 100,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text('Click the '),
              Text(
                '+ ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Text('button'),
            ],
          ),
          const Text('to add your first '),
          const Text('record'),
        ],
      ),
    );
  }
}
