import 'package:biolensback/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class TechnicalPlatform extends StatefulWidget {
  const TechnicalPlatform({this.university});

  final String? university;

  @override
  _TechnicalPlatformState createState() => _TechnicalPlatformState();
}

class _TechnicalPlatformState extends State<TechnicalPlatform> {
  final Stream<QuerySnapshot> _universitiesStream = FirebaseFirestore.instance
      .collection('universities')
      .where("enabled", isEqualTo: true)
      .snapshots();
  final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
      .collection('products')
      .where("enabled", isEqualTo: true)
      .orderBy("name")
      .snapshots();
  String? _university;

  List<String> _productsSelected = [];
  List<String> _initialSelection = [];

  @override
  Widget build(BuildContext context) {
    bool _isInitial = DeepCollectionEquality.unordered()
        .equals(_productsSelected, _initialSelection);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Text(widget.university == null
              ? "Mode universitaire"
              : "Mon plateau technique"),
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
              child: StreamBuilder<QuerySnapshot<Object?>>(
                stream: _universitiesStream,
                builder: (context, snapshotUniversities) {
                  if (snapshotUniversities.connectionState ==
                      ConnectionState.active) {
                    if (snapshotUniversities.data != null &&
                        snapshotUniversities.data!.docs.length > 0 &&
                        _university == null) {
                      QueryDocumentSnapshot document = widget.university != null
                          ? snapshotUniversities.data!.docs.firstWhere(
                              (element) => element.id == widget.university)
                          : snapshotUniversities.data!.docs.first;

                      _university = document.id;

                      _productsSelected = List<String>.from(
                          (document.data() as Map)["products"]);
                      _initialSelection = List<String>.from(_productsSelected);
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              widget.university == null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 15),
                                          child: Text(
                                            "Sélectionner une université :"
                                                .toUpperCase(),
                                            style: CupertinoTheme.of(context)
                                                .textTheme
                                                .textStyle
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  // fontSize: 12,
                                                ),
                                          ),
                                        ),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 8,
                                          children: snapshotUniversities
                                                  .data?.docs
                                                  .map((university) {
                                                Map universityMap =
                                                    university.data() as Map;

                                                return CupertinoButton(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 2),
                                                  color: _university ==
                                                          university.id
                                                      ? CupertinoTheme.of(
                                                              context)
                                                          .primaryColor
                                                      : CupertinoColors
                                                          .systemGrey2,
                                                  child: Container(
                                                    child: Text(
                                                      universityMap['name'],
                                                      style: CupertinoTheme.of(
                                                              context)
                                                          .textTheme
                                                          .textStyle,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _university =
                                                          university.id;

                                                      _productsSelected =
                                                          List<String>.from(
                                                              universityMap[
                                                                  "products"]);
                                                      _initialSelection = List<
                                                              String>.from(
                                                          _productsSelected);
                                                    });
                                                  },
                                                );
                                              }).toList() ??
                                              [],
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: widget.university == null ? 40 : 0,
                                    bottom: 15),
                                child: Text(
                                  "Sélectionner les produits du plateau technique :"
                                      .toUpperCase(),
                                  style: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 12,
                                      ),
                                ),
                              ),
                              StreamBuilder<QuerySnapshot<Object?>>(
                                stream: _productsStream,
                                builder: (context, snapshotProducts) {
                                  if (snapshotProducts.connectionState ==
                                      ConnectionState.active) {
                                    bool allIsSelected =
                                        DeepCollectionEquality.unordered()
                                            .equals(
                                                snapshotProducts.data?.docs
                                                    .map((product) {
                                                  return product.id;
                                                }).toList(),
                                                _productsSelected);

                                    return Column(children: [
                                      CheckboxListTile(
                                        value: allIsSelected,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        title: Text(
                                          allIsSelected
                                              ? "Tout désélectionner"
                                              : "Tout sélectionner",
                                          style: CupertinoTheme.of(context)
                                              .textTheme
                                              .textStyle
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                // fontSize: 12,
                                              ),
                                        ),
                                        side: BorderSide(
                                          color: CupertinoColors.systemGrey2,
                                          width: 2,
                                        ),
                                        onChanged: (value) {
                                          if (value == true) {
                                            _productsSelected = snapshotProducts
                                                    .data?.docs
                                                    .map(
                                                        (product) => product.id)
                                                    .toList() ??
                                                [];
                                            setState(() {});
                                          } else {
                                            setState(() {
                                              _productsSelected = [];
                                            });
                                          }
                                        },
                                      ),
                                      ...snapshotProducts.data?.docs
                                              .map((product) {
                                            Map productMap =
                                                product.data() as Map;

                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: CheckboxListTile(
                                                    value: _productsSelected
                                                        .contains(product.id),
                                                    controlAffinity:
                                                        ListTileControlAffinity
                                                            .leading,
                                                    title: Text(
                                                      productMap["name"],
                                                      style: CupertinoTheme.of(
                                                              context)
                                                          .textTheme
                                                          .textStyle
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            // fontSize: 12,
                                                          ),
                                                    ),
                                                    subtitle: Text(
                                                      productMap["brand"],
                                                      style: TextStyle(
                                                        color: CupertinoColors
                                                            .systemGrey2,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    side: BorderSide(
                                                      color: CupertinoColors
                                                          .systemGrey2,
                                                      width: 2,
                                                    ),
                                                    onChanged: (value) {
                                                      if (value == true) {
                                                        setState(() {
                                                          _productsSelected
                                                              .add(product.id);
                                                        });
                                                      } else {
                                                        setState(() {
                                                          _productsSelected
                                                              .removeWhere(
                                                                  (e) =>
                                                                      e ==
                                                                      product
                                                                          .id);
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                                CupertinoButton(
                                                  child: Icon(CupertinoIcons
                                                      .pencil_ellipsis_rectangle),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .push(
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          Annotation(
                                                        AnnotationArguments(
                                                          university:
                                                              _university!,
                                                          product: product.id,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            );
                                          }).toList() ??
                                          [],
                                    ]);
                                  }

                                  return Center(
                                    child: CupertinoActivityIndicator(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8),
                          child: CupertinoButton(
                              color: CupertinoTheme.of(context).primaryColor,
                              child: Text(
                                "Enregistrer les modifications",
                                style: _isInitial
                                    ? CupertinoTheme.of(context)
                                        .textTheme
                                        .textStyle
                                    : null,
                              ),
                              onPressed: !_isInitial
                                  ? () {
                                      FirebaseFirestore.instance
                                          .collection("universities")
                                          .doc(_university)
                                          .update({
                                        "products": _productsSelected,
                                        "editedAt": DateTime.now()
                                            .millisecondsSinceEpoch,
                                      });
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      } else {
                                        _initialSelection = List<String>.from(
                                            _productsSelected);
                                      }
                                    }
                                  : null),
                        )
                      ],
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
