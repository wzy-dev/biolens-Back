import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RichTextField extends StatelessWidget {
  const RichTextField({
    Key? key,
    required FocusNode focus,
    required TextEditingController? controller,
  })  : _focus = focus,
        _controller = controller,
        super(key: key);

  final FocusNode _focus;
  final TextEditingController? _controller;

  _addEffet(String nameEffect) {
    int start = _controller!.value.selection.start;
    int end = _controller!.value.selection.end;

    if (_controller!.text.substring(
                start - (2 + nameEffect.length) >= 0
                    ? start - (2 + nameEffect.length)
                    : 0,
                start) ==
            "[$nameEffect]" &&
        _controller!.text.substring(end, end + (3 + nameEffect.length)) ==
            "[/$nameEffect]") {
      int nbMatches = RegExp("\\[/$nameEffect\\]\n\\[$nameEffect\\]")
          .allMatches(_controller!.text.substring(start, end))
          .length;

      String newString = _controller!.text.substring(start, end);

      _controller!.text = _controller!.text.replaceRange(
          start - (2 + nameEffect.length),
          end + (3 + nameEffect.length),
          newString);
      _controller!.text = _controller!.text
          .replaceAll(RegExp("\\[/$nameEffect\\]\n\\[$nameEffect\\]"), "\n");

      _focus.requestFocus();

      _controller!.selection = TextSelection(
        baseOffset: start - (2 + nameEffect.length),
        extentOffset: end -
            (2 + nameEffect.length) -
            (nameEffect.length * 2 + 5) * nbMatches,
      );

      return;
    }
    int nbMatches =
        RegExp("\n").allMatches(_controller!.text.substring(start, end)).length;

    String newString =
        "[$nameEffect]${_controller!.text.substring(start, end).replaceAll("\n", "[/$nameEffect]\n[$nameEffect]")}[/$nameEffect]";

    _controller!.text = _controller!.text.replaceRange(start, end, newString);

    _focus.requestFocus();

    _controller!.selection = TextSelection(
      baseOffset: start + (2 + nameEffect.length),
      extentOffset: end +
          (2 + nameEffect.length) +
          (nameEffect.length * 2 + 5) * nbMatches,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.sentences,
          minLines: 3,
          maxLines: null,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
          ),
          selectionHeightStyle: BoxHeightStyle.max,
          style: TextStyle(
            color: CupertinoTheme.of(context).textTheme.textStyle.color,
          ),
          focusNode: _focus,
        ),
        Divider(
          color: CupertinoColors.systemGrey2,
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              child: InkWell(
                child: Icon(CupertinoIcons.bold),
                onTap: () => _addEffet("b"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              child: InkWell(
                child: Icon(CupertinoIcons.italic),
                onTap: () => _addEffet("i"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              child: InkWell(
                child: Icon(CupertinoIcons.underline),
                onTap: () => _addEffet("u"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
