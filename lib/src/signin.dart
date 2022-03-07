import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _controllerMail = TextEditingController();
  final _controllerPassword = TextEditingController();
  bool _errorMail = false;
  bool _errorPassword = false;
  String _info = "";

  BoxDecoration _textInputDecoration(bool error) {
    if (error == true) {
      // If error > Box danger
      return BoxDecoration(
        color: Color.fromRGBO(255, 0, 0, 0.05),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: CupertinoColors.destructiveRed,
        ),
      );
    } else {
      // If not error > Box ok
      return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: CupertinoColors.systemGrey,
        ),
      );
    }
  }

  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _controllerMail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _errorMail = true;
          _info = "";
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _errorMail = true;
          _errorPassword = true;
          _info = "";
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _controllerMail.text);
      setState(() {
        _errorMail = false;
        _errorPassword = false;
        _info = "Mail envoyé à l'adresse sélectionnée";
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'missing-email' ||
          e.code == 'invalid-email') {
        setState(() {
          _errorMail = true;
          _errorPassword = false;
          _info = "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Container(
          width: 25,
        ),
        middle: Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: SvgPicture.asset(
            'assets/logo.svg',
            semanticsLabel: 'biolens',
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pushNamed('/about'),
              child: Icon(
                CupertinoIcons.info_circle,
                color: CupertinoTheme.of(context).primaryColor,
                size: 25,
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: EdgeInsets.all(30),
              child: AutofillGroup(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      child: SvgPicture.asset(
                        'assets/logo.svg',
                        semanticsLabel: 'biolens',
                        color: CupertinoTheme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      height: 50,
                      child: Container(
                        decoration: _textInputDecoration(_errorMail),
                        child: Row(
                          children: [
                            Padding(
                              child: Icon(CupertinoIcons.mail),
                              padding: EdgeInsets.all(10),
                            ),
                            Expanded(
                              child: TextField(
                                onEditingComplete: () {
                                  node.nextFocus();
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Adresse mail',
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                controller: _controllerMail,
                                autofillHints: [AutofillHints.email],
                                style: TextStyle(
                                  color: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle
                                      .color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50,
                      child: Container(
                        decoration: _textInputDecoration(_errorPassword),
                        child: Row(
                          children: [
                            Padding(
                              child: Icon(CupertinoIcons.lock),
                              padding: EdgeInsets.all(10),
                            ),
                            Expanded(
                              child: TextField(
                                onEditingComplete: () => _signIn(),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Mot de passe',
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                controller: _controllerPassword,
                                autofillHints: [AutofillHints.password],
                                style: TextStyle(
                                  color: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle
                                      .color,
                                ),
                                obscureText: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      height: 55,
                      child: CupertinoButton(
                        color: CupertinoTheme.of(context).primaryColor,
                        child: Text('Connexion'),
                        onPressed: _signIn,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    CupertinoButton(
                      child: Text('Mot de passe oublié'),
                      onPressed: _resetPassword,
                    ),
                    Text(
                      _info,
                      style: TextStyle(color: CupertinoColors.activeGreen),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
