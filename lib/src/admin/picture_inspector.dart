import 'package:flutter/cupertino.dart';

class PictureInspector extends StatefulWidget {
  const PictureInspector({
    Key? key,
    required this.tag,
    required this.picture,
    this.identity,
  }) : super(key: key);

  final String tag;
  final Image? picture;
  final Widget? identity;

  @override
  _PictureInspectorState createState() => _PictureInspectorState();
}

class _PictureInspectorState extends State<PictureInspector> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Hero(
                                tag: widget.tag,
                                transitionOnUserGestures: true,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    color: Color.fromRGBO(190, 190, 190, 0.1),
                                    child: widget.picture,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(25),
                              child: widget.identity ?? Container(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.all(40),
                    child: Text('Retour'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
