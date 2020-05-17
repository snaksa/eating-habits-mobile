import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../exceptions/http_exception.dart';
import '../../providers/auth.dart';
import '../../widgets/drawer.dart';
import '../../widgets/screens/weight-balance.dart';
import '../../widgets/dialog.dart' as CustomDialog;

class AuthScreen extends StatefulWidget {
  static const String routeName = '/login';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _showErrorDialog(String message) {
    CustomDialog.Dialog('An Error Occurred!', message).show(context);
  }

  void _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    try {
      await Provider.of<Auth>(context, listen: false).login(
        _authData['email'],
        _authData['password'],
      );

      Navigator.of(context).pushReplacementNamed(WeightBalanceScreen.routeName);
    } on HttpException catch (error) {
      _showErrorDialog(error.message);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(
        'Login',
        style: TextStyle(color: Colors.white),
      ),
    );

    return Scaffold(
      appBar: appBar,
      drawer: AppDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 0,
            left: 10,
            right: 10,
            bottom: 0,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Invalid email!';
                      }

                      return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSaved: (value) {
                      _authData['password'] = value;
                    },
                  ),
                  RaisedButton(
                    onPressed: _submit,
                    child: Text('Login'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
