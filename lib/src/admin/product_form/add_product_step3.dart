import 'dart:typed_data';
import 'package:biolensback/shelf.dart';
import 'package:flutter/cupertino.dart';

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
    List<dynamic>? cookbookString,
    List<String>? tagsIds,
    List<String>? tagsTmp,
    String? tagPicture,
    String? source,
    bool save,
  }) submit;
  final Product product;

  AddProductStep3({required this.submit, required this.product});

  @override
  _AddProductStep3State createState() => _AddProductStep3State();
}

class _AddProductStep3State extends State<AddProductStep3> {
  late String? _tagPicture;
  late String? _source;
  late TextEditingController _controllerTagPicture;
  late TextEditingController? _controllerSource;
  late List<String> _indicationsIds;
  late List<String> _indicationsTmp;
  late List<String> _tagsIds;
  late List<String> _tagsTmp;
  late TextEditingController? _precautions;
  late TextEditingController? _ingredients;
  late TextEditingController? _cookbook;

  @override
  void initState() {
    super.initState();

    _tagPicture = widget.product.tagPicture;
    _source = widget.product.source;
    _controllerTagPicture =
        TextEditingController(text: widget.product.tagPicture);
    _controllerSource = TextEditingController(text: widget.product.source);
    _indicationsIds = widget.product.indicationsIds;
    _indicationsTmp = widget.product.indicationsTmp;
    _tagsIds = widget.product.tagsIds;
    _tagsTmp = widget.product.tagsTmp;
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
      tagsIds: _tagsIds,
      tagsTmp: _tagsTmp,
      tagPicture: _tagPicture,
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
      source: _source,
      save: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CupertinoPageScaffold(
        navigationBar: CustomNavigationBar.draw(
          context: context,
          middle: Text('Informations'),
          trailingOnly: Text(
            '??tape 3 sur 3',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: BoxConstraints(maxWidth: 800),
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: CustomCupertinoFieldsGroup(
                      title: 'Tag scanner',
                      help:
                          "Ajouter ici le nom du produit tel qu'il est ??crit sur l'emballage",
                      body: CustomTextField(
                        autofocus: false,
                        isNullable: true,
                        value: _tagPicture,
                        controller: _controllerTagPicture,
                        onChanged: (value) {
                          setState(() {
                            _tagPicture = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: CustomCupertinoFieldsGroup(
                      title: 'Tags du produit',
                      paddingTitle: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      body: CustomSelectMultiple(
                        key: Key("tagsMultiple"),
                        initialValues: _tagsTmp,
                        initialIds: _tagsIds,
                        enabled: true,
                        collectionPath: 'tags',
                        onChanged: ({
                          List<String> ids = const [],
                          List<String> values = const [],
                        }) {
                          setState(() {
                            _tagsIds = ids;
                            _tagsTmp = values;
                          });
                        },
                      ),
                      help: 'Maintenez un tag pour le d??placer',
                      paddingHelp: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: CustomCupertinoFieldsGroup(
                      title: 'Indications du produit',
                      paddingTitle: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      body: CustomSelectMultiple(
                        key: Key("indicationsMultiple"),
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
                      help: 'Maintenez une indication pour la d??placer',
                      paddingHelp: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: CustomCupertinoFieldsGroup(
                      title: 'Pr??cautions du produit',
                      body: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        child: RichTextField(
                            focus: FocusNode(), controller: _precautions),
                      ),
                      help: 'Sautez une ligne entre les pr??cautions',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: CustomCupertinoFieldsGroup(
                      title: 'Composition du produit',
                      body: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        child: RichTextField(
                            focus: FocusNode(), controller: _ingredients),
                      ),
                      help: 'Sautez une ligne entre les composants',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: CustomCupertinoFieldsGroup(
                      title: 'Mode d\'emploi du produit',
                      body: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        child: RichTextField(
                            focus: FocusNode(), controller: _cookbook),
                      ),
                      help: 'Sautez une ligne entre les ??tapes',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: CustomCupertinoFieldsGroup(
                      title: 'Source',
                      help:
                          "Ajouter ici le lien vers les donn??es du constructeur",
                      body: CustomTextField(
                        autofocus: false,
                        isNullable: true,
                        value: _source,
                        controller: _controllerSource,
                        onChanged: (value) {
                          setState(() {
                            _source = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Container(
                      width: double.infinity,
                      child: CupertinoButton(
                        child: Text('Suivant'),
                        onPressed: _submit,
                        color: CupertinoTheme.of(context).primaryColor,
                      ),
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
