import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'register.dart';
import 'water-supply/water-supply.dart';
import '../exceptions/http_exception.dart';
import '../providers/auth.dart';
import '../widgets/drawer.dart';
import '../widgets/dialog.dart' as CustomDialog;

class AuthScreen extends StatefulWidget {
  static const String routeName = '/login';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var _passwordFieldFocus = FocusNode();

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
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Auth>(context, listen: false).login(
        _authData['email'],
        _authData['password'],
      );

      Navigator.of(context).pushReplacementNamed(WaterSupplyScreen.routeName);
    } on HttpException catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(error.message);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).primaryColor, Colors.blueAccent],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 0,
              left: 20,
              right: 20,
              bottom: 0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Image.asset('assets/images/logo.png'),
                      )),
                  Card(
                    elevation: 24,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration:
                                      const InputDecoration(labelText: 'Email'),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value.isEmpty || !value.contains('@')) {
                                      return 'Invalid email!';
                                    }

                                    return null;
                                  },
                                  onFieldSubmitted: (term) {
                                    FocusScope.of(context)
                                        .requestFocus(_passwordFieldFocus);
                                  },
                                  onSaved: (value) {
                                    _authData['email'] = value;
                                  },
                                ),
                                TextFormField(
                                  textInputAction: TextInputAction.done,
                                  focusNode: _passwordFieldFocus,
                                  decoration: const InputDecoration(
                                      labelText: 'Password'),
                                  obscureText: true,
                                  onSaved: (value) {
                                    _authData['password'] = value;
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                _isLoading
                                    ? CircularProgressIndicator()
                                    : RaisedButton(
                                        onPressed: _submit,
                                        child: Text(
                                          'Login',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        color: Colors.cyan,
                                      ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("You don't have an account? "),
                                GestureDetector(
                                  child: Text(
                                    "Register here",
                                    style: TextStyle(color: Colors.lightBlue),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pushReplacementNamed(
                                        RegisterScreen.routeName);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
