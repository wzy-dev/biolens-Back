import 'package:biolensback/shelf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductsList extends StatelessWidget {
  final List list;

  ProductsList({required this.list});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (context, index) {
        Map _data = list[index].item;
        return Material(
          type: MaterialType.transparency,
          child: CupertinoButton(
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Row(
                children: [
                  _data['picture'] != null
                      ? Picture(
                          size: 80,
                          path: _data['picture'],
                        )
                      : SizedBox(
                          width: 80,
                          height: 80,
                        ),
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
