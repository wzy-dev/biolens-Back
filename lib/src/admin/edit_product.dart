// import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:biolensback/shelf.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

import 'product_form/shelf_form.dart';

class EditProduct extends StatefulWidget {
  final Map product;

  EditProduct({required this.product});

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _product = Product();
  bool _completeUpload = false;
  String? _completeSubmit;

  @override
  void initState() {
    _product.filename = widget.product['picture'];
    _product.name = widget.product['name'];
    _product.brand = widget.product['brand'];
    _product.categoryTmp = widget.product['names']['category'];
    _product.categoryId = widget.product['ids']['category'];
    _product.subCategoryTmp = widget.product['names']['subCategory'];
    _product.subCategoryId = widget.product['ids']['subCategory'];
    _product.indicationsTmp =
        List<String>.from(widget.product['names']['indications'] ?? []);
    _product.indicationsIds =
        List<String>.from(widget.product['ids']['indications'] ?? []);
    _product.precautions = List<String>.from(widget.product['precautions']);
    _product.ingredients = List<String>.from(widget.product['ingredients']);
    _product.cookbook = List<String>.from(widget.product['cookbook']);
    _product.tagsTmp = List<String>.from(widget.product['names']['tags'] ?? []);
    _product.tagsIds = List<String>.from(widget.product['ids']['tags'] ?? []);
    _product.tagPicture = widget.product['tagPicture'];
    _product.source = widget.product['source'];

    super.initState();
  }

  Future<void> uploadFile(
      {required String filename,
      required Uint8List uint8List,
      File? file}) async {
    if (file != null) {
      firebase_storage.FirebaseStorage.instance
          .ref('uploads/' + filename)
          .putFile(
              file, firebase_storage.SettableMetadata(contentType: 'image/png'))
          .then((e) {
        setState(() {
          _completeUpload = true;
        });
      });
    } else {
      firebase_storage.FirebaseStorage.instance
          .ref('uploads/' + filename)
          .putData(uint8List,
              firebase_storage.SettableMetadata(contentType: 'image/png'))
          .then((e) {
        setState(() {
          _completeUpload = true;
        });
      });
    }
  }

  void _submit({
    filename,
    uint8List,
    file,
    name,
    brand,
    categoryTmp,
    categoryId,
    subCategoryTmp,
    subCategoryId,
    indicationsIds,
    indicationsTmp,
    precautions,
    ingredients,
    cookbook,
    cookbookString,
    tagsIds,
    tagsTmp,
    tagPicture,
    source,
    save = false,
  }) {
    if (filename != null) {
      _product.filename = filename;
    }

    if (uint8List != null) {
      _product.uint8List = uint8List;
    }

    if (file != null) {
      _product.file = file;
    }

    if (name != null) {
      _product.name = name;
    }

    if (brand != null) {
      _product.brand = brand;
    }

    if (categoryTmp != null) {
      _product.categoryTmp = categoryTmp;
    }

    if (categoryId != null) {
      _product.categoryId = categoryId;
    }

    if (subCategoryTmp != null) {
      _product.subCategoryTmp = subCategoryTmp;
    }

    if (subCategoryId != null) {
      _product.subCategoryId = subCategoryId;
    }

    if (indicationsIds != null) {
      _product.indicationsIds = indicationsIds;
    }

    if (indicationsTmp != null) {
      _product.indicationsTmp = indicationsTmp;
    }

    if (precautions != null) {
      _product.precautions = precautions;
    }

    if (ingredients != null) {
      _product.ingredients = ingredients;
    }

    if (cookbook != null) {
      _product.cookbook = cookbook;
    }

    if (tagsIds != null) {
      _product.tagsIds = tagsIds;
    }

    if (tagsTmp != null) {
      _product.tagsTmp = tagsTmp;
    }

    if (tagPicture != null) {
      _product.tagPicture = tagPicture!.isNotEmpty ? tagPicture : null;
    }

    if (source != null) {
      _product.source = source.isNotEmpty ? source : null;
    }

    if (save == true) {
      if (_product.uint8List != null) {
        uploadFile(
            uint8List: _product.uint8List!,
            filename: _product.filename!,
            file: _product.file);
      } else {
        setState(() {
          _completeUpload = true;
        });
      }

      DocumentReference document = FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product['id']);

      try {
        document.update({
          'picture': _product.filename != null
              ? path.basename(_product.filename!)
              : null,
          'name': _product.name,
          'brand': _product.brand,
          'ids': {
            'category': _product.categoryId,
            'subCategory': _product.subCategoryId,
            'indications': _product.indicationsIds,
            'tags': _product.tagsIds
          },
          'names': {
            'category': _product.categoryTmp,
            'subCategory': _product.subCategoryTmp,
            'indications': _product.indicationsTmp,
            'tags': _product.tagsTmp,
          },
          'precautions': _product.precautions,
          'ingredients': _product.ingredients,
          'cookbook': _product.cookbook,
          'editedAt': DateTime.now().millisecondsSinceEpoch,
          'tagPicture': _product.tagPicture,
          'source': _product.source,
        }).then((docRef) {
          setState(() {
            _completeSubmit = widget.product['id'];
          });
        });
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_completeSubmit != null && _completeUpload) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/viewer/" + _completeSubmit!,
          ModalRoute.withName("/"),
        );
      });
    }

    return AddProductStep1(submit: _submit, product: _product);
  }
}
