import 'dart:math';

import 'package:biolensback/shelf.dart';
import 'package:biolensback/src/admin/user_modifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class TestItem {
  const TestItem({required this.value});

  final String value;
}

class UsersManager extends StatefulWidget {
  const UsersManager({Key? key}) : super(key: key);

  @override
  State<UsersManager> createState() => _UsersManagerState();
}

class _UsersManagerState extends State<UsersManager> {
  final Stream<QuerySnapshot> _streamUsers = FirebaseFirestore.instance
      .collection("users")
      .orderBy("email")
      .snapshots();
  Future<QuerySnapshot> _futureListUniversities =
      FirebaseFirestore.instance.collection("universities").get();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar.draw(
          context: context, middle: Text("Modifier un utilisateur")),
      child: SafeArea(
          child: FutureBuilder<QuerySnapshot>(
        future: _futureListUniversities,
        builder: (context, snapshotUniversities) {
          if (snapshotUniversities.connectionState != ConnectionState.done)
            return Center(
              child: CupertinoActivityIndicator(),
            );

          List<QueryDocumentSnapshot> _listUniversities =
              snapshotUniversities.data!.docs;
          return StreamBuilder<QuerySnapshot>(
            stream: _streamUsers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                List<QueryDocumentSnapshot> users = snapshot.data?.docs
                        .where((doc) =>
                            doc.id != FirebaseAuth.instance.currentUser!.uid)
                        .toList() ??
                    [];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: users.map(
                              (user) {
                                Map data = user.data() as Map;
                                return CupertinoButton(
                                  alignment: Alignment.centerLeft,
                                  minSize: 0,
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    _showBottomModal(context,
                                        enabled: data["enabled"],
                                        email: data["email"],
                                        role: data["role"],
                                        universityId: data["university"],
                                        userId: user.id,
                                        listUniversities: _listUniversities);
                                  },
                                  child: UserContainer(
                                    enabled: data["enabled"],
                                    email: data["email"],
                                    role: data["role"],
                                    universityId: data["university"],
                                    userId: user.id,
                                    listUniversities: _listUniversities,
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(
                        height: 1,
                        color: CupertinoColors.systemGrey,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Ajouter un utilisateur",
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: CupertinoColors.systemGrey,
                      ),
                      SizedBox(height: 10),
                      UserForm(
                        listUniversities: _listUniversities,
                      ),
                    ],
                  ),
                );
              }
              return Center(
                child: CupertinoActivityIndicator(),
              );
            },
          );
        },
      )),
    );
  }

  Future<dynamic> _showBottomModal(
    BuildContext context, {
    required bool enabled,
    required String email,
    required String role,
    String? universityId,
    required String userId,
    required List<QueryDocumentSnapshot<Object?>> listUniversities,
  }) {
    return showCupertinoModalPopup(
      barrierColor: Color.fromRGBO(100, 100, 100, 0.5),
      context: context,
      builder: (context) {
        bool _enabled = enabled;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
                decoration: BoxDecoration(
                    color:
                        CupertinoTheme.brightnessOf(context) == Brightness.dark
                            ? CupertinoColors.black
                            : CupertinoColors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                width: double.infinity,
                height: 300,
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      child: Text("Annuler"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UserContainer(
                            enabled: enabled,
                            email: email,
                            role: role,
                            universityId: universityId,
                            listUniversities: listUniversities,
                            userId: userId,
                          ),
                          Container(
                            width: double.infinity,
                            child: CupertinoButton(
                              child: Text("Modifier le rôle"),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            UserModifier(userId: userId)));
                              },
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: _enabled
                                ? CupertinoButton(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.trash,
                                          color: CupertinoColors.destructiveRed,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Révoquer cet utilisateur',
                                          style: TextStyle(
                                              color: CupertinoColors
                                                  .destructiveRed),
                                        ),
                                      ],
                                    ),
                                    onPressed: () async {
                                      if (!await showCupertinoDialog(
                                        context: context,
                                        builder: (context) =>
                                            CupertinoAlertDialog(
                                                title: Text(
                                                    "Êtes-vous sûr de vouloir révoquer cet utilisateur ?"),
                                                content: Text(
                                                  "La désactivation empêchera l'utilisateur $email d'accéder à son compte. Cette action est réversible.",
                                                ),
                                                actions: [
                                              CupertinoDialogAction(
                                                  child: Text("Annuler"),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true)),
                                              CupertinoDialogAction(
                                                child: Text("Supprimer"),
                                                isDestructiveAction: true,
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                              )
                                            ]),
                                      ))
                                        FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(userId)
                                            .update({"enabled": false}).then(
                                                (value) => setState(() {
                                                      _enabled = false;
                                                    }));
                                    },
                                  )
                                : CupertinoButton(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons
                                              .person_crop_circle_badge_checkmark,
                                          color: CupertinoTheme.of(context)
                                              .primaryColor,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Réhabiliter cet utilisateur',
                                          style: TextStyle(
                                            color: CupertinoTheme.of(context)
                                                .primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(userId)
                                          .update({"enabled": true}).then(
                                              (value) => setState(() {
                                                    _enabled = true;
                                                  }));
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ));
          },
        );
      },
    );
  }
}

