import 'dart:typed_data';

import 'package:biolensback/shelf.dart';
import 'package:flutter/cupertino.dart';
import 'add_product_step3.dart';

class AddProductStep2 extends StatefulWidget {
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

  AddProductStep2({required this.submit, required this.product});

  @override
  _AddProductStep2State createState() => _AddProductStep2State();
}

class _AddProductStep2State extends State<AddProductStep2> {
  late String? _categoryId;
  late String? _subCategoryId;
  late String? _categoryTmp;
  late String? _subCategoryTmp;

  void _submit() {
    bool _error = false;

    _error = Validator.isNull(
      value: _categoryId,
      callback: () {
        setState(() {
          _categoryTmp = '';
        });
      },
    );

    _error = Validator.isNull(
      value: _subCategoryId,
      callback: () {
        setState(() {
          _subCategoryTmp = '';
        });
      },
    );

    if (_error) {
      return;
    }

    widget.submit(
      categoryId: _categoryId,
      categoryTmp: _categoryTmp,
      subCategoryId: _subCategoryId,
      subCategoryTmp: _subCategoryTmp,
    );

    Navigator.of(context).push(
      CupertinoPageRoute(
          builder: (context) =>
              AddProductStep3(submit: widget.submit, product: widget.product)),
    );
  }

  @override
  void initState() {
    super.initState();

    _categoryTmp = widget.product.categoryTmp;
    _subCategoryTmp = widget.product.subCategoryTmp;

    _categoryId = widget.product.categoryId;
    _subCategoryId = widget.product.subCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CupertinoPageScaffold(
        navigationBar: CustomNavigationBar.draw(
          context: context,
          middle: Text('Classification'),
          trailingOnly: Text(
            'Étape 2 sur 3',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomCupertinoFieldsGroup(
                        title: 'Catégorie du produit',
                        body: CustomSelect(
                          initialName: _categoryTmp,
                          initialId: _categoryId,
                          enabled: true,
                          selectedId: _categoryId,
                          collectionPath: 'categories',
                          onChanged: ({String? name, String? id}) {
                            setState(() {
                              _categoryTmp = name;
                              _categoryId = id;
                            });
                          },
                        ),
                      ),
                      CustomCupertinoFieldsGroup(
                          title: 'Sous-catégorie du produit',
                          body: CustomSelect(
                            initialName: _subCategoryTmp,
                            initialId: _subCategoryId,
                            enabled:
                                _categoryId != null && _categoryId!.length > 0
                                    ? true
                                    : false,
                            selectedId: _subCategoryId,
                            collectionPath: '/categories/' +
                                _categoryId.toString() +
                                '/subcategories',
                            onChanged: (
                                {required String name, required String id}) {
                              setState(() {
                                _subCategoryTmp = name;
                                _subCategoryId = id;
                              });
                            },
                            onChangedId: ({required String id}) {
                              _subCategoryId = id;
                            },
                          )),
                      Container(
                        width: double.infinity,
                        child: CupertinoButton(
                          child: Text('Suivant'),
                          onPressed: _submit,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
