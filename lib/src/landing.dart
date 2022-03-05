import 'package:biolensback/shelf.dart';
import 'package:biolensback/src/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

enum Roles { admin, university }

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return SignInPage();
          }
          Future<DocumentSnapshot<Object?>> futureUser = FirebaseFirestore
              .instance
              .collection("users")
              .doc(user.uid)
              .get();

          return FutureBuilder<DocumentSnapshot<Object?>>(
              future: futureUser,
              builder: (context, snapshotUser) {
                if (snapshotUser.connectionState == ConnectionState.done) {
                  Map userMap = snapshotUser.data!.data() as Map;

                  Roles role = Roles.values.firstWhere((role) {
                    return role.toString() == "Roles.${userMap["role"]}";
                  });

                  switch (role) {
                    case Roles.admin:
                      return StreamProduct();
                    case Roles.university:
                      return UniversityHomepage(
                        university: userMap["university"],
                      );
                  }
                }
                return CupertinoPageScaffold(
                  child: Center(
                    child: CupertinoActivityIndicator(),
                  ),
                );
              });
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          // // Debug web only
          // final user = FirebaseAuth.instance.currentUser;
          // if (user == null) {
          //   return SignInPage();
          // }
          // return StreamProduct();
          return CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        } else {
          return CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }
      },
    );
  }
}
