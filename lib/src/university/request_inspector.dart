import 'package:biolensback/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestInspector extends StatefulWidget {
  const RequestInspector(
      {Key? key,
      required this.request,
      required this.university,
      this.admin = false})
      : super(key: key);

  final String request;
  final String university;
  final bool admin;

  @override
  State<RequestInspector> createState() => _RequestInspectorState();
}

class _RequestInspectorState extends State<RequestInspector> {
  late final Stream<DocumentSnapshot<Object?>> _streamRequest;

  String? _universityName;
  final TextEditingController _feedbacksController = TextEditingController();

  @override
  void initState() {
    _streamRequest = FirebaseFirestore.instance
        .collection("requests")
        .doc(widget.request)
        .snapshots();
    FirebaseFirestore.instance
        .collection("universities")
        .doc(widget.university)
        .get()
        .then((value) => setState(() {
              _universityName = (value.data() as Map)["name"];
            }));
    super.initState();
  }

  Icon _drawRequestIcon(String state) {
    double sizeIcon = 80;
    switch (
        RequestStates.values.firstWhere((element) => element.name == state)) {
      case RequestStates.sent:
        return Icon(
          CupertinoIcons.envelope_circle,
          color: CupertinoColors.systemGrey3,
          size: sizeIcon,
        );
      case RequestStates.treatment:
        return Icon(
          CupertinoIcons.person_circle,
          color: CupertinoColors.activeBlue,
          size: sizeIcon,
        );
      case RequestStates.done:
        return Icon(
          CupertinoIcons.checkmark_alt_circle,
          color: CupertinoColors.activeGreen,
          size: sizeIcon,
        );
      default:
        return Icon(CupertinoIcons.exclamationmark_circle);
    }
  }

