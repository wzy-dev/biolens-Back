import 'dart:io';
import 'dart:typed_data';

class Product {
  String? filename;
  Uint8List? uint8List;
  File? file;
  String? name;
  String? brand;
  String? categoryTmp;
  String? categoryId;
  String? subCategoryTmp;
  String? subCategoryId;
  List<String> indicationsIds;
  List<String> indicationsTmp;
  List<String>? precautions;
  List<String>? ingredients;
  List<String>? cookbook;
  List<String> tagsIds;
  List<String> tagsTmp;
  String? tagPicture;

  Product({
    this.filename,
    this.uint8List,
    this.name,
    this.brand,
    this.categoryTmp,
    this.categoryId,
    this.subCategoryTmp,
    this.subCategoryId,
    this.indicationsIds = const [],
    this.indicationsTmp = const [],
    this.precautions,
    this.ingredients,
    this.cookbook,
    this.tagsIds = const [],
    this.tagsTmp = const [],
    this.tagPicture,
  });
}