class UserContainer extends StatelessWidget {
  const UserContainer(
      {Key? key,
      required this.enabled,
      required this.email,
      required this.role,
      this.universityId,
      required this.userId,
      required this.listUniversities})
      : super(key: key);

  final bool enabled;
  final String email;
  final String role;
  final String? universityId;
  final String userId;
  final List<QueryDocumentSnapshot<Object?>> listUniversities;

  @override
  Widget build(BuildContext context) {
    QueryDocumentSnapshot? _university = listUniversities
        .firstWhereOrNull((university) => university.id == universityId);
    return AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: CupertinoColors.systemGrey,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8.0),
                    child: Text(
                      email,
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                width: 150,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  color: Color.fromRGBO(122, 122, 122, 0.2),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        role == "admin" ? "Administrateur" : "Universitaire",
                        textAlign: TextAlign.center,
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                      role == "university" && _university != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                (_university.data() as Map)["name"]
                                    .toUpperCase(),
                                style: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserForm extends StatefulWidget {
  const UserForm({Key? key, required this.listUniversities, this.userData})
      : super(key: key);

  final List<QueryDocumentSnapshot> listUniversities;
  final Map<String, dynamic>? userData;

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  Roles _addedRole = Roles.admin;
  int _addedUniversityIndex = 0;
  TextEditingController _addedEmailController = TextEditingController();

  Future<UserCredential?> _register(
      {required String email, required String password}) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(e);
      // Do something with exception. This try/catch is here to make sure
      // that even if the user creation fails, app.delete() runs, if is not,
      // next time Firebase.initializeApp() will fail as the previous one was
      // not deleted.
    }

    await app.delete();
    return Future.sync(() => userCredential);
  }

  String generatePassword({
    bool letter = true,
    bool isNumber = true,
    bool isSpecial = true,
  }) {
    final length = 10;
    final letterLowerCase = "abcdefghijklmnopqrstuvwxyz";
    final letterUpperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    final number = '0123456789';
    final special = '@#%^*>\$@?/[]=+';

    String chars = "";
    if (letter) chars += '$letterLowerCase$letterUpperCase';
    if (isNumber) chars += '$number';
    if (isSpecial) chars += '$special';

    return List.generate(length, (index) {
      final indexRandom = Random.secure().nextInt(chars.length);
      return chars[indexRandom];
    }).join('');
  }

