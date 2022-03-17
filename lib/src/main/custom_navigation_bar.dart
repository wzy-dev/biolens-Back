import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeaderItem {
  const HeaderItem(
      {required this.label,
      required this.action,
      this.webOnly = false,
      this.isDefaultAction = false,
      this.isDestructiveAction = false});

  final String label;
  final Function() action;
  final bool webOnly;
  final bool isDefaultAction;
  final bool isDestructiveAction;
}

class CustomNavigationBar {
  static bool isDesktopWidth(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return screenWidth > 800;
  }

  static bool breakpoint(BuildContext context) =>
      MediaQuery.of(context).size.width > 800;

  static Widget drawLogo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: SvgPicture.asset(
        'assets/logo.svg',
        width: isDesktopWidth(context) ? 100 : null,
        semanticsLabel: 'biolens',
        color: CupertinoTheme.of(context).primaryColor,
      ),
    );
  }

  static draw({
    required BuildContext context,
    Widget? leading,
    required Widget middle,
    List<HeaderItem> trailingList = const [],
    Widget? trailingOnly,
  }) {
    return CupertinoNavigationBar(
      leading: isDesktopWidth(context)
          ? leading != null
              ? Align(alignment: Alignment.centerLeft, child: middle)
              : Navigator.of(context).canPop()
                  ? CupertinoButton(
                      padding: const EdgeInsets.only(left: 15, top: 3),
                      child: Text("Retour"),
                      onPressed: () => Navigator.of(context).pop())
                  : SizedBox()
          : leading != null
              ? Container(width: 50, child: leading)
              : Navigator.of(context).canPop()
                  ? null
                  : Container(width: 50, child: leading),
      middle: leading != null && isDesktopWidth(context) ? SizedBox() : middle,
      trailing: trailingOnly != null
          ? trailingOnly
          : isDesktopWidth(context)
              ? Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: trailingList
                        .where((e) => !e.webOnly || (e.webOnly && kIsWeb))
                        .map<Widget>(
                          (e) => CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            onPressed: () => e.action(),
                            child: Text(
                              e.label,
                              style: TextStyle(
                                fontWeight:
                                    e.isDefaultAction ? FontWeight.w900 : null,
                                color: e.isDestructiveAction
                                    ? CupertinoColors.destructiveRed
                                    : null,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              : trailingList.length > 0
                  ? Container(
                      width: 50,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                          child: Icon(
                            CupertinoIcons.ellipsis_vertical_circle,
                            color: CupertinoTheme.of(context).primaryColor,
                            size: 25,
                          ),
                          minSize: 25,
                          padding: EdgeInsets.zero,
                          onPressed: () => showCupertinoModalPopup(
                            context: context,
                            builder: (context) => CupertinoActionSheet(
                              actions: [
                                ...trailingList
                                    .where((e) =>
                                        !e.webOnly || (e.webOnly && kIsWeb))
                                    .map<Widget>(
                                      (e) => CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          e.action();
                                        },
                                        child: Text(e.label),
                                        isDefaultAction: e.isDefaultAction,
                                        isDestructiveAction:
                                            e.isDestructiveAction,
                                      ),
                                    )
                                    .toList(),
                              ],
                              cancelButton: CupertinoActionSheetAction(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("Fermer"),
                                isDestructiveAction: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
    );
  }
}