  Text _drawRequestState(String state) {
    switch (
        RequestStates.values.firstWhere((element) => element.name == state)) {
      case RequestStates.sent:
        return Text(
          "En attente de traitement",
          style: TextStyle(
            color: CupertinoColors.systemGrey3,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        );
      case RequestStates.treatment:
        return Text(
          "En cours de traitement",
          style: TextStyle(
            color: CupertinoColors.activeBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        );
      case RequestStates.done:
        return Text(
          "Demande traitée",
          style: TextStyle(
            color: CupertinoColors.activeGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        );
      default:
        return Text(
          "Etat inconnu",
          style: TextStyle(color: CupertinoColors.systemGrey3),
        );
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

  Widget _drawFeedbacks(BuildContext context, List<String> feedbacks) {
    int i = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Remarques :".toUpperCase(),
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontWeight: FontWeight.bold,
                // fontSize: 15,
              ),
        ),
        SizedBox(height: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: feedbacks.map((e) {
            i++;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                "$i. $e",
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar.draw(
        context: context,
        middle: Text("Inspecteur de requête"),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 30, top: 25, right: 30, bottom: 20),
              child: StreamBuilder<DocumentSnapshot>(
                stream: _streamRequest,
                builder: (context, snapshotRequest) {
                  if (snapshotRequest.connectionState ==
                      ConnectionState.active) {
                    Map? requestMap = snapshotRequest.data?.data() as Map?;
                    if (requestMap == null) return SizedBox();
                    if (requestMap["feedbacks"] != null)
                      _feedbacksController.text =
                          requestMap["feedbacks"].join('\n');

                    List<String> _addedList =
                        List<String>.from(requestMap["addedList"] ?? []);

                    return Container(
                      width: double.infinity,
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Container(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  _drawRequestIcon(requestMap["state"]),
                                  SizedBox(height: 8),
                                  _drawRequestState(requestMap["state"]),
                                  SizedBox(height: 2),
                                  Text(
                                    "Dernière modification le ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.fromMillisecondsSinceEpoch(requestMap["editedAt"]))}",
                                    style: TextStyle(
                                      color: CupertinoColors.systemGrey2,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _writeRequestType(requestMap["type"],
                                    toAddList: requestMap["toAddList"])
                                .toUpperCase(),
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                          ),
                          SizedBox(height: 5),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text:
                                    "Demande réalisée le ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.fromMillisecondsSinceEpoch(requestMap["editedAt"]))}",
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey2,
                                ),
                              ),
                              TextSpan(
                                text: _universityName != null
                                    ? " ($_universityName)"
                                    : "",
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]),
                          ),
                          SizedBox(height: 20),
                          requestMap["type"] == "add"
                              ? Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: requestMap["toAddList"].map<Widget>(
                                    (e) {
                                      bool isAdded = _addedList.contains(e);
                                      return CupertinoButton(
                                        minSize: 0,
                                        padding: const EdgeInsets.all(0),
                                        onPressed: widget.admin &&
                                                requestMap["state"] != "sent"
                                            ? () => FirebaseFirestore.instance
                                                    .collection("requests")
                                                    .doc(widget.request)
                                                    .update({
                                                  "editedAt": DateTime.now()
                                                      .millisecondsSinceEpoch,
                                                  "addedList": isAdded
                                                      ? _addedList
                                                          .where((element) =>
                                                              element != e)
                                                          .toList()
                                                      : [..._addedList, e]
                                                })
                                            : null,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                            border: Border.all(
                                                width: 2,
                                                color: isAdded
                                                    ? CupertinoColors
                                                        .activeGreen
                                                    : CupertinoColors
                                                        .systemGrey2),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 4),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                isAdded
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 5.0),
                                                        child: Icon(
                                                          CupertinoIcons
                                                              .check_mark,
                                                          color: CupertinoColors
                                                              .activeGreen,
                                                          size: 15,
                                                        ),
                                                      )
                                                    : SizedBox(),
                                                Text(
                                                  e,
                                                  style: isAdded
                                                      ? TextStyle(
                                                          color: CupertinoColors
                                                              .activeGreen)
                                                      : CupertinoTheme.of(
                                                              context)
                                                          .textTheme
                                                          .textStyle,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    requestMap["productName"] != null
                                        ? RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "Le produit : ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text:
                                                      requestMap["productName"],
                                                ),
                                              ],
                                              style: CupertinoTheme.of(context)
                                                  .textTheme
                                                  .textStyle,
                                            ),
                                          )
                                        : SizedBox(),
                                    SizedBox(height: 5),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Votre signalement : ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: requestMap["toUpdate"],
                                          ),
                                        ],
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle,
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(height: 20),
                          requestMap["state"] == "sent"
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    widget.admin
                                        ? CupertinoButton(
                                            color: CupertinoTheme.of(context)
                                                .primaryColor,
                                            child: Text(
                                              'Commencer le traitement',
                                            ),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection("requests")
                                                  .doc(widget.request)
                                                  .update({
                                                "state": "treatment",
                                                "editedAt": DateTime.now()
                                                    .millisecondsSinceEpoch
                                              });
                                              // Navigator.of(context).pop();
                                            },
                                          )
                                        : SizedBox(),
                                    CupertinoButton(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.trash,
                                            color:
                                                CupertinoColors.destructiveRed,
                                            size: 16,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Annuler cette requête',
                                            style: TextStyle(
                                                color: CupertinoColors
                                                    .destructiveRed),
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        showCupertinoDialog(
                                            context: context,
                                            builder: (context) =>
                                                CupertinoAlertDialog(
                                                  title: Text(
                                                      "Supprimer une requête"),
                                                  content: Text(
                                                      "Êtes-vous sûr de vouloir supprimer cette requête ? Cette action est irréversible."),
                                                  actions: [
                                                    CupertinoDialogAction(
                                                        child: Text("Annuler"),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop()),
                                                    CupertinoDialogAction(
                                                        child:
                                                            Text("Supprimer"),
                                                        isDestructiveAction:
                                                            true,
                                                        onPressed: () {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "requests")
                                                              .doc(widget
                                                                  .request)
                                                              .delete();
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        }),
                                                  ],
                                                ));
                                      },
                                    ),
                                  ],
                                )
                              : !widget.admin
                                  ? requestMap["feedbacks"] != null
                                      ? _drawFeedbacks(
                                          context,
                                          List<String>.from(
                                              requestMap["feedbacks"]))
                                      : SizedBox()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          "Remarques :".toUpperCase(),
                                          style: CupertinoTheme.of(context)
                                              .textTheme
                                              .textStyle
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                // fontSize: 15,
                                              ),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  border: Border.all(
                                                    color: CupertinoColors
                                                        .systemGrey,
                                                  ),
                                                ),
                                                padding: EdgeInsets.fromLTRB(
                                                    15, 0, 15, 0),
                                                child: TextField(
                                                  minLines: 5,
                                                  maxLines: 10,
                                                  controller:
                                                      _feedbacksController,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  style: TextStyle(
                                                    color: CupertinoTheme.of(
                                                            context)
                                                        .textTheme
                                                        .textStyle
                                                        .color,
                                                    fontSize: 16,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Container(
                                              child: CupertinoButton(
                                                minSize: 0,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                color:
                                                    CupertinoTheme.of(context)
                                                        .primaryColor,
                                                child: Icon(
                                                    CupertinoIcons.paperplane),
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection("requests")
                                                      .doc(widget.request)
                                                      .update({
                                                    "editedAt": DateTime.now()
                                                        .millisecondsSinceEpoch,
                                                    "feedbacks":
                                                        _feedbacksController
                                                            .text
                                                            .split('\n')
                                                            .where((element) =>
                                                                element
                                                                    .isEmpty ==
                                                                false)
                                                            .toList()
                                                  });
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        requestMap["state"] == "treatment"
                                            ? CupertinoButton(
                                                color:
                                                    CupertinoTheme.of(context)
                                                        .primaryColor,
                                                child: Text(
                                                    "Clôturer cette requête"),
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection("requests")
                                                      .doc(widget.request)
                                                      .update({
                                                    "editedAt": DateTime.now()
                                                        .millisecondsSinceEpoch,
                                                    "state": "done",
                                                    "feedbacks":
                                                        _feedbacksController
                                                            .text
                                                            .split('\n')
                                                            .where((element) =>
                                                                element
                                                                    .isEmpty ==
                                                                false)
                                                            .toList()
                                                  });
                                                  // Navigator.of(context).pop();
                                                },
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: CupertinoActivityIndicator(),
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
