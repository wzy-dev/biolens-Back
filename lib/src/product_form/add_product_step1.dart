import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Identité'),
          trailing: Text(
            'Étape 1 sur 3',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
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
                  body: CustomCupertinoTextField(
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
                  body: CustomCupertinoTextField(
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
                    color: Theme.of(context).primaryColor,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
