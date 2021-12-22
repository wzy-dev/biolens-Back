import 'dart:typed_data';
import 'dart:ui';
import 'package:biolensback/shelf.dart';
import 'package:biolensback/src/fields/cupertino_select_multiple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:html_editor_enhanced/html_editor.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:tuple/tuple.dart';

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
    bool save,
  }) submit;
  final Product product;

  AddProductStep3({required this.submit, required this.product});

  @override
  _AddProductStep3State createState() => _AddProductStep3State();
}

class _AddProductStep3State extends State<AddProductStep3> {
  late String? _tagPicture;
  late TextEditingController _controllerTagPicture;
  late List<String> _indicationsIds;
  late List<String> _indicationsTmp;
  late List<String> _tagsIds;
  late List<String> _tagsTmp;
  late TextEditingController? _precautions;
  late TextEditingController? _ingredients;
  late TextEditingController? _cookbook;
  late final quill.QuillController _controller;
  final ScrollController _listViewController = ScrollController();
  late final FocusNode _usageFocus;

  @override
  void initState() {
    super.initState();

    _usageFocus = FocusNode();
    _controller = quill.QuillController.basic();

    _tagPicture = widget.product.tagPicture;
    _controllerTagPicture =
        TextEditingController(text: widget.product.tagPicture);
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

    quill.Delta delta = quill.Delta();
    for (var i = 0; i < widget.product.cookbook!.length; i++) {
      delta.insert(widget.product.cookbook![i]);
      delta.insert('\n');
    }
    _controller.document.compose(delta, quill.ChangeSource.LOCAL);
  }

  @override
  void dispose() {
    super.dispose();

    _precautions!.dispose();
    _ingredients!.dispose();
    _cookbook!.dispose();
  }

  void _submit() {
    print(_controller.document.toDelta().toJson());
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
      // cookbook: _cookbook!.text
      //     .split('\n')
      //     .where((element) => element.isEmpty == false)
      //     .toList(),
      cookbookString:
          _controller.document.toDelta().toJson() as List<Map<String, dynamic>>,
      save: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CupertinoPageScaffold(
        resizeToAvoidBottomInset: true,
        navigationBar: CupertinoNavigationBar(
          middle: Text('Informations'),
          trailing: Text(
            'Étape 3 sur 3',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ),
        child: SafeArea(
          child: ListView(
            controller: _listViewController,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: CustomCupertinoFieldsGroup(
                  title: 'Tag scanner',
                  help:
                      "Ajouter ici le nom du produit tel qu'il est écrit sur l'emballage",
                  body: CustomCupertinoTextField(
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
                  help: 'Maintenez un tag pour le déplacer',
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
                child: CustomCupertinoFieldsGroup(
                  title: 'Mode d\'emploi du produit',
                  body: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        border: Border.all(
                          color: CupertinoColors.systemGrey,
                        ),
                        color:
                            CupertinoTheme.of(context).scaffoldBackgroundColor),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          quill.QuillEditor(
                            onTapDown: (TapDownDetails tapDetails,
                                TextPosition Function(Offset) positions) {
                              Future.delayed(
                                Duration(milliseconds: 350),
                                () => _listViewController.animateTo(
                                  _listViewController.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.linear,
                                ),
                              );

                              return false;
                            },
                            minHeight: 200,
                            customStyles: quill.DefaultStyles(
                              paragraph: quill.DefaultTextBlockStyle(
                                CupertinoTheme.of(context).textTheme.textStyle,
                                const Tuple2(5, 5),
                                const Tuple2(0, 0),
                                null,
                              ),
                              leading: quill.DefaultTextBlockStyle(
                                CupertinoTheme.of(context).textTheme.textStyle,
                                const Tuple2(0, 16),
                                const Tuple2(0, 0),
                                null,
                              ),
                            ),
                            focusNode: _usageFocus,
                            scrollable: true,
                            autoFocus: false,
                            expands: false,
                            padding: const EdgeInsets.all(0),
                            scrollController: ScrollController(),
                            controller: _controller,
                            readOnly: false,
                          ),
                          quill.QuillToolbar.basic(
                            locale: Locale('fr'),
                            iconTheme: quill.QuillIconTheme(
                              iconUnselectedColor: CupertinoColors.white,
                              iconUnselectedFillColor: Color.fromRGBO(
                                125,
                                125,
                                125,
                                0.5,
                              ),
                              iconSelectedFillColor:
                                  CupertinoTheme.of(context).primaryColor,
                            ),
                            controller: _controller,
                            showBoldButton: true,
                            showColorButton: false,
                            showBackgroundColorButton: false,
                            showCameraButton: false,
                            showAlignmentButtons: false,
                            showCenterAlignment: false,
                            showClearFormat: false,
                            showCodeBlock: false,
                            showDividers: false,
                            showHeaderStyle: false,
                            showHistory: false,
                            showHorizontalRule: false,
                            showImageButton: false,
                            showItalicButton: false,
                            showUnderLineButton: false,
                            showInlineCode: false,
                            showListCheck: false,
                            showQuote: false,
                            showLink: false,
                            showIndent: false,
                            showStrikeThrough: false,
                            showVideoButton: false,
                          ),
                        ],
                      ),
                    ),
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
