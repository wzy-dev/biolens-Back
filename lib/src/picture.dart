import 'dart:async';

import 'package:biolensback/shelf.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Picture extends StatefulWidget {
  const Picture({Key? key, required this.path, this.size = 100, this.identity})
      : super(key: key);

  final String path;
  final double size;
  final Widget? identity;

  @override
  _PictureState createState() => _PictureState();
}

class _PictureState extends State<Picture> {
  Image? _picture;
  Image? _heroPicture;

  @override
  void initState() {
    super.initState();

    _downloadImage(widget.path);
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<void> _downloadImage(String filename) async {
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('uploads/' + filename)
        .getDownloadURL();

    setStateIfMounted(() {
      _picture = Image.network(
        downloadURL,
        width: widget.size - 20,
        height: widget.size - 20,
        fit: BoxFit.cover,
      );
    });

    _heroPicture = Image.network(
      downloadURL,
      width: MediaQuery.of(context).size.width > 800
          ? 800
          : MediaQuery.of(context).size.width - 50,
      height: MediaQuery.of(context).size.width > 800
          ? 800
          : MediaQuery.of(context).size.width - 50,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _picture != null
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => ViewerPicture(
                      tag: "picture${widget.path}",
                      picture: _heroPicture,
                      identity: widget.identity,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: "picture${widget.path}",
                transitionOnUserGestures: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Color.fromRGBO(190, 190, 190, 0.1),
                    child: _picture,
                  ),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(190, 190, 190, 0.1),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              width: widget.size,
              height: widget.size,
              child: CupertinoActivityIndicator(),
            ),
    );
  }
}
