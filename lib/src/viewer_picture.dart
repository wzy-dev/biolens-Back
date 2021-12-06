import 'package:flutter/cupertino.dart';

class ViewerPicture extends StatefulWidget {
  const ViewerPicture({
    Key? key,
    required this.picture,
    this.identity,
  }) : super(key: key);

  final Image? picture;
  final Widget? identity;

  @override
  _ViewerPictureState createState() => _ViewerPictureState();
}

class _ViewerPictureState extends State<ViewerPicture> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Hero(
                          tag: 'picture',
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
    );
  }
}
