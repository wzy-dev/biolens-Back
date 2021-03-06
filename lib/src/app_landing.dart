import 'package:biolensback/shelf.dart';
import 'package:biolensback/src/editor/editor_homepage.dart';
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
    // On initialise un listener sur l'état de l'utilisateur
    FirebaseAuth.instance.authStateChanges().listen((user) {
      // Si user == null on affiche un état déconnecté
      if (user == null) {
        setState(() => _roles = Roles.logout);
        return;
      }

      // Si user != null on assigne le role et l'université de l'utilisateur
      FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get()
          .then((value) => setState(() {
                setState(() {
                  _roles = Roles.values.firstWhere(
                      (role) => role.name == (value.data()!)["role"],
                      orElse: () => Roles.logout);
                  _university = (value.data()!)["university"];
                });
              }));
    });
    super.initState();
  }

  // On retourne un widget en fonction du role de l'utilisateur
  Widget _permissionHandler(
      {required Roles role,
      Widget? ifAdmin,
      Widget? ifUniversity,
      Widget? ifEditor}) {
    switch (role) {
      case Roles.loading:
        return CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()));
      case Roles.admin:
        if (ifAdmin != null) {
          return ifAdmin;
        }
        return SignInPage();
      case Roles.university:
        if (_university != null && ifUniversity != null) {
          return ifUniversity;
        }
        return SignInPage();
      case Roles.editor:
        if (ifEditor != null) {
          return ifEditor;
        }
        return SignInPage();
      default:
        return SignInPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _roles.name == Roles.loading.name
        ? Container(
            color: CupertinoColors.darkBackgroundGray,
            child: Center(
                child: CupertinoActivityIndicator(
              color: CupertinoColors.white,
            )))
        : GestureDetector(
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
                initialRoute: "/",
                routes: {
                  '/': (context) => _permissionHandler(
                        role: _roles,
                        ifAdmin: AdminHomepage(),
                        ifUniversity: _university != null
                            ? ManagementCenterUser(university: _university!)
                            : null,
                        ifEditor: EditorHomepage(),
                      ),
                  '/add': (context) => _permissionHandler(
                      role: _roles,
                      ifAdmin: AddProduct(),
                      ifEditor: AddProduct()),
                  '/viewer': (context) => _permissionHandler(
                        role: _roles,
                        ifAdmin: ProductInspector(),
                        ifEditor: ProductInspector(),
                      ),
                  '/universities': (context) => _permissionHandler(
                      role: _roles, ifAdmin: ManagementCenterAdmin()),
                  '/users': (context) =>
                      _permissionHandler(role: _roles, ifAdmin: UsersManager()),
                  '/about': (context) => Privacy(canPop: true),
                  '/privacy': (context) => Privacy(canPop: false)
                },
                onGenerateRoute: (settings) {
                  // En cas de lien avec un argument
                  final String path = settings.name!.split("/")[1];
                  final String? arguments = settings.name!.split("/")[2];
                  Widget page;

                  if (_roles == Roles.logout) {
                    return CupertinoPageRoute(
                      builder: (BuildContext context) => SignInPage(),
                      settings: RouteSettings(
                        name: "/",
                      ),
                    );
                  }

                  switch ("/" + path) {
                    case "/viewer":
                      page = _permissionHandler(
                        role: _roles,
                        ifAdmin: ProductInspector(),
                        ifEditor: ProductInspector(),
                      );
                      break;
                    default:
                      page = _permissionHandler(
                        role: _roles,
                        ifAdmin: AdminHomepage(),
                        ifUniversity: _university != null
                            ? ManagementCenterUser(university: _university!)
                            : null,
                        ifEditor: EditorHomepage(),
                      );
                  }

                  return CupertinoPageRoute(
                    builder: (BuildContext context) => page,
                    settings: RouteSettings(
                      arguments: arguments,
                      name: settings.name,
                    ),
                  );
                },
              ),
            ),
          );
  }
}
