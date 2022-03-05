import 'package:biolensback/shelf.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreamProduct extends StatelessWidget {
  const StreamProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
        .collection('products')
        .where("enabled", isEqualTo: true)
        .orderBy("name")
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _productsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.active) {
          return Homepage(snapshot);
        }

        return CupertinoPageScaffold(
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        );
      },
    );
  }
}
