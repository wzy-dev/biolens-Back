import 'package:biolensback/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserModifier extends StatelessWidget {
  const UserModifier({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  Widget build(BuildContext context) {
    final Future<DocumentSnapshot> _futureUser =
        FirebaseFirestore.instance.collection("users").doc(userId).get();
    final Future<QuerySnapshot> _futureListUniversities =
        FirebaseFirestore.instance.collection("universities").get();

    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar.draw(
          context: context, middle: Text("Gestion des utilisateurs")),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: FutureBuilder(
            future: Future.wait([_futureUser, _futureListUniversities]),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done ||
                  snapshot.data == null) return CupertinoActivityIndicator();
              DocumentSnapshot user = (snapshot.data as List)[0];
              List<QueryDocumentSnapshot> listUniversities =
                  (snapshot.data as List)[1].docs;

              Map<String, dynamic> userData =
                  user.data() as Map<String, dynamic>;
              userData["id"] = user.id;
              return Column(
                children: [
                  // UserContainer(
                  //   enabled: userData["enabled"],
                  //   email: userData["email"],
                  //   role: userData["role"],
                  //   universityId: userData["university"],
                  //   userId: user.id,
                  //   listUniversities: listUniversities,
                  // ),
                  UserForm(
                    listUniversities: listUniversities,
                    userData: userData,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
