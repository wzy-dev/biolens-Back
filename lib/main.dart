import 'package:biolensback/shelf.dart';
import 'package:biolensback/src/landing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Widget _firebaseConnect() {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return CupertinoPageScaffold(
              child: Center(child: Text('Error sync')));
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return LandingPage();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return CupertinoPageScaffold(
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return TestTextField();
    return Material(
      child: CupertinoApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('fr', 'FR')],
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              color: CupertinoDynamicColor.withBrightness(
                color: CupertinoColors.black,
                darkColor: CupertinoColors.white,
              ).resolveFrom(context),
            ),
          ),
        ),
        routes: {
          // '/about': (context) => About(),
          '/add': (context) => AddProduct(),
          '/viewer': (context) => ProductViewer(),
          '/about': (context) => Privacy(canPop: true),
          '/privacy': (context) => Privacy(canPop: false),
        },
        onGenerateRoute: (settings) {
          final String path = settings.name!.split("/")[1];
          final arguments = RouteArgs(
              arguments: settings.arguments,
              parameter: settings.name!.split("/")[2]);
          Widget page;

          switch ("/" + path) {
            case "/viewer":
              page = ProductViewer();
              break;
            default:
              page = LandingPage();
          }

          return CupertinoPageRoute(
              builder: (BuildContext context) => page,
              settings: RouteSettings(
                arguments: arguments,
                name: settings.name,
              ));
        },
        home: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: DefaultTextStyle(
            child: _firebaseConnect(),
            style: CupertinoTheme.of(context).textTheme.textStyle,
          ),
        ),
      ),
    );
  }
}

class RouteArgs {
  final Object? arguments;
  final String? parameter;

  RouteArgs({this.arguments, this.parameter});
}
