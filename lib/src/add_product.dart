import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'product_form/add_product_step1.dart';
import 'package:biolensback/shelf.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _product = Product();
  bool _completeUpload = false;
  String? _completeSubmit;

  Future<void> uploadFile(
      {required String filename,
      required Uint8List uint8List,
      File? file}) async {
    if (file != null) {
      firebase_storage.FirebaseStorage.instance
          .ref('uploads/' + filename)
          .putFile(file)
          .then((e) {
        setState(() {
          _completeUpload = true;
        });
      });
    } else {
      firebase_storage.FirebaseStorage.instance
          .ref('uploads/' + filename)
          // .putString(uint8List, format: firebase_storage.PutStringFormat.base64)
          .putData(uint8List)
          .then((e) {
        setState(() {
          _completeUpload = true;
        });
      });
    }
  }

  void _submit({
    String? filename,
    Uint8List? uint8List,
    File? file,
    String? name,
    String? brand,
    String? categoryId,
    String? categoryTmp,
    String? subCategoryId,
    String? subCategoryTmp,
    List<String>? indicationsIds,
    List<String>? indicationsTmp,
    List<String>? precautions,
    List<String>? ingredients,
    List<String>? cookbook,
    List<String>? tagsIds,
    List<String>? tagsTmp,
    String? tagPicture,
    bool save = false,
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
      _product.tagPicture = tagPicture.isNotEmpty ? tagPicture : null;
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

      CollectionReference collection =
          FirebaseFirestore.instance.collection('products');

      collection.add({
        'picture': _product.filename,
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
        'enabled': true,
      }).then((docRef) {
        setState(() {
          _completeSubmit = docRef.id;
        });
      }).catchError((error) {});
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
