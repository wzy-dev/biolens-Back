import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.value,
    this.node,
    this.onEditingComplete,
    required this.onChanged,
    this.controller,
    this.autofocus = true,
    this.isNullable = false,
  }) : super(key: key);

  final String? value;
  final bool autofocus;
  final bool isNullable;
  final FocusScopeNode? node;
  final Function? onEditingComplete;
  final void Function(String) onChanged;
  final TextEditingController? controller;

  Color _cursorColor(BuildContext context, String? value) {
    if (!isNullable && (value?.isEmpty ?? false)) {
      return CupertinoColors.destructiveRed;
    } else {
      return Theme.of(context).primaryColor;
    }
  }

  BoxDecoration _textInputDecoration(String? value) {
    if (!isNullable && (value?.isEmpty ?? false)) {
      // If empty > Box danger
      return BoxDecoration(
        color: Color.fromRGBO(255, 0, 0, 0.05),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: CupertinoColors.destructiveRed,
        ),
      );
    } else {
      // If not empty > Box ok
      return BoxDecoration(
        // color: CupertinoColors.lightBackgroundGray,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: CupertinoColors.systemGrey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _textInputDecoration(value),
      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: TextField(
        autofocus: autofocus,
        textCapitalization: TextCapitalization.sentences,
        controller: controller,
        onEditingComplete: () {
          if (onEditingComplete is Function) {
            onEditingComplete!();
          } else if (node != null) {
            node!.nextFocus();
          }
        },
        onChanged: onChanged,
        style: TextStyle(
            color: CupertinoTheme.of(context).textTheme.textStyle.color,
            fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        cursorColor: _cursorColor(context, value),
      ),
    );
  }
}
