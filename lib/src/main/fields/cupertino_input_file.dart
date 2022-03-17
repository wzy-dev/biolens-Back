import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' as kIsWeb;

class CupertinoInputFile extends StatefulWidget {
  const CupertinoInputFile(
      {Key? key, this.path, this.loadingImage = false, required this.onChanged})
      : super(key: key);

  final String? path;
  final bool? loadingImage;
  final Function onChanged;

  @override
  _CupertinoInputFileState createState() => _CupertinoInputFileState();
}

class _CupertinoInputFileState extends State<CupertinoInputFile> {
  Image? _picture;
  final double size = 120;
  late bool _loader;

  @override
  void initState() {
    super.initState();

    if (widget.path != null) {
      _loader = true;
      _downloadImage(widget.path!);
    } else {
      _loader = false;
    }
  }

  Future<void> _downloadImage(String filename) async {
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('uploads/' + filename)
        .getDownloadURL();

    setState(() {
      _picture = Image.network(
        downloadURL,
        width: size - 20,
        height: size - 20,
        fit: BoxFit.cover,
      );
    });
  }

  _imgFromGallery() async {
    XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxHeight: 800,
      maxWidth: 800,
    );

    String uuid = Uuid().v4();
    String extension = path.extension(image!.path);
    String filename = uuid + extension;
    Uint8List uint8List = await image.readAsBytes();
    File? file;

    if (kIsWeb.kIsWeb) {
      setState(() {
        _picture = Image.network(
          image.path,
          width: size - 20,
          height: size - 20,
          fit: BoxFit.cover,
        );
      });
    } else {
      file = File(image.path);
      setState(() {
        _picture = Image.file(
          file!,
          width: size - 20,
          height: size - 20,
          fit: BoxFit.cover,
        );
      });
    }

    widget.onChanged(filename: filename, uint8List: uint8List, file: file);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
      child: Center(
        child: GestureDetector(
          onTap: () {
            _imgFromGallery();
          },
          child: _picture != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Color.fromRGBO(190, 190, 190, 0.1),
                    child: _picture,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(190, 190, 190, 0.1),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  width: size,
                  height: size,
                  child: _loader
                      ? CupertinoActivityIndicator()
                      : Icon(
                          Icons.camera_alt,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                ),
        ),
      ),
    );
  }
}
