import 'package:biolensback/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class RequestsDisplayer extends StatelessWidget {
  const RequestsDisplayer({Key? key, this.university, this.state, this.admin})
      : assert(
          university != null || state != null,
          "university and state can't both be null",
        ),
        super(key: key);

  final String? university;
  final RequestStates? state;
  final bool? admin;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot<Object?>> requests = this.university != null
        ? FirebaseFirestore.instance
            .collection("requests")
            .where("university", isEqualTo: this.university)
            .orderBy("editedAt", descending: true)
            .snapshots()
        : FirebaseFirestore.instance
            .collection("requests")
            .where("state", isEqualTo: RequestStates.values[state!.index].name)
            .orderBy("editedAt")
            .snapshots();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Text("Mes requêtes"),
        ),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 30, top: 25, right: 30, bottom: 20),
              child: StreamBuilder<QuerySnapshot>(
                stream: requests,
                builder: (context, snapshotRequests) {
                  if (snapshotRequests.connectionState ==
                      ConnectionState.active) {
                    List<QueryDocumentSnapshot<Object?>> requestsList =
                        snapshotRequests.data?.docs ?? [];

                    List<Widget>? children = requestsList.map<Widget>((e) {
                      Map data = e.data() as Map;
                      return RequestItem(
                        data: data,
                        requestId: e.id,
                        admin: admin ?? false,
                      );
                    }).toList();

                    if (children.length == 0) children = null;

                    return Column(
                      children: children != null
                          ? children
                          : [
                              Text(
                                "Vous n'avez actuellement aucune requête à afficher ici",
                                style: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle,
                              ),
                              CupertinoButton(
                                child: Text("Retourner au centre de gestion"),
                                onPressed: () => Navigator.of(context).pop(),
                              )
                            ],
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 40),
                      child: CupertinoActivityIndicator(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
