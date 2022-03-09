import 'package:biolensback/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLanding extends StatefulWidget {
  const AppLanding({Key? key}) : super(key: key);

  @override
  State<AppLanding> createState() => _AppLandingState();
}

class _AppLandingState extends State<AppLanding> {
  Roles _roles = Roles.loading;
  String? _university;

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        setState(() => _roles = Roles.logout);
        return;
      }

      FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get()
          .then((value) => setState(() {
                _roles = Roles.values.firstWhere(
                    (role) => role.name == (value.data()!)["role"],
                    orElse: () => Roles.logout);
                _university = (value.data()!)["university"];
              }));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Material(
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
            '/': (context) => _roles == Roles.loading
                ? CupertinoPageScaffold(
                    child: Center(child: CupertinoActivityIndicator()))
                : _roles == Roles.admin
                    ? StreamProduct()
                    : _roles == Roles.university && _university != null
                        ? ManagementCenterUser(university: _university!)
                        : SignInPage(),
            '/add': (context) => AddProduct(),
            '/viewer': (context) => ProductViewer(),
            '/university': (context) => ManagementCenterAdmin(),
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
                page = _roles == Roles.loading
                    ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: CupertinoColors.darkBackgroundGray,
                        child: Center(child: CupertinoActivityIndicator()))
                    : _roles == Roles.admin
                        ? StreamProduct()
                        : _roles == Roles.university && _university != null
                            ? ManagementCenterUser(university: _university!)
                            : SignInPage();
            }

            return CupertinoPageRoute(
                builder: (BuildContext context) => page,
                settings: RouteSettings(
                  arguments: arguments,
                  name: settings.name,
                ));
          },
        ),
      ),
    );
  }
}
