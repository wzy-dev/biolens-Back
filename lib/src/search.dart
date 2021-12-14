import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:fuzzy/fuzzy.dart';

class Search {
  static String escape(String query) {
    List<String> escapeList = [
      "(",
      ")",
      "[",
      "]",
      "{",
      "}",
      "*",
      "+",
      "?",
      ".",
      "^",
      "\$",
      "|",
      "\\"
    ];

    String result = query;
    escapeList.forEach((escapeWord) {
      result = result.replaceAll(escapeWord, "");
    });

    return result;
  }

  static searchByName(
      {required String query,
      required AsyncSnapshot<QuerySnapshot<Object?>> snapshot}) {
    List<Map> _searchList = [];

    snapshot.data!.docs.forEach((DocumentSnapshot document) {
      Map _data = (document.data() as Map);
      _searchList.add({..._data, 'id': document.id});
    });

    _searchList.sort(
        (a, b) => a["name"].toLowerCase().compareTo(b["name"].toLowerCase()));

    var options = FuzzyOptions(
      keys: [
        WeightedKey(
            name: 'name',
            getter: (e) {
              return (e as Map)['name'];
            },
            weight: 2)
      ],
    );

    final fuse = Fuzzy(_searchList, options: options);

    final result = fuse.search(escape(query));

    return result;
  }
}
