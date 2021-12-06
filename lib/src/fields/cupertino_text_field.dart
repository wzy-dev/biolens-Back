import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCupertinoTextField extends StatelessWidget {
  const CustomCupertinoTextField(
      {Key? key,
      required this.value,
      required this.node,
      this.onEditingComplete,
      required this.onChanged,
      this.controller})
      : super(key: key);

  final String? value;
  final FocusScopeNode node;
  final Function? onEditingComplete;
  final void Function(String) onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    Color _cursorColor(String? value) {
      if (value?.isEmpty ?? false) {
        return CupertinoColors.destructiveRed;
      } else {
        return Theme.of(context).primaryColor;
      }
    }

    BoxDecoration _textInputDecoration(String? value) {
      if (value?.isEmpty ?? false) {
        // If empty > Box danger
        return BoxDecoration(
          color: Color.fromRGBO(255, 0, 0, 0.05),
          borderRadius: BorderRadius.all(Radius.circular(6)),
          border: Border.all(
            color: CupertinoColors.destructiveRed,
          ),
        );
      } else {
        // If not empty > Box ok
        return BoxDecoration(
          // color: CupertinoColors.lightBackgroundGray,
          borderRadius: BorderRadius.all(Radius.circular(6)),
          border: Border.all(
            color: CupertinoColors.systemGrey,
          ),
        );
      }
    }

    return CupertinoTextField(
      autofocus: true,
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      onEditingComplete: () {
        if (onEditingComplete is Function) {
          onEditingComplete!();
        } else {
          node.nextFocus();
        }
      },
      decoration: _textInputDecoration(value),
      onChanged: onChanged,
      style: TextStyle(fontSize: 16),
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      cursorColor: _cursorColor(value),
    );
  }
}
