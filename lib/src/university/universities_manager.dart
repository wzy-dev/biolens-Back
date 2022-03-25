import 'package:biolensback/src/main/custom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UniversitiesManager extends StatefulWidget {
  const UniversitiesManager({Key? key}) : super(key: key);

  @override
  State<UniversitiesManager> createState() => _UniversitiesManagerState();
}

class _UniversitiesManagerState extends State<UniversitiesManager> {
  final Stream<QuerySnapshot<Map<String, dynamic>>> _universities =
      FirebaseFirestore.instance
          .collection("universities")
          .orderBy("name")
          .snapshots();
  String? _expandedId;
  final TextEditingController _renameController = TextEditingController();
  final TextEditingController _toAddController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar.draw(
          context: context, middle: Text("Gestion des universités")),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _universities,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.active ||
                        snapshot.data == null)
                      return Center(
                        child: CupertinoActivityIndicator(),
                      );

                    return Column(
                        children: snapshot.data!.docs.map(
                      (university) {
                        Map<String, dynamic> data = university.data();
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            border: Border.all(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: Column(
                            children: [
                              CupertinoButton(
                                onPressed: () => setState(() {
                                  _expandedId == university.id
                                      ? _expandedId = null
                                      : _expandedId = university.id;
                                }),
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.arrowtriangle_down_circle,
                                      color: data["enabled"]
                                          ? CupertinoTheme.of(context)
                                              .textTheme
                                              .textStyle
                                              .color
                                          : CupertinoColors.systemGrey,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      data["name"],
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: data["enabled"]
                                                ? CupertinoTheme.of(context)
                                                    .textTheme
                                                    .textStyle
                                                    .color
                                                : CupertinoColors.systemGrey,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedSize(
                                duration: Duration(milliseconds: 200),
                                child: data["enabled"]
                                    ? Column(
                                        children: [
                                          Container(
                                            height: _expandedId == university.id
                                                ? null
                                                : 0,
                                            width: double.infinity,
                                            child: CupertinoButton(
                                              child:
                                                  Text("Renommer l'université"),
                                              color: CupertinoTheme.of(context)
                                                  .primaryColor,
                                              onPressed: () =>
                                                  showCupertinoModalPopup(
                                                barrierColor: Color.fromRGBO(
                                                    100, 100, 100, 0.5),
                                                context: context,
                                                builder: (context) {
                                                  _renameController.text =
                                                      data["name"];
                                                  return StatefulBuilder(
                                                    builder:
                                                        (context, setState) =>
                                                            Container(
                                                      decoration: BoxDecoration(
                                                          color: CupertinoTheme
                                                                      .brightnessOf(
                                                                          context) ==
                                                                  Brightness
                                                                      .dark
                                                              ? CupertinoColors
                                                                  .black
                                                              : CupertinoColors
                                                                  .white,
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          20))),
                                                      width: double.infinity,
                                                      height: 300,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 16.0,
                                                        horizontal: 22,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          CupertinoButton(
                                                            child:
                                                                Text("Annuler"),
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .stretch,
                                                              children: [
                                                                Container(
                                                                  height: 50,
                                                                  margin: const EdgeInsets
                                                                          .only(
                                                                      top: 8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8)),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: CupertinoColors
                                                                          .systemGrey,
                                                                    ),
                                                                  ),
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          15,
                                                                          0,
                                                                          15,
                                                                          0),
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child:
                                                                        TextField(
                                                                      minLines:
                                                                          1,
                                                                      maxLines:
                                                                          1,
                                                                      controller:
                                                                          _renameController,
                                                                      onChanged:
                                                                          (value) =>
                                                                              setState(() {}),
                                                                      style:
                                                                          TextStyle(
                                                                        color: CupertinoTheme.of(context)
                                                                            .textTheme
                                                                            .textStyle
                                                                            .color,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                      decoration:
                                                                          InputDecoration(
                                                                        hintText:
                                                                            "Nom de l'université",
                                                                        hintStyle:
                                                                            TextStyle(color: CupertinoColors.systemGrey),
                                                                        border:
                                                                            InputBorder.none,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 12),
                                                                CupertinoButton(
                                                                    child: Text(
                                                                        "Renommer"),
                                                                    color: CupertinoTheme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    onPressed:
                                                                        _renameController.text.length >
                                                                                0
                                                                            ? () {
                                                                                FirebaseFirestore.instance.collection("universities").doc(university.id).update({
                                                                                  "name": _renameController.text,
                                                                                  "editedAt": DateTime.now().millisecondsSinceEpoch,
                                                                                });
                                                                                Navigator.of(context).pop();
                                                                              }
                                                                            : null)
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: _expandedId == university.id
                                                ? null
                                                : 0,
                                            child: CupertinoButton(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    CupertinoIcons.trash,
                                                    color: CupertinoColors
                                                        .destructiveRed,
                                                    size: 16,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    'Désactiver cette université',
                                                    style: TextStyle(
                                                        color: CupertinoColors
                                                            .destructiveRed),
                                                  ),
                                                ],
                                              ),
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection("universities")
                                                    .doc(university.id)
                                                    .update({
                                                  "enabled": false,
                                                  "editedAt": DateTime.now()
                                                      .millisecondsSinceEpoch,
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        height: _expandedId == university.id
                                            ? null
                                            : 0,
                                        width: double.infinity,
                                        margin: EdgeInsets.only(
                                            bottom: _expandedId == university.id
                                                ? 15
                                                : 0),
                                        child: CupertinoButton(
                                            child: Text(
                                                "Réactiver cette université"),
                                            color: CupertinoTheme.of(context)
                                                .primaryColor,
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection("universities")
                                                  .doc(university.id)
                                                  .update({
                                                "enabled": true,
                                                "editedAt": DateTime.now()
                                                    .millisecondsSinceEpoch,
                                              });
                                            }),
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).toList());
                  },
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10),
                  Divider(
                    height: 1,
                    color: CupertinoColors.systemGrey,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Ajouter une université",
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: CupertinoColors.systemGrey,
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        minLines: 1,
                        maxLines: 1,
                        controller: _toAddController,
                        onChanged: (value) => setState(() {}),
                        style: TextStyle(
                          color: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .color,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: "Nom de l'université",
                          hintStyle:
                              TextStyle(color: CupertinoColors.systemGrey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  CupertinoButton(
                      child: Text("Créer cette université"),
                      color: CupertinoTheme.of(context).primaryColor,
                      onPressed: _toAddController.text.length > 3
                          ? () {
                              FirebaseFirestore.instance
                                  .collection("universities")
                                  .add({
                                "name": _toAddController.text,
                                "enabled": true,
                                "products": [],
                                "editedAt":
                                    DateTime.now().millisecondsSinceEpoch,
                              });
                            }
                          : null)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
