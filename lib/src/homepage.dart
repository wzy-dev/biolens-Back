import 'package:biolensback/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Homepage extends StatefulWidget {
  Homepage(this.snapshot, {key}) : super(key: key);
  final AsyncSnapshot<QuerySnapshot<Object?>> snapshot;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _query = '';

  Export? _drawExport(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!kIsWeb) return null;

    List<Map<String, dynamic>> products = [];
    snapshot.data!.docs.forEach((QueryDocumentSnapshot document) {
      products.add(document.data() as Map<String, dynamic>);
    });

    return Export(
      products: products,
    );
  }

  Future<String> buildNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Container(
          width: 60,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FutureBuilder<String>(
              future: buildNumber(),
              builder: (context, snapshot) {
                return Text(
                    (snapshot.connectionState == ConnectionState.done &&
                            snapshot.data != null)
                        ? snapshot.data!
                        : "",
                    style: TextStyle(color: CupertinoColors.inactiveGray));
              },
            ),
          ),
        ),
        middle: Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: SvgPicture.asset(
            'assets/logo.svg',
            semanticsLabel: 'biolens',
            color: Theme.of(context).primaryColor,
          ),
        ),
        trailing: Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Container(
            width: 60,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _drawExport(widget.snapshot) ?? SizedBox(),
                SizedBox(width: 10),
                CupertinoButton(
                  minSize: 25,
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pushNamed('/privacy'),
                  child: Icon(
                    CupertinoIcons.info_circle,
                    color: Theme.of(context).primaryColor,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
              child: CupertinoSearchTextField(
                padding: EdgeInsets.all(10),
                prefixInsets: EdgeInsets.fromLTRB(10, 10, 0, 10),
                suffixInsets: EdgeInsets.fromLTRB(0, 10, 10, 10),
                style: TextStyle(fontSize: 15),
                placeholder: 'Rechercher',
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ProductsList(
                list: Search.searchByName(
                    query: _query, snapshot: widget.snapshot),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: CupertinoButton(
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pushNamed('/add');
                },
                child: Text('Ajouter un produit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
