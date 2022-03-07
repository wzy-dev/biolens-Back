import 'package:biolensback/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManagementCenterAdmin extends StatefulWidget {
  const ManagementCenterAdmin({Key? key}) : super(key: key);

  @override
  State<ManagementCenterAdmin> createState() => _ManagementCenterAdminState();
}

class _ManagementCenterAdminState extends State<ManagementCenterAdmin> {
  final Stream<QuerySnapshot<Object?>> requests = FirebaseFirestore.instance
      .collection("requests")
      .where("state", isEqualTo: RequestStates.sent.name)
      .orderBy("editedAt")
      .snapshots();

  int _nbRequests = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Text("Centre de gestion"),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      "$_nbRequests requête${_nbRequests != 1 ? "s" : ""} en attente :"
                          .toUpperCase(),
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: requests,
                      builder: (context, snapshotRequests) {
                        if (snapshotRequests.connectionState ==
                            ConnectionState.active) {
                          List<QueryDocumentSnapshot<Object?>> requestsList =
                              snapshotRequests.data?.docs ?? [];

                          Future.delayed(
                            Duration.zero,
                            () => setState(
                              () {
                                _nbRequests = requestsList.length;
                              },
                            ),
                          );

                          List<Widget>? children = requestsList.map((e) {
                            Map data = e.data() as Map;
                            return RequestItem(
                              data: data,
                              requestId: e.id,
                              admin: true,
                            );
                          }).toList();

                          if (children.length == 0) children = null;

                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: children != null
                                  ? children
                                  : [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 40),
                                        child: Text(
                                          "Vous n'avez pas de requêtes en attente",
                                          style: TextStyle(
                                              color:
                                                  CupertinoColors.systemGrey2),
                                        ),
                                      )
                                    ],
                            ),
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
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 30,
                    runSpacing: 20,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => RequestsDisplayer(
                              state: RequestStates.treatment,
                              admin: true,
                            ),
                          ),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width > 900
                              ? MediaQuery.of(context).size.width / 2 - 45
                              : double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(children: [
                            Container(
                              height: 60,
                              width: 75,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(121, 143, 219, 1)),
                              child: Center(
                                  child: Icon(
                                CupertinoIcons.person_circle,
                                color: Color.fromARGB(255, 70, 76, 99),
                                size: 30,
                              )),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              left: 65,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 166, 181, 237),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Voir les requêtes en cours de traitement"
                                          .toUpperCase(),
                                      style: TextStyle(
                                        letterSpacing: 1.5,
                                        color: Color.fromARGB(255, 70, 76, 99),
                                      ),
                                    )),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => RequestsDisplayer(
                              state: RequestStates.done,
                              admin: true,
                            ),
                          ),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width > 900
                              ? MediaQuery.of(context).size.width / 2 - 45
                              : double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(children: [
                            Container(
                              height: 60,
                              width: 75,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(109, 177, 181, 1)),
                              child: Center(
                                  child: Icon(
                                CupertinoIcons.checkmark_alt_circle,
                                color: Color.fromARGB(255, 40, 65, 67),
                                size: 30,
                              )),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              left: 65,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(134, 219, 224, 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Voir les requêtes traitées"
                                          .toUpperCase(),
                                      style: TextStyle(
                                        letterSpacing: 1.5,
                                        color: Color.fromARGB(255, 40, 65, 67),
                                      ),
                                    )),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => TechnicalPlatform(),
                          ),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width > 900
                              ? MediaQuery.of(context).size.width / 2 - 45
                              : double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(children: [
                            Container(
                              height: 60,
                              width: 75,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(184, 147, 46, 1)),
                              child: Center(
                                  child: Icon(
                                Icons.dashboard_rounded,
                                color: Color.fromARGB(255, 99, 79, 25),
                                size: 30,
                              )),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              left: 65,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(237, 190, 59, 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Modifier un plateau technique"
                                          .toUpperCase(),
                                      style: TextStyle(
                                        letterSpacing: 1.5,
                                        color: Color.fromARGB(255, 99, 79, 25),
                                      ),
                                    )),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
