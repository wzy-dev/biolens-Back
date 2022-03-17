import 'package:biolensback/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RequestAddProduct extends StatefulWidget {
  const RequestAddProduct({Key? key, required this.university})
      : super(key: key);

  final String university;

  @override
  State<RequestAddProduct> createState() => _RequestAddProductState();
}

class _RequestAddProductState extends State<RequestAddProduct> {
  List<String> _productsList = [""];
  int _nbInput = 1;

  List<Widget> _drawInputsList(context) {
    List<Widget> result = [];
    for (var i = 0; i < _nbInput; i++) {
      result.add(_drawInput(context, i));
    }
    return result;
  }

  Widget _drawInput(context, index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: CupertinoColors.systemGrey,
        ),
      ),
      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: TextField(
        autofocus: true,
        minLines: 1,
        maxLines: 1,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: "Unifast Trad (GC)",
          hintStyle: TextStyle(
              color: CupertinoColors.systemGrey, fontStyle: FontStyle.italic),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          _productsList[index] = value;

          if (_nbInput - 1 == index && value.length > 0) {
            setState(() {
              _productsList.add("");
              _nbInput++;
            });
          } else if (_nbInput - 2 == index && value.length == 0) {
            setState(() {
              _productsList.removeLast();
              _nbInput--;
            });
          }
        },
        style: TextStyle(
          color: CupertinoTheme.of(context).textTheme.textStyle.color,
          fontSize: 16,
        ),
        // cursorColor: _cursorColor(context, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar.draw(
        context: context,
        middle: Text("Ajouter un produit"),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Entrez le nom du produit ainsi que sa marque entre parenthèses :"
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
                  Expanded(
                    child: ListView(
                      children: _drawInputsList(context),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    child: CupertinoButton(
                      child: Text("Soumettre la liste"),
                      color: CupertinoTheme.of(context).primaryColor,
                      onPressed: () {
                        if (_productsList
                                .where((element) => element.length > 0)
                                .length >
                            0) {
                          FirebaseFirestore.instance
                              .collection("requests")
                              .add({
                            "state": "sent",
                            "toAddList": _productsList
                                .where((element) => element.length > 0)
                                .toList(),
                            "university": widget.university,
                            "createdAt": DateTime.now().millisecondsSinceEpoch,
                            "editedAt": DateTime.now().millisecondsSinceEpoch,
                            "type": "add",
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
