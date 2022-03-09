import 'package:biolensback/src/app_landing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  configureApp();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());

  //For Navigation bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarColor: Color.fromARGB(0, 0, 0, 0),
  ));
}

enum Roles { loading, logout, university, admin }

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(child: Text('Error sync')));
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return AppLanding();
        }
        // Otherwise, show something whilst waiting for initialization to complete
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        );
      },
    );
  }
}

class RouteArgs {
  final Object? arguments;
  final String? parameter;

  RouteArgs({this.arguments, this.parameter});
}
