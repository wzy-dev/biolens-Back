import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnnotationArguments {
  const AnnotationArguments({required this.university, required this.product});

  final String university;
  final String product;
}

class Annotation extends StatelessWidget {
  Annotation(this.args);

  final AnnotationArguments args;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // final AnnotationArguments args =
    //     ModalRoute.of(context)!.settings.arguments as AnnotationArguments;

    final Future<DocumentSnapshot> _product = FirebaseFirestore.instance
        .collection('products')
        .doc(args.product)
        .get();
    final Future<QuerySnapshot> _annotation = FirebaseFirestore.instance
        .collection("universities")
        .doc(args.university)
        .collection("annotations")
        .where("enabled", isEqualTo: true)
        .where("product", isEqualTo: args.product)
        .limit(1)
        .get();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Text("Annotation"),
        ),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
              child: FutureBuilder<QuerySnapshot<Object?>>(
                future: _annotation,
                builder: (context, snapshotAnnotation) {
                  if (snapshotAnnotation.connectionState ==
                      ConnectionState.done) {
                    if (snapshotAnnotation.data != null &&
                        snapshotAnnotation.data!.docs.length > 0) {
                      Map? annotation =
                          snapshotAnnotation.data?.docs.first.data() as Map?;
                      _controller.text = annotation!["note"];
                    }

                    return FutureBuilder<DocumentSnapshot<Object?>>(
                      future: _product,
                      builder: (context, snapshotProduct) {
                        if (snapshotProduct.connectionState ==
                            ConnectionState.done) {
                          Map? product = snapshotProduct.data?.data() as Map;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text:
                                            "Ajouter une annotation pour ${product["name"].toUpperCase()} "
                                                .toUpperCase()),
                                    TextSpan(
                                        text: "(${product["brand"]})",
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: CupertinoColors.systemGrey2))
                                  ],
                                  style: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  border: Border.all(
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                child: TextField(
                                  controller: _controller,
                                  minLines: 5,
                                  maxLines: 5,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: TextStyle(
                                    color: CupertinoTheme.of(context)
                                        .textTheme
                                        .textStyle
                                        .color,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  // cursorColor: _cursorColor(context, value),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                child: CupertinoButton(
                                  child: Text("Sauvegarder"),
                                  onPressed: () {
                                    if (snapshotAnnotation.data != null &&
                                        snapshotAnnotation.data!.docs.length >
                                            0) {
                                      FirebaseFirestore.instance
                                          .doc(snapshotAnnotation
                                              .data!.docs.first.reference.path)
                                          .update({
                                        "editedAt": DateTime.now()
                                            .millisecondsSinceEpoch,
                                        "note": _controller.text,
                                      });
                                    } else {
                                      FirebaseFirestore.instance
                                          .collection("universities")
                                          .doc(args.university)
                                          .collection("annotations")
                                          .add({
                                        "editedAt": DateTime.now()
                                            .millisecondsSinceEpoch,
                                        "enabled": true,
                                        "product": snapshotProduct.data!.id,
                                        "note": _controller.text,
                                      });
                                    }

                                    Navigator.of(context).pop();
                                  },
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                ),
                              )
                            ],
                          );
                        }

                        return Center(
                          child: CupertinoActivityIndicator(),
                        );
                      },
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
