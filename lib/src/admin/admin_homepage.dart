import 'package:biolensback/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AdminHomepage extends StatefulWidget {
  AdminHomepage({key}) : super(key: key);

  @override
  _AdminHomepageState createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  String _query = '';
  List<dynamic> _listResults = [];
  Widget? _versionWidget;
  late final Stream<QuerySnapshot> _productsStream;

  @override
  void initState() {
    _drawVersionWidget();
    _productsStream = FirebaseFirestore.instance
        .collection('products')
        .where("enabled", isEqualTo: true)
        .orderBy("name")
        .snapshots();

    super.initState();
  }

  // Affiche le numéro de version dans le header
  void _drawVersionWidget() async {
    PackageInfo.fromPlatform().then(
      (PackageInfo value) => setState(
        () => _versionWidget = Text(
          value.version,
          style: TextStyle(color: CupertinoColors.inactiveGray),
        ),
      ),
    );
  }

  // Permet l'export de la DB en PDF
  HeaderItem _drawExport(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<Map<String, dynamic>> products = [];
    snapshot.data!.docs.forEach((QueryDocumentSnapshot document) {
      products.add(document.data() as Map<String, dynamic>);
    });

    return ExportPdf.exportToPdf(
      products,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return CupertinoPageScaffold(
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          }

          _listResults =
              SearchProcess.searchByName(query: _query, snapshot: snapshot);

          return CupertinoPageScaffold(
            navigationBar: CustomNavigationBar.draw(
              context: context,
              leading: Align(
                alignment: Alignment.centerLeft,
                child: _versionWidget,
              ),
              middle: CustomNavigationBar.breakpoint(context)
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CustomNavigationBar.drawLogo(context),
                        Padding(
                          padding: const EdgeInsets.only(left: 3, bottom: 5),
                          child: _versionWidget ?? SizedBox(),
                        )
                      ],
                    )
                  : CustomNavigationBar.drawLogo(context),
              trailingList: [
                HeaderItem(
                  label: "Mode universitaire",
                  action: () => Navigator.of(context).pushNamed('/university'),
                  isDefaultAction: true,
                ),
                _drawExport(snapshot),
                HeaderItem(
                  label: "A propos",
                  action: () => Navigator.of(context).pushNamed('/about'),
                ),
                HeaderItem(
                  label: "Se déconnecter",
                  action: () => FirebaseAuth.instance.signOut(),
                  isDestructiveAction: true,
                ),
              ],
            ),
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 30, top: 10, right: 30, bottom: 0),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
                                child: CupertinoSearchTextField(
                                  padding: EdgeInsets.all(10),
                                  prefixInsets:
                                      EdgeInsets.fromLTRB(10, 10, 0, 10),
                                  suffixInsets:
                                      EdgeInsets.fromLTRB(0, 10, 10, 10),
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
                                  key: Key("${_listResults.length}"),
                                  list: _listResults,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                                child: CupertinoButton(
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/add');
                                  },
                                  child: Text('Ajouter un produit'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
