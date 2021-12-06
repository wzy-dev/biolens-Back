import 'package:flutter/cupertino.dart';

class CustomCupertinoFieldsGroup extends StatelessWidget {
  const CustomCupertinoFieldsGroup({
    required this.title,
    required this.body,
    this.paddingTitle = const EdgeInsets.all(0),
    this.help,
    this.paddingHelp = const EdgeInsets.all(0),
  });

  final String title;
  final Widget body;
  final EdgeInsets paddingTitle;
  final EdgeInsets paddingHelp;
  final String? help;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            child: Text(
              title,
              style: CupertinoTheme.of(context)
                  .textTheme
                  .textStyle
                  .merge(TextStyle(fontSize: 12)),
            ),
            padding: paddingTitle),
        SizedBox(height: 10),
        body,
        (help != null
            ? Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Padding(
                  padding: paddingHelp,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.info_circle,
                        color: CupertinoColors.inactiveGray,
                        size: 15,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        help!,
                        style: TextStyle(
                          color: CupertinoColors.inactiveGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container()),
        SizedBox(height: 20),
      ],
    );
  }
}
