import 'package:biolensback/shelf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductsList extends StatelessWidget {
  final List list;

  ProductsList({required this.list});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: list.map((dynamic document) {
        Map _data = document.item;
        return Material(
          type: MaterialType.transparency,
          child: CupertinoButton(
            child: ListTile(
              title: Text(_data['name'],
                  style: CupertinoTheme.of(context).textTheme.textStyle),
              subtitle: Text(
                _data['brand'],
                style: TextStyle(
                  color: CupertinoColors.systemGrey2,
                  fontSize: 12,
                ),
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
      }).toList(),
    );
  }
}
