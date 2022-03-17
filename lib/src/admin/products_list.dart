import 'package:biolensback/shelf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProductsList extends StatefulWidget {
  final List list;

  ProductsList({Key? key, required this.list}) : super(key: key);

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  late List<Widget?> _listImages;

  @override
  void initState() {
    _listImages = List<Widget?>.generate(widget.list.length, (index) => null);
    super.initState();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<void> _downloadImage(int index, String? filename) async {
    String? downloadURL = filename != null
        ? await firebase_storage.FirebaseStorage.instance
            .ref('uploads/' + filename)
            .getDownloadURL()
        : null;

    setStateIfMounted(() {
      _listImages[index] = filename != null
          ? SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Color.fromRGBO(190, 190, 190, 0.1),
                  child: Image.network(
                    downloadURL!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          : SizedBox(
              width: 80,
              height: 80,
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      primary: true,
      itemCount: widget.list.length,
      itemBuilder: (context, index) {
        Map _data = widget.list[index].item;
        if (_listImages[index] == null) {
          _downloadImage(index, _data["picture"]);
        }

        return Material(
          type: MaterialType.transparency,
          child: CupertinoButton(
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Row(
                children: [
                  _listImages[index] ?? SizedBox(width: 80, height: 80),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(_data['name'],
                            style:
                                CupertinoTheme.of(context).textTheme.textStyle),
                        SizedBox(height: 8),
                        Text(
                          _data['brand'],
                          style: TextStyle(
                            color: CupertinoColors.systemGrey2,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            padding: EdgeInsets.all(0),
            onPressed: () {
              Navigator.pushNamed(
                context,
                "/viewer/" + _data['id'],
                arguments: ProductViewerArguments(product: _data),
              );
            },
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(
        color: CupertinoColors.systemGrey,
        thickness: 0.3,
      ),
    );
  }
}
