import 'dart:typed_data';
import 'dart:ui';
import 'package:biolensback/shelf.dart';
import 'package:biolensback/src/fields/cupertino_select_multiple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddProductStep3 extends StatefulWidget {
  final void Function({
    String? filename,
    Uint8List? uint8List,
    String? name,
    String? brand,
    String? categoryId,
    String? categoryTmp,
    String? subCategoryId,
    String? subCategoryTmp,
    List<String> indicationsIds,
    List<String> indicationsTmp,
    List<String>? precautions,
    List<String>? ingredients,
    List<String>? cookbook,
    bool save,
  }) submit;
  final Product product;

  AddProductStep3({required this.submit, required this.product});

  @override
  _AddProductStep3State createState() => _AddProductStep3State();
}

class _AddProductStep3State extends State<AddProductStep3> {
  late List<String> _indicationsIds;
  late List<String> _indicationsTmp;
  late TextEditingController? _precautions;
  late TextEditingController? _ingredients;
  late TextEditingController? _cookbook;

  @override
  void initState() {
    super.initState();

    _indicationsIds = widget.product.indicationsIds;
    _indicationsTmp = widget.product.indicationsTmp;
    _precautions = TextEditingController(
        text: widget.product.precautions?.join('\n') ?? null);
    _ingredients = TextEditingController(
        text: widget.product.ingredients?.join('\n') ?? null);
    _cookbook = TextEditingController(
        text: widget.product.cookbook?.join('\n') ?? null);
  }

  @override
  void dispose() {
    super.dispose();

    _precautions!.dispose();
    _ingredients!.dispose();
    _cookbook!.dispose();
  }

  void _submit() {
    widget.submit(
      indicationsIds: _indicationsIds,
      indicationsTmp: _indicationsTmp,
      precautions: _precautions!.text
          .split('\n')
          .where((element) => element.isEmpty == false)
          .toList(),
      ingredients: _ingredients!.text
          .split('\n')
          .where((element) => element.isEmpty == false)
          .toList(),
      cookbook: _cookbook!.text
          .split('\n')
          .where((element) => element.isEmpty == false)
          .toList(),
      save: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Informations'),
          trailing: Text(
            'Étape 3 sur 3',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: CustomCupertinoFieldsGroup(
                  title: 'Indications du produit',
                  paddingTitle: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  body: CustomSelectMultiple(
                    initialValues: _indicationsTmp,
                    initialIds: _indicationsIds,
                    enabled: true,
                    collectionPath: 'indications',
                    onChanged: ({
                      List<String> ids = const [],
                      List<String> values = const [],
                    }) {
                      setState(() {
                        _indicationsIds = ids;
                        _indicationsTmp = values;
                      });
                    },
                  ),
                  help: 'Maintenez une indication pour la déplacer',
                  paddingHelp: EdgeInsets.fromLTRB(20, 0, 20, 0),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: CustomCupertinoFieldsGroup(
                  title: 'Précautions du produit',
                  body: CupertinoTextField(
                    controller: _precautions,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 5,
                    selectionHeightStyle: BoxHeightStyle.includeLineSpacingTop,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      border: Border.all(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    style: TextStyle(height: 1.5),
                  ),
                  help: 'Sautez une ligne entre les précautions',
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: CustomCupertinoFieldsGroup(
                  title: 'Composition du produit',
                  body: CupertinoTextField(
                    controller: _ingredients,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      border: Border.all(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    style: TextStyle(height: 1.5),
                  ),
                  help: 'Sautez une ligne entre les composants',
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: CustomCupertinoFieldsGroup(
                  title: 'Mode d\'emploi du produit',
                  body: CupertinoTextField(
                    controller: _cookbook,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      border: Border.all(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    style: TextStyle(height: 1.5),
                  ),
                  help: 'Sautez une ligne entre les étapes',
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  width: double.infinity,
                  child: CupertinoButton(
                    child: Text('Suivant'),
                    onPressed: _submit,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
