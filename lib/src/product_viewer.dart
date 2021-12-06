import 'package:biolensback/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductViewerArguments {
  final Map? product;

  ProductViewerArguments({this.product});
}

class ProductViewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RouteArgs? routeArgs =
        ModalRoute.of(context)!.settings.arguments as RouteArgs;
    final ProductViewerArguments? arguments =
        routeArgs?.arguments as ProductViewerArguments;
    final Map? productArg = arguments?.product ?? null;
    final String? idParam = routeArgs?.parameter;

    _removeAction({
      required String id,
      required String name,
    }) {
      showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: Text('Êtes-vous sûr de vouloir supprimer "$name" ?'),
                content: Text(
                    'Vous êtes sur le point de supprimer le produit "$name", cette action est irréversible.'),
                actions: [
                  CupertinoButton(
                      child: Text('Annuler'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  CupertinoButton(
                      child: Text('Supprimer',
                          style:
                              TextStyle(color: CupertinoColors.destructiveRed)),
                      onPressed: () {
                        CollectionReference collection =
                            FirebaseFirestore.instance.collection('products');

                        collection
                            .doc(id)
                            .update({
                              'enabled': false,
                              'editedAt': DateTime.now().millisecondsSinceEpoch,
                            })
                            .then((name) => print("Product Removed"))
                            .catchError((error) =>
                                print("Failed to update option: $error"));

                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }),
                ],
              ));
    }

    Column _drawList(List? list, {required Row title}) {
      List<Widget> children = [
        title,
        SizedBox(
          height: 5,
        )
      ];

      if (list == null || list.length == 0) {
        return Column();
      }

      for (var item in list) {
        children.add(Text(
          "• " + item,
          style: TextStyle(color: CupertinoColors.systemGrey2),
        ));
      }

      children.add(
        SizedBox(
          height: 20,
        ),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    Column _drawIdentity(product) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                product['name'].toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                product['brand'],
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            product['names']['category'].toLowerCase() +
                " > " +
                product['names']['subCategory'].toLowerCase(),
            style: TextStyle(color: CupertinoColors.systemGrey2),
          ),
        ],
      );
    }

    Padding _drawViewer(Map product) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Row(
              children: [
                product['picture'] != null
                    ? Picture(
                        path: product['picture'],
                        identity: _drawIdentity(product),
                      )
                    : Container(),
                SizedBox(
                  width: product['picture'] != null ? 13 : 0,
                ),
                Expanded(
                  child: _drawIdentity(product),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            _drawList(
              product['names']['indications'],
              title: Row(
                children: [
                  Icon(
                    CupertinoIcons.check_mark,
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                    size: 20,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    'Indications'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
            _drawList(
              product['precautions'],
              title: Row(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                    size: 20,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    'Précautions :'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
            _drawList(
              product['ingredients'],
              title: Row(
                children: [
                  Icon(
                    CupertinoIcons.wrench,
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                    size: 20,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    'Composition :'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
            _drawList(
              product['cookbook'],
              title: Row(
                children: [
                  Icon(
                    CupertinoIcons.list_bullet,
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                    size: 20,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    'Utilisation :'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
            CupertinoButton(
                color: Theme.of(context).primaryColor,
                child: Text('Modifier ce produit'),
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => EditProduct(product: product),
                    ),
                  );
                }),
            CupertinoButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.trash,
                    color: CupertinoColors.destructiveRed,
                    size: 16,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Supprimer ce produit',
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                ],
              ),
              onPressed: () {
                _removeAction(
                  id: product['id'],
                  name: product['name'],
                );
              },
            )
          ],
        ),
      );
    }

    CupertinoPageScaffold _drawScaffold(Widget child) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Résumé'),
        ),
        child: DefaultTextStyle(
          style: CupertinoTheme.of(context).textTheme.textStyle,
          child: SafeArea(child: child),
        ),
      );
    }

    if (productArg == null) {
      CollectionReference products =
          FirebaseFirestore.instance.collection('products');

      return FutureBuilder<DocumentSnapshot>(
        future: products.doc(idParam).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return _drawScaffold(
                Center(child: Text("Une erreur est survenue")));
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return _drawScaffold(
                Center(child: Text("Ce document n'existe pas")));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            data['id'] = idParam;
            return _drawScaffold(_drawViewer(data));
          }

          return _drawScaffold(Center(child: CupertinoActivityIndicator()));
        },
      );
    }

    return _drawScaffold(_drawViewer(productArg));
  }
}
