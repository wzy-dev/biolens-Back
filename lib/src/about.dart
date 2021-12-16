import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("À propos..."),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Me contacter ?",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "L'application biolens est développée par Simon Wegrzyn, contactez-moi pour toute information.",
                  style: TextStyle(
                    color: CupertinoColors.systemGrey2,
                    fontWeight: FontWeight.w200,
                    fontSize: 17,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Color.fromRGBO(0, 122, 255, 0.2),
                        ),
                        child: CupertinoButton(
                          padding: const EdgeInsets.all(20),
                          onPressed: () =>
                              launch("mailto:wegrzyn.simon@gmail.com"),
                          child: Column(
                            children: [
                              Icon(
                                CupertinoIcons.mail,
                                color: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .color,
                                size: 50,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "wegrzyn.simon@gmail.com",
                                style: TextStyle(
                                  color: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle
                                      .color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Color.fromRGBO(255, 149, 0, 0.2),
                        ),
                        child: CupertinoButton(
                          padding: const EdgeInsets.all(20),
                          onPressed: () => launch("sms:0620905177"),
                          child: Column(
                            children: [
                              Icon(
                                CupertinoIcons.phone,
                                color: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .color,
                                size: 50,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "06 20 90 51 77",
                                style: TextStyle(
                                  color: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle
                                      .color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