  @override
  void initState() {
    if (widget.userData != null) {
      _addedRole = Roles.values
          .firstWhere((role) => role.name == widget.userData!["role"]);
      _addedEmailController.text = widget.userData!["email"];

      if (widget.userData!["university"] != null) {
        int index = widget.listUniversities.indexWhere(
            (university) => university.id == widget.userData!["university"]);
        if (index > -1) _addedUniversityIndex = index;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(
                      color: CupertinoTheme.of(context).primaryColor),
                ),
                child: CupertinoButton(
                  color: _addedRole == Roles.admin
                      ? CupertinoTheme.of(context).primaryColor
                      : null,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  child: Text("Administrateur"),
                  onPressed: () => setState(() {
                    _addedRole = Roles.admin;
                  }),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(
                      color: CupertinoTheme.of(context).primaryColor),
                ),
                child: CupertinoButton(
                  color: _addedRole == Roles.university
                      ? CupertinoTheme.of(context).primaryColor
                      : null,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  child: Text("Universitaire"),
                  onPressed: () => setState(() {
                    _addedRole = Roles.university;
                  }),
                ),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            minSize: 0,
            onPressed: () => showCupertinoModalPopup(
                barrierColor: Color.fromRGBO(100, 100, 100, 0.5),
                context: context,
                builder: (context) {
                  return Container(
                    decoration: BoxDecoration(
                        color: CupertinoTheme.brightnessOf(context) ==
                                Brightness.dark
                            ? CupertinoColors.black
                            : CupertinoColors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    width: double.infinity,
                    height: 300,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 22,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: CupertinoButton(
                            child: Text("Confirmer"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            }),
                            child: CupertinoPicker(
                              itemExtent: 60,
                              scrollController: FixedExtentScrollController(
                                  initialItem: _addedUniversityIndex),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _addedUniversityIndex = index;
                                });
                              },
                              children: [
                                ...widget.listUniversities.map(
                                  (university) => Container(
                                    height: 60,
                                    child: Center(
                                      child: Text(
                                        (university.data() as Map)["name"],
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            child: Container(
              height: _addedRole == Roles.university ? 50 : 0,
              width: double.infinity,
              margin: _addedRole == Roles.university
                  ? const EdgeInsets.only(top: 8)
                  : null,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                border: Border.all(
                  color: CupertinoColors.systemGrey,
                ),
              ),
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.arrowtriangle_down_circle,
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.listUniversities.length > 0
                          ? (widget.listUniversities[_addedUniversityIndex]
                              .data() as Map)["name"]
                          : "",
                      style: TextStyle(
                          color: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .color,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              color: CupertinoColors.systemGrey,
            ),
          ),
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _addedEmailController,
              enabled: widget.userData == null,
              minLines: 1,
              maxLines: 1,
              onChanged: (value) => setState(() {}),
              style: TextStyle(
                color: widget.userData == null
                    ? CupertinoTheme.of(context).textTheme.textStyle.color
                    : CupertinoColors.systemGrey,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: "utilisateur@email.com",
                hintStyle: TextStyle(color: CupertinoColors.systemGrey),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        CupertinoButton(
          child: widget.userData != null
              ? Text("Modifier un utilisateur")
              : Text("Ajouter un utilisateur"),
          color: CupertinoTheme.of(context).primaryColor,
          onPressed: _addedEmailController.text.length > 0 &&
                  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(_addedEmailController.text)
              ? () {
                  Map<String, dynamic> userData = {
                    "email": _addedEmailController.text,
                    "role": _addedRole.name,
                    "enabled": true,
                  };

                  if (_addedRole == Roles.university)
                    userData["university"] =
                        widget.listUniversities[_addedUniversityIndex].id;

                  if (widget.userData != null) {
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(widget.userData!["id"])
                        .update(userData);
                    Navigator.of(context).pop();
                    return;
                  }

                  String password = generatePassword();
                  _register(
                    email: _addedEmailController.text,
                    password: password,
                  ).then(
                    (user) {
                      if (user == null) return null;

                      return FirebaseFirestore.instance
                          .collection("users")
                          .doc(user.user!.uid)
                          .set(userData)
                          .then((value) => setState(() {
                                String email = _addedEmailController.text;
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: Text("Nouvel utilisateur créé !"),
                                    content: Column(
                                      children: [
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: Text(
                                                  "Email : ",
                                                  textAlign: TextAlign.start,
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: SelectableText(
                                                email,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.start,
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: Text(
                                                  "Mot de passe : ",
                                                  textAlign: TextAlign.start,
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: SelectableText(
                                                password,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.start,
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          "Nb : Pensez à copier le mot de passe !",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: Text("Fermer"),
                                        isDefaultAction: true,
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ],
                                  ),
                                );
                                _addedEmailController.text = "";
                              }));
                    },
                  );
                }
              : null,
        ),
      ],
    );
  }
}
