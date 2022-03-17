import 'package:biolensback/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RequestEditProduct extends StatefulWidget {
  const RequestEditProduct({Key? key, required this.university})
      : super(key: key);

  final String university;

  @override
  State<RequestEditProduct> createState() => _RequestEditProductState();
}

class _RequestEditProductState extends State<RequestEditProduct> {
  String? _productName;
  String? _productId;
  String _toUpdate = "";

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar.draw(
        context: context,
        middle: Text("Signaler un produit"),
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
                  Text(
                    "Nom du produit à signaler (facultatif) :".toUpperCase(),
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  SizedBox(height: 10),
                  CustomSelect(
                    collectionPath: "/products",
                    initialName: _productName,
                    initialId: _productId,
                    onChanged: ({required String name, required String id}) {
                      setState(() {
                        _productName = name;
                        _productId = id;
                      });
                    },
                    onChangedId: ({required String id}) {
                      _productId = id;
                    },
                    enabled: true,
                    selectedId: _productId,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Informations à signaler :".toUpperCase(),
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: TextField(
                      autofocus: true,
                      minLines: 5,
                      maxLines: 10,
                      onChanged: (value) => setState(() {
                        _toUpdate = value;
                      }),
                      textCapitalization: TextCapitalization.sentences,
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
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20),
                    child: CupertinoButton(
                      child: Text("Envoyer le signalement"),
                      color: CupertinoTheme.of(context).primaryColor,
                      onPressed: () {
                        if (_toUpdate.length > 0) {
                          FirebaseFirestore.instance
                              .collection("requests")
                              .add({
                            "state": "sent",
                            "toUpdate": _toUpdate,
                            "productId": _productId,
                            "productName": _productName,
                            "university": widget.university,
                            "createdAt": DateTime.now().millisecondsSinceEpoch,
                            "editedAt": DateTime.now().millisecondsSinceEpoch,
                            "type": "edit",
                          });
                        }
                        Navigator.of(context).pop();
                      },
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
