import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSelectOptionMultiple extends StatefulWidget {
  final String id;
  final String name;
  final Function renameAction;
  final Function removeAction;
  final Function rename;
  final Function touchAction;
  final bool enabled;

  const CustomSelectOptionMultiple({
    Key? key,
    required this.id,
    required this.name,
    required this.renameAction,
    required this.removeAction,
    required this.rename,
    required this.touchAction,
    required this.enabled,
  });

  @override
  _CustomSelectOptionMultipleState createState() =>
      _CustomSelectOptionMultipleState();
}

class _CustomSelectOptionMultipleState
    extends State<CustomSelectOptionMultiple> {
  late TextEditingController _controller;
  bool _enabled = false;
  late FocusNode _focusNode;
  late String _savedValue;
  // late bool widget.enabled;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.name);
    // widget.enabled = widget.enabled;
    _savedValue = widget.name;
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(CustomSelectOptionMultiple oldWidget) {
    super.didUpdateWidget(oldWidget);

    _controller = TextEditingController(text: widget.name);
    _savedValue = widget.name;
    _focusNode = FocusNode();
    // widget.enabled = widget.enabled;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  void _renameAction() {
    widget.renameAction(id: widget.id, name: _controller.text);
    widget.rename(oldName: _savedValue, newName: _controller.text);
    setState(() {
      _enabled = false;
    });
    _savedValue = _controller.text;
  }

  IconButton _leftButton() {
    if (_enabled == false) {
      return IconButton(
        key: ValueKey('pencil'),
        onPressed: () {
          setState(() {
            _enabled = true;
          });

          // ignore: todo
          //TODO : Realtime
          Future.delayed(const Duration(milliseconds: 100), () {
            _focusNode.requestFocus();
          });
        },
        color: Theme.of(context).primaryColor,
        iconSize: 28,
        icon: Icon(
          CupertinoIcons.pencil,
        ),
      );
    } else {
      return IconButton(
        key: ValueKey('checkmark'),
        onPressed: _renameAction,
        color: CupertinoColors.systemGreen,
        iconSize: 22,
        icon: Icon(
          CupertinoIcons.checkmark,
        ),
      );
    }
  }

  IconButton _rightButton() {
    if (_enabled == false) {
      return IconButton(
        key: ValueKey('trash'),
        onPressed: () {
          widget.removeAction(id: widget.id, name: _controller.text);
        },
        color: CupertinoColors.destructiveRed,
        iconSize: 20,
        icon: Icon(
          CupertinoIcons.trash,
        ),
      );
    } else {
      return IconButton(
        key: ValueKey('multiply'),
        onPressed: () {
          _controller.text = _savedValue;
          setState(() {
            _enabled = false;
          });
        },
        color: CupertinoColors.destructiveRed,
        iconSize: 25,
        icon: Icon(
          CupertinoIcons.multiply,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: widget.key,
      title: CupertinoButton(
        onPressed: () {
          if (_enabled == false) {
            widget.touchAction(name: _controller.text, id: widget.id);
          }
        },
        child: Row(
          children: [
            widget.enabled == true
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(CupertinoIcons.check_mark),
                  )
                : SizedBox(),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: _enabled,
                focusNode: _focusNode,
                maxLines: null,
                onEditingComplete: _renameAction,
                decoration: InputDecoration(
                  border: null,
                  fillColor: Colors.transparent,
                ),
                style: TextStyle(
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(child: child, scale: animation);
            },
            duration: const Duration(milliseconds: 200),
            child: _leftButton(),
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: VerticalDivider(
                thickness: 0.8,
                width: 4,
                color: CupertinoColors.systemGrey,
                indent: 15,
                endIndent: 15,
              )),
          AnimatedSwitcher(
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(child: child, scale: animation);
            },
            duration: const Duration(milliseconds: 200),
            child: _rightButton(),
          ),
        ],
      ),
    );
  }
}
