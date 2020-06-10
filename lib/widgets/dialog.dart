import 'package:flutter/material.dart';

class Dialog {
  final String _title;
  final String _message;
  final Map<String, Function> _actions;

  Dialog(this._title, this._message, [this._actions]);

  Future<bool> show(BuildContext context) {
    var actions = [
      FlatButton(
        child: const Text('Okay'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ];

    if (this._actions != null) {
      actions = [];
      this._actions.forEach(
            (key, action) => {
              actions.add(
                FlatButton(
                  child: Text(key),
                  onPressed: action,
                ),
              ),
            },
          );
    }

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_title),
        content: Text(_message),
        actions: actions,
      ),
    );
  }
}
