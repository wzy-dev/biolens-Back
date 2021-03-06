import 'package:biolensback/shelf.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'cupertico_select_option_multiple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biolensback/src/animations/scale.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CustomSelectMultiple extends StatefulWidget {
  const CustomSelectMultiple({
    key,
    required this.collectionPath,
    required this.initialValues,
    required this.initialIds,
    required this.onChanged,
    required this.enabled,
  }) : super(key: key);

  final String collectionPath;
  final List<String>? initialValues;
  final List<String>? initialIds;
  final Function onChanged;
  final bool enabled;

  @override
  _CustomSelectMultipleState createState() => _CustomSelectMultipleState();
}

class _CustomSelectMultipleState extends State<CustomSelectMultiple> {
  late List<String> _listValues;
  late List<String> _listIds;

  @override
  void initState() {
    super.initState();

    _listValues = widget.initialValues ?? [];
    _listIds = widget.initialIds ?? [];
  }

  void _add({required String name, required String id}) {
    setState(() {
      _listIds = [..._listIds, id];
      _listValues = [..._listValues, name];
    });

    widget.onChanged(
      ids: _listIds,
      values: _listValues,
    );
  }

  void _delete({required String name, required String id}) {
    setState(() {
      _listIds.remove(id);
      _listValues.remove(name);
    });

    widget.onChanged(
      ids: _listIds,
      values: _listValues,
    );
  }

  void _rename({required String oldName, required String newName}) {
    setState(() {
      int index = _listValues.indexWhere((element) => element == oldName);

      if (index > -1) _listValues[index] = newName;
    });

    widget.onChanged(
      ids: _listIds,
      values: _listValues,
    );
  }

  void _onReorder(before, after) {
    if (before < after) {
      after -= 1;
    }

    setState(() {
      final String id = _listIds.removeAt(before);
      final String value = _listValues.removeAt(before);

      _listIds.insert(after, id);
      _listValues.insert(after, value);
    });
  }

