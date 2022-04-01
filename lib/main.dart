import 'package:biolensback/src/app_landing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'config/configure_nonweb.dart'
    if (dart.library.html) 'config/configure_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';

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

enum Roles { loading, logout, university, admin, editor }

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
      // On initialise FlutterFire :
      future: _initialization,
      builder: (context, snapshot) {
        // Si erreurs
        if (snapshot.hasError) {
          return Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(child: Text('Error sync')));
        }

        // On affiche le landing
        if (snapshot.connectionState == ConnectionState.done) {
          return AppLanding();
        }

        // Temps de chargement
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
