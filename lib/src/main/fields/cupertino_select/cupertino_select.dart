import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'cupertico_select_option.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biolensback/shelf.dart';

class CustomSelect extends StatefulWidget {
  const CustomSelect({
    key,
    required this.collectionPath,
    required this.initialName,
    required this.initialId,
    required this.onChanged,
    required this.enabled,
    required this.selectedId,
    this.onChangedId,
  }) : super(key: key);

  final String collectionPath;
  final String? initialName;
  final String? initialId;
  final Function onChanged;
  final Function? onChangedId;
  final bool enabled;
  final String? selectedId;

  @override
  _CustomSelectState createState() => _CustomSelectState();
}

class _CustomSelectState extends State<CustomSelect> {
  late TextEditingController _controllerTouchable;
  late String? _activeId;
  late String _collectionPath;

  @override
  void initState() {
    super.initState();

    _activeId = widget.initialId;
    _controllerTouchable = TextEditingController(text: widget.initialName);
    _collectionPath = widget.collectionPath;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_collectionPath != widget.collectionPath) {
      _controllerTouchable = TextEditingController(text: null);
      widget.onChangedId!(id: null);
    }

    setState(() {
      _collectionPath = widget.collectionPath;
    });
  }

  @override
  void dispose() {
    _controllerTouchable.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration _textInputDecoration(
        {required String? value, required bool enabled}) {
      if (enabled == false) {
        // If disabled > Box disabled
        return BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.05),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: CupertinoColors.systemGrey5,
          ),
        );
      } else if (value?.isEmpty ?? false) {
        // If empty > Box danger
        return BoxDecoration(
          color: Color.fromRGBO(255, 0, 0, 0.05),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: CupertinoColors.destructiveRed,
          ),
        );
      } else {
        // If not empty > Box ok
        return BoxDecoration(
          // color: CupertinoColors.lightBackgroundGray,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: CupertinoColors.systemGrey,
          ),
        );
      }
    }

    void _submit({required String? name, required String? id}) {
      _controllerTouchable.text = name ?? "";
      _activeId = id;
      widget.onChanged(name: name, id: id);
      Navigator.pop(context);
    }

    return CupertinoButton(
      padding: EdgeInsets.all(0),
      child: CupertinoTextField(
        controller: _controllerTouchable,
        decoration: _textInputDecoration(
            value: _controllerTouchable.text.isNotEmpty
                ? _controllerTouchable.text
                : widget.initialName,
            enabled: widget.enabled),
        style: TextStyle(fontSize: 16),
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        maxLines: null,
        enabled: false,
      ),
      onPressed:
          widget.enabled ? () => _showBottomModal(context, _submit) : null,
    );
  }

  Future _showBottomModal(BuildContext context, Function _submit) {
    return showCupertinoModalBottomSheet(
        expand: true,
        bounce: true,
        context: context,
        barrierColor: Color.fromRGBO(100, 100, 100, 0.5),
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) => Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  // child: ConstrainedBox(
                  //   constraints: BoxConstraints(
                  //       maxHeight: MediaQuery.of(context).size.height * 0.80),
                  child: SingleChildScrollView(
                    controller: ModalScrollController.of(context),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: ModalContentCustomSelect(
                          submit: _submit,
                          collectionPath: _collectionPath,
                          onChanged: widget.onChanged,
                          activeId: _activeId,
                          selectedId: widget.selectedId),
                    ),
                  ),
                  // ),
                ),
              ),
            ),
          );
        });
  }
}

class ModalContentCustomSelect extends StatefulWidget {
  const ModalContentCustomSelect({
    required this.submit,
    required this.collectionPath,
    required this.onChanged,
    required this.activeId,
    required this.selectedId,
  });

  final Function submit;
  final String collectionPath;
  final Function onChanged;
  final String? activeId;
  final String? selectedId;

  @override
  _ModalContentCustomSelectState createState() =>
      _ModalContentCustomSelectState();
}

class _ModalContentCustomSelectState extends State<ModalContentCustomSelect> {
  late TextEditingController _controllerSetter;
  String _query = '';
  late StreamBuilder<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();

    _controllerSetter = TextEditingController(text: '');

    final Stream<QuerySnapshot> _collectionStream = FirebaseFirestore.instance
        .collection(widget.collectionPath)
        .where('enabled', isEqualTo: true)
        .orderBy('name')
        .snapshots();

    _stream = StreamBuilder<QuerySnapshot>(
        stream: _collectionStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print(snapshot);
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return _modalContent(snapshot);
        });
  }

  @override
  void dispose() {
    _controllerSetter.dispose();

    super.dispose();
  }

  void _addNewItem() {
    String value = _controllerSetter.text;

    if (value.isEmpty) {
      return;
    }

    CollectionReference collection =
        FirebaseFirestore.instance.collection(widget.collectionPath);

    collection
        .add({
          'name': value,
          'editedAt': DateTime.now().millisecondsSinceEpoch,
          'enabled': true,
        })
        .then((docRef) => widget.submit(id: docRef.id, name: value))
        .catchError((error) => print("Failed to add option: $error"));
  }

  void _renameAction({required String id, required String name}) {
    CollectionReference collection =
        FirebaseFirestore.instance.collection(widget.collectionPath);

    if (widget.activeId == id) {
      widget.submit(name: name, id: id);
    }

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
              title: Text('Êtes-vous sûr de vouloir supprimer "$name" ?'),
              content: Text(
                  'Vous êtes sur le point de supprimer "$name" de vos suggestions.'),
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
                      widget.submit(name: null, id: null);

                      Navigator.pop(context);
                    }),
              ],
            ));
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
  Widget build(BuildContext context) {
    return _stream;
  }

  Widget _itemBuilder(entry, int endIndex) {
    int index = entry.key;
    Map document = entry.value.item;

    return Column(children: [
      CustomSelectOption(
        id: document['id'],
        name: document['name'],
        renameAction: _renameAction,
        removeAction: _removeAction,
        submit: widget.submit,
        selected: (widget.selectedId == document['id'] ? true : false),
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
