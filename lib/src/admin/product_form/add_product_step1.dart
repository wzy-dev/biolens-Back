import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'add_product_step2.dart';
import 'package:biolensback/shelf.dart';

class AddProductStep1 extends StatefulWidget {
  final void Function({
    String? filename,
    Uint8List? uint8List,
    File? file,
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
  final bool loadingImage;

  AddProductStep1(
      {required this.submit, required this.product, this.loadingImage = false});

  @override
  _AddProductStep1State createState() => _AddProductStep1State();
}

class _AddProductStep1State extends State<AddProductStep1> {
  late String? _filename;
  Uint8List? _uint8List;
  File? _file;
  late String? _name;
  late String? _brand;
  late TextEditingController _controllerName;
  late TextEditingController _controllerBrand;

  void _submit() {
    bool _error = false;

    _error = Validator.isEmpty(
      value: _name,
      callback: () {
        setState(() {
          _name = '';
        });
      },
    );

    if (_error) {
      return;
    }

    _error = Validator.isEmpty(
      value: _brand,
      callback: () {
        setState(() {
          _brand = '';
        });
      },
    );

    if (_error) {
      return;
    }

    widget.submit(
        filename: _filename,
        uint8List: _uint8List,
        file: _file,
        name: _name,
        brand: _brand);

    Navigator.of(context).push(
      CupertinoPageRoute(
          builder: (context) =>
              AddProductStep2(submit: widget.submit, product: widget.product)),
    );
  }

  @override
  void initState() {
    super.initState();
    _controllerName = TextEditingController(text: widget.product.name);
    _controllerBrand = TextEditingController(text: widget.product.brand);
    _filename = widget.product.filename;
    _name = widget.product.name;
    _brand = widget.product.brand;
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CupertinoPageScaffold(
        navigationBar: CustomNavigationBar.draw(
          context: context,
          middle: Text('Identité'),
          trailingOnly: Text(
            'Étape 1 sur 3',
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
                      CupertinoInputFile(
                        path: _filename,
                        loadingImage: widget.loadingImage,
                        onChanged: ({
                          required String filename,
                          File? file,
                          required Uint8List uint8List,
                        }) {
                          setState(() {
                            _filename = filename;
                            _file = file;
                            _uint8List = uint8List;
                          });
                        },
                      ),
                      CustomCupertinoFieldsGroup(
                        title: 'Nom du produit',
                        body: CustomTextField(
                          value: _name,
                          node: node,
                          controller: _controllerName,
                          onChanged: (value) {
                            setState(() {
                              _name = value;
                            });
                          },
                        ),
                      ),
                      CustomCupertinoFieldsGroup(
                        title: 'Marque du produit',
                        body: CustomTextField(
                          value: _brand,
                          node: node,
                          controller: _controllerBrand,
                          onEditingComplete: _submit,
                          onChanged: (value) {
                            setState(() {
                              _brand = value;
                            });
                          },
                        ),
                      ),
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