  List<Widget> _drawList() {
    List<Widget> _list = [];

    for (int i = 0; i < _listIds.length; i++) {
      String id = _listIds[i];
      String value = _listValues[i];

      _list.add(
        Container(
          height: 40,
          padding: EdgeInsets.fromLTRB(5, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.drag_indicator,
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
                    ),
                    Expanded(
                      child: Text(
                        value,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                    )
                  ],
                ),
              ),
              CupertinoButton(
                onPressed: () => _delete(id: id, name: value),
                padding: EdgeInsets.fromLTRB(0, 0, kIsWeb ? 30 : 0, 0),
                alignment: Alignment.centerRight,
                child: Icon(
                  CupertinoIcons.return_icon,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          // key: ValueKey("selected$id${widget.collectionPath}"),
          key: UniqueKey(),
          margin: EdgeInsets.fromLTRB(
              0, (i > 0 ? 5 : 0), 0, (i < _listIds.length ? 5 : 0)),
          decoration: BoxDecoration(
            color: CupertinoTheme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
      );
    }

    return _list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: (_listIds.length * 50).toDouble(),
          child: ReorderableListView(
            key: UniqueKey(),
            primary: false,
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            children: _drawList(),
            onReorder: _onReorder,
            proxyDecorator: (widget, i, animation) {
              return CustomScaleTransition(widget: widget);
            },
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          onPressed: widget.enabled
              ? () => _showBottomModal(context, _add, _delete, _rename)
              : null,
          child: Container(
            height: 43,
            padding: EdgeInsets.fromLTRB(0, 7, 0, 10),
            child: Align(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(CupertinoIcons.pencil_ellipsis_rectangle, size: 18),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Modifier ma liste',
                    style: TextStyle(color: CupertinoColors.link),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Color.fromRGBO(10, 122, 255, 0.1),
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future _showBottomModal(
      BuildContext context, Function _add, Function _delete, Function _rename) {
    return showCupertinoModalBottomSheet(
      expand: true,
      bounce: true,
      context: context,
      barrierColor: Color.fromRGBO(100, 100, 100, 0.5),
      builder: (context) => Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              controller: ModalScrollController.of(context),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: ModalContentCustomSelectMultiple(
                  add: _add,
                  delete: _delete,
                  rename: _rename,
                  collectionPath: widget.collectionPath,
                  listIds: _listIds,
                  listValues: _listValues,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModalContentCustomSelectMultiple extends StatefulWidget {
  const ModalContentCustomSelectMultiple({
    Key? key,
    required this.add,
    required this.delete,
    required this.rename,
    required this.collectionPath,
    required this.listIds,
    required this.listValues,
  }) : super(key: key);

  final Function add;
  final Function delete;
  final Function rename;
  final String collectionPath;
  final List<String> listIds;
  final List<String> listValues;

  @override
  _ModalContentCustomSelectMultipleState createState() =>
      _ModalContentCustomSelectMultipleState();
}

class _ModalContentCustomSelectMultipleState
    extends State<ModalContentCustomSelectMultiple> {
  late TextEditingController _controllerSetter;
  String _query = '';
  late List<String> _listIds;
  late List<String> _listValues;
  late Stream<QuerySnapshot> _collectionStream;

  @override
  void initState() {
    super.initState();

    _controllerSetter = TextEditingController(text: '');
    _listIds = widget.listIds;
    _listValues = widget.listValues;

    _collectionStream = FirebaseFirestore.instance
        .collection(widget.collectionPath)
        .where('enabled', isEqualTo: true)
        .orderBy('name')
        .snapshots();
  }

  @override
  void didUpdateWidget(ModalContentCustomSelectMultiple oldWidget) {
    super.didUpdateWidget(oldWidget);

    _listIds = widget.listIds;
    _listValues = widget.listValues;
  }

  void _addNewItem() {
    String value = _controllerSetter.text;

    if (value.isEmpty) {
      return;
    }

    CollectionReference collection =
        FirebaseFirestore.instance.collection(widget.collectionPath);

    collection.add({
      'name': value,
      'editedAt': DateTime.now().millisecondsSinceEpoch,
      'enabled': true,
    });
  }

  Widget _modalContent(snapshot) {
    return StatefulBuilder(builder: (BuildContext context, setState) {
      List _searchList =
          SearchProcess.searchByName(query: _query, snapshot: snapshot);
      return Column(children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: ListTile(
            title: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                border: Border.all(
                  color: CupertinoColors.systemGrey,
                ),
              ),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                  border: InputBorder.none,
                  hintText: 'Rechercher parmi les suggestions',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: CupertinoColors.systemGrey,
                  ),
                  suffixIcon: _query.length > 0
                      ? IconButton(
                          color: CupertinoColors.systemGreen,
                          icon: Icon(
                            CupertinoIcons.plus_circle_fill,
                          ),
                          onPressed: _addNewItem,
                        )
                      : SizedBox(),
                ),
                controller: _controllerSetter,
                style: TextStyle(
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                    fontSize: 16),
                onEditingComplete: _addNewItem,
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
            ),
          ),
        ),
        snapshot.data.docs.length == 0
            ? SizedBox(
                height: 30,
              )
            : Container(),
        ..._searchList.asMap().entries.map((entry) {
          return _itemBuilder(entry, _searchList.length);
        }).toList(),
      ]);
    });
  }

  @override
  void dispose() {
    _controllerSetter.dispose();

    super.dispose();
  }

  void _renameAction({required String id, required String name}) {
    CollectionReference collection =
        FirebaseFirestore.instance.collection(widget.collectionPath);

    collection
        .doc(id)
        .update({
          'name': name,
          'editedAt': DateTime.now().millisecondsSinceEpoch,
        })
        .then((name) => print("Option Updated"))
        .catchError((error) => print("Failed to update option: $error"));
  }

  void _removeAction({required String id, required String name}) {
    showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              title: Text('??tes-vous s??r de vouloir supprimer "$name" ?'),
              content: Text(
                  'Vous ??tes sur le point de supprimer "$name" de vos suggestions.'),
              actions: [
                CupertinoButton(
                    child: Text('Annuler'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                CupertinoButton(
                    child: Text('Supprimer',
                        style:
                            TextStyle(color: CupertinoColors.destructiveRed)),
                    onPressed: () {
                      // CollectionReference productsCollection =
                      //     FirebaseFirestore.instance.collection("products");

                      // productsCollection
                      //     .where("ids.indications", arrayContains: id)
                      //     .get()
                      //     .then((value) {
                      //   value.docs.forEach((DocumentSnapshot document) {
                      //     productsCollection
                      //         .doc(document.id)
                      //         .update({"ids.indications": _listIds});

                      //     productsCollection
                      //         .doc(document.id)
                      //         .update({"names.indications": _listValues});
                      //   });

                      CollectionReference collection = FirebaseFirestore
                          .instance
                          .collection(widget.collectionPath);

                      collection
                          .doc(id)
                          .update({
                            'enabled': false,
                            'editedAt': DateTime.now().millisecondsSinceEpoch,
                          })
                          .then((name) => print("Option Removed"))
                          .catchError((error) =>
                              print("Failed to update option: $error"));
                      // });

                      // widget.delete(name: name, id: id);

                      Navigator.of(context).pop();
                    }),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _collectionStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return _modalContent(snapshot);
        });
  }

  void _touchAction({required String name, required String id}) {
    Iterable<String> idWhere = _listIds.where((element) => element == id);
    if (idWhere.length > 0) {
      widget.delete(name: name, id: id);

      setState(() {
        _listIds.remove(id);
        _listValues.remove(name);
      });
    } else {
      widget.add(name: name, id: id);
      setState(() {
        _listIds = [..._listIds, id];
        _listValues = [..._listValues, name];
      });
    }
  }

  Widget _itemBuilder(entry, int endIndex) {
    int index = entry.key;
    Map document = entry.value.item;

    return Column(children: [
      CustomSelectOptionMultiple(
        id: document['id'],
        name: document['name'],
        renameAction: _renameAction,
        removeAction: _removeAction,
        rename: widget.rename,
        enabled: _listIds.contains(document['id']),
        touchAction: _touchAction,
      ),
      (index + 1 < endIndex)
          ? Divider(
              height: 5,
              indent: 20,
              endIndent: 20,
              color: CupertinoColors.systemGrey,
            )
          : Container()
    ]);
  }
}
