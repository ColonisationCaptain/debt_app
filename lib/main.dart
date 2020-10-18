import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomException implements Exception {
  String cause;
  CustomException(this.cause);
}

Future<void> _showDialogBox(String title, String message, BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      //title: 'Debt App',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primarySwatch: Colors.green,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.green,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      initialRoute: '/gateway',
      routes: {
        '/gateway': (context) => MyApp(),
        '/main': (context) => MainMenu(),
      },
    )
  );
}

class MyApp extends StatelessWidget {
  Widget messageScreen(String titleText, IconData icon, Color iconColour, String iconText) {
    return Scaffold(
        appBar: AppBar(
          title: Text(titleText),
        ),
        body: Center(
          child:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 64, color: iconColour),
            Text(iconText, textScaleFactor: 2.0),
          ]),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return FutureBuilder(
      // initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // check for errors
        if (snapshot.hasError) {
          return messageScreen('Firebase Error', Icons.error, Colors.orange, 'Error connecting to Firebase');
        }

        // once complete, show main screen
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            body: GatewayPage(title: 'Gateway'),
          );
        }

        // show loading screen while waiting for initialization to complete
        return messageScreen('Connecting to Firebase', Icons.refresh, Colors.green, 'Loading ...');
      },
    );
  }
}

class GatewayPage extends StatefulWidget {GatewayPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GatewayPageState createState() => _GatewayPageState();
}
class _GatewayPageState extends State<GatewayPage> {
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;

  String _username;
  String _password;

  void _enterGateway(String action) async {
    try {
      switch (action) {
        case 'Register':
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _username,
              password: _password
          );
          break;
        case 'Login':
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _username,
              password: _password
          );
          break;
        default:
          throw Exception('Invalid action parameter in _enterGateway() call.');
      }
      Navigator.pushReplacementNamed(context, '/main');
    } on FirebaseAuthException catch (e) {
      _showDialogBox('FirebaseAuthException caught', e.toString(), context);
    } catch (e) {
      _showDialogBox('Unhandled Exception', e.toString(), context);
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
                  return 'Field must be non-empty';
                }
                _username=value;
                return null;
              },
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              validator: (value) {
                if (value == '') {
                  return 'Field must be non-empty';
                }
                _password=value;
                return null;
              },
              decoration: InputDecoration(labelText: 'Password'),
            ),
            RaisedButton(
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
        title: Text(widget.title),
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

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        bottomNavigationBar: Container(
          // TODO: theme this according to the main app theme
          color: Colors.green,
          child: TabBar(
            indicatorColor: Colors.greenAccent,
            tabs: [
              Tab(text: 'DOGS', icon: Icon(Icons.favorite)),
              Tab(text: 'CATS', icon: Icon(Icons.music_note)),
              Tab(text: 'BIRDS', icon: Icon(Icons.search)),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('Debt App'),
          automaticallyImplyLeading: false,
        ),
        body: TabBarView(
          children: [
            Center(
              child: Text('DOGS')
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/gateway');
                },
                child: Text('Go back!'),
              ),
            ),
            Center(
              child: Text('BIRDS')
            ),
          ],
        ),
      ),
    );
  }
}
