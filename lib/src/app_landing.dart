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
                _roles = Roles.values.firstWhere(
                    (role) => role.name == (value.data()!)["role"],
                    orElse: () => Roles.logout);
                _university = (value.data()!)["university"];
              }));
    });
    super.initState();
  }

  // On retourne un widget en fonction du role de l'utilisateur
  Widget _permissionHandler({
    required Roles role,
    Widget? ifAdmin,
    Widget? ifUniversity,
  }) {
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
      default:
        return SignInPage();
    }
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
            '/': (context) => _permissionHandler(
                  role: _roles,
                  ifAdmin: AdminHomepage(),
                  ifUniversity: _university != null
                      ? ManagementCenterUser(university: _university!)
                      : null,
                ),
            '/add': (context) =>
                _permissionHandler(role: _roles, ifAdmin: AddProduct()),
            '/viewer': (context) =>
                _permissionHandler(role: _roles, ifAdmin: ProductInspector()),
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
            final arguments = RouteArgs(
                arguments: settings.arguments,
                parameter: settings.name!.split("/")[2]);
            Widget page;

            switch ("/" + path) {
              case "/viewer":
                page = _permissionHandler(
                  role: _roles,
                  ifAdmin: ProductInspector(),
                );
                break;
              default:
                page = _permissionHandler(
                  role: _roles,
                  ifAdmin: AdminHomepage(),
                  ifUniversity: _university != null
                      ? ManagementCenterUser(university: _university!)
                      : null,
                );
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
