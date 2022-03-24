import 'package:biolensback/shelf.dart';
import 'package:biolensback/src/university/universities_manager.dart';
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
      navigationBar: CustomNavigationBar.draw(
        context: context,
        middle: Text(
          "Centre de gestion",
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
              child: ListView(
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
                  StreamBuilder<QuerySnapshot>(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                            color: CupertinoColors.systemGrey2),
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
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ManagementButton(
                          target: RequestsDisplayer(
                            state: RequestStates.treatment,
                            admin: true,
                          ),
                          lightColor: Color.fromARGB(255, 166, 181, 237),
                          darkColor: Color.fromRGBO(121, 143, 219, 1),
                          textColor: Color.fromARGB(255, 70, 76, 99),
                          icon: Icon(
                            Icons.account_circle,
                            color: Color.fromARGB(255, 70, 76, 99),
                            size: 30,
                          ),
                          label: "Voir les requêtes en cours de traitement",
                        ),
                        SizedBox(height: 20),
                        ManagementButton(
                          target: RequestsDisplayer(
                            state: RequestStates.done,
                            admin: true,
                          ),
                          lightColor: Color.fromRGBO(134, 219, 224, 1),
                          darkColor: Color.fromRGBO(109, 177, 181, 1),
                          textColor: Color.fromARGB(255, 40, 65, 67),
                          icon: Icon(
                            Icons.check_circle_rounded,
                            color: Color.fromARGB(255, 40, 65, 67),
                            size: 30,
                          ),
                          label: "Voir les requêtes traitées",
                        ),
                        SizedBox(height: 20),
                        ManagementButton(
                          target: TechnicalPlatform(),
                          lightColor: Color.fromRGBO(237, 190, 59, 1),
                          darkColor: Color.fromRGBO(184, 147, 46, 1),
                          textColor: Color.fromARGB(255, 99, 79, 25),
                          icon: Icon(
                            Icons.dashboard_rounded,
                            color: Color.fromARGB(255, 99, 79, 25),
                            size: 30,
                          ),
                          label: "Modifier un plateau technique",
                        ),
                        SizedBox(height: 20),
                        ManagementButton(
                          target: UniversitiesManager(),
                          lightColor: Color.fromRGBO(179, 203, 255, 1),
                          darkColor: Color.fromRGBO(118, 150, 219, 1),
                          textColor: Color.fromARGB(221, 46, 40, 25),
                          icon: Icon(
                            Icons.school,
                            color: Color.fromARGB(221, 46, 40, 25),
                            size: 30,
                          ),
                          label: "Gérer les universités",
                        ),
                      ],
                    ),
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

class ManagementButton extends StatelessWidget {
  const ManagementButton({
    Key? key,
    required this.target,
    required this.label,
    required this.icon,
    required this.darkColor,
    required this.lightColor,
    required this.textColor,
  }) : super(key: key);

  final Widget target;
  final String label;
  final Icon icon;
  final Color darkColor;
  final Color lightColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: () => Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => target,
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(children: [
          Container(
            height: 60,
            width: 75,
            decoration: BoxDecoration(color: darkColor),
            child: Center(
              child: icon,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            left: 65,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      letterSpacing: 1.5,
                      color: textColor,
                    ),
                  )),
            ),
          ),
        ]),
      ),
    );
  }
}
