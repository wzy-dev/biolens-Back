import 'package:biolensback/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum RequestStates { sent, treatment, done }
enum RequestTypes { add, edit }

class ManagementCenterUser extends StatelessWidget {
  const ManagementCenterUser({Key? key, required this.university})
      : super(key: key);

  final String university;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot<Object?>> requests = FirebaseFirestore.instance
        .collection("requests")
        .where("university", isEqualTo: this.university)
        .orderBy("editedAt", descending: true)
        .limit(3)
        .snapshots();

    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar.draw(
        context: context,
        middle: CustomNavigationBar.drawLogo(context),
        trailingList: [
          HeaderItem(
              label: "A propos",
              action: () => Navigator.of(context).pushNamed('/about')),
          HeaderItem(
              label: "Se déconnecter",
              action: () => FirebaseAuth.instance.signOut(),
              isDestructiveAction: true),
        ],
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 30, top: 25, right: 30, bottom: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Mes dernières requêtes :".toUpperCase(),
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: requests,
                        builder: (context, snapshotRequests) {
                          if (snapshotRequests.connectionState ==
                              ConnectionState.active) {
                            List<QueryDocumentSnapshot<Object?>> requestsList =
                                snapshotRequests.data?.docs ?? [];

                            List<Widget>? children = requestsList.map((e) {
                              Map data = e.data() as Map;

                              return RequestItem(
                                data: data,
                                requestId: e.id,
                              );
                            }).toList();

                            if (children.length == 0) children = null;

                            return Column(
                              children: children != null
                                  ? [
                                      ...children,
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 30),
                                        child: Center(
                                          child: CupertinoButton(
                                            padding: const EdgeInsets.all(0),
                                            child: Text(
                                                "Voir toutes mes requêtes"),
                                            onPressed: () =>
                                                Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                builder: (context) =>
                                                    RequestsDisplayer(
                                                        university: university),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]
                                  : [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 40),
                                        child: Text(
                                          "Vous n'avez encore soumis aucune requête",
                                          style: TextStyle(
                                              color:
                                                  CupertinoColors.systemGrey2),
                                        ),
                                      )
                                    ],
                            );
                          }

                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 40),
                              child: CupertinoActivityIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                    Column(
                      children: [
                        ManagementButton(
                          target:
                              RequestAddProduct(university: this.university),
                          lightColor: Color.fromRGBO(134, 219, 224, 1),
                          darkColor: Color.fromRGBO(109, 177, 181, 1),
                          textColor: Color.fromARGB(255, 40, 65, 67),
                          icon: Icon(
                            Icons.add_rounded,
                            color: Color.fromARGB(255, 40, 65, 67),
                            size: 45,
                          ),
                          label: "Demander l'ajout de produits",
                        ),
                        SizedBox(height: 20),
                        ManagementButton(
                          target:
                              RequestEditProduct(university: this.university),
                          lightColor: Color.fromRGBO(237, 190, 59, 1),
                          darkColor: Color.fromRGBO(184, 147, 46, 1),
                          textColor: Color.fromARGB(255, 99, 79, 25),
                          icon: Icon(
                            Icons.edit_rounded,
                            color: Color.fromARGB(255, 99, 79, 25),
                            size: 30,
                          ),
                          label: "Demander la modification d'un produit",
                        ),
                        SizedBox(height: 20),
                        ManagementButton(
                          target:
                              TechnicalPlatform(university: this.university),
                          lightColor: Color.fromARGB(255, 166, 181, 237),
                          darkColor: Color.fromRGBO(121, 143, 219, 1),
                          textColor: Color.fromARGB(255, 70, 76, 99),
                          icon: Icon(
                            Icons.dashboard_rounded,
                            color: Color.fromARGB(255, 70, 76, 99),
                            size: 30,
                          ),
                          label: "Personnaliser mon plateau technique",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RequestItem extends StatelessWidget {
  const RequestItem({
    Key? key,
    required this.requestId,
    required this.data,
    this.admin = false,
  }) : super(key: key);

  final String requestId;
  final Map data;
  final bool admin;

  Icon _drawRequestIcon(String state) {
    switch (
        RequestStates.values.firstWhere((element) => element.name == state)) {
      case RequestStates.sent:
        return Icon(
          CupertinoIcons.envelope_circle,
          color: CupertinoColors.systemGrey3,
          size: 35,
        );
      case RequestStates.treatment:
        return Icon(
          Icons.account_circle_outlined,
          color: CupertinoColors.activeBlue,
          size: 35,
        );
      case RequestStates.done:
        return Icon(
          Icons.check_circle_outline_rounded,
          color: CupertinoColors.activeGreen,
          size: 35,
        );
      default:
        return Icon(CupertinoIcons.exclamationmark_circle);
    }
  }

  String _drawRequestState(String state) {
    switch (
        RequestStates.values.firstWhere((element) => element.name == state)) {
      case RequestStates.sent:
        return "En attente de traitement";
      case RequestStates.treatment:
        return "En cours de traitement";
      case RequestStates.done:
        return "Demande traitée";
      default:
        return "Etat inconnu";
    }
  }

  String _writeRequestType(String type, {List<dynamic>? toAddList}) {
    switch (RequestTypes.values.firstWhere((element) => element.name == type)) {
      case RequestTypes.add:
        return "Demande d'ajout de ${toAddList != null ? "${toAddList.length} " : ""}produit${toAddList != null && toAddList.length > 1 ? "s" : ""}";
      case RequestTypes.edit:
        return "Signalement d'un produit";
      default:
        return "Autre demande";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => RequestInspector(
            request: requestId,
            admin: admin,
            university: data["university"],
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
      leading: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: _drawRequestIcon(data["state"]),
      ),
      title: Text(
        _writeRequestType(data["type"], toAddList: data["toAddList"]),
        style: CupertinoTheme.of(context).textTheme.textStyle,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_drawRequestState(data["state"]),
              style: TextStyle(color: CupertinoColors.systemGrey2)),
          Text(
              "Dernière modification le ${DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.fromMillisecondsSinceEpoch(data["editedAt"]))}",
              style: TextStyle(
                  color: CupertinoColors.systemGrey2,
                  fontSize: 12,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
