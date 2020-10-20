import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'misc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> _getFriendlyName(context) async {
  final _formKey = GlobalKey<FormState>();
  String _username;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter username'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  validator: (value) {
                    if (value == '') {
                      return 'Empty field';
                    }
                    _username = value;
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Submit'),
            onPressed: () {
              if (_formKey.currentState.validate()){
                Navigator.pop(context);
              }
            },
          ),
        ],
      );
    },
  );

  return _username;
}

class GatewayPage extends StatefulWidget {GatewayPage({Key key}) : super(key: key);
@override
_GatewayPageState createState() => _GatewayPageState();
}
class _GatewayPageState extends State<GatewayPage> {
  final _formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  String _username;

  void _enterGateway(String action) async {
    try {
      switch (action) {
        case 'Register':
          // none of these functions require error handling - this is handled by the main block

          await _getFriendlyName(context)
              .then((value) => _username = value);
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _email,
              password: _password
          );
          CollectionReference users = FirebaseFirestore.instance.collection('users');

          users
              .doc(userCredential.user.uid)
              .set({
            'balance': 0.0,
            'username' : _username,
            'pending': false,
            'pending_user': '',
            'pending_amount': 0.0,
            'debts': {}
          });

          break;
        case 'Login':
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _email,
              password: _password
          );
          break;
        default:
          throw Exception('Invalid action parameter in _enterGateway() call.');
      }
    } on FirebaseAuthException catch (e) {
      showDialogBox('FirebaseAuthException caught', e.toString(), context);
    } catch (e) {
      showDialogBox('Unhandled Exception', e.toString(), context);
    }
  }

  Widget loginForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            TextFormField(
              validator: (value) {
                if (value == '') {
                  return 'Empty field';
                }
                _email=value;
                return null;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            SizedBox(height:32),
            TextFormField(
              validator: (value) {
                if (value == '') {
                  return 'Empty field';
                }
                _password=value;
                return null;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height:64),
            FlatButton(
              child: Text('Register'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _enterGateway('Register');
                }
              },
            ),
            RaisedButton(
              child: Text('Login'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _enterGateway('Login');
                }
              },
            ),
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gateway'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            loginForm(),
          ],
        ),
      ),
    );
  }
}