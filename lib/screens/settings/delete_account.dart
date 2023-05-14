import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:label_app/autorization/components/main_button.dart';
import 'package:label_app/models/localization.dart';
import 'package:label_app/models/ra_model.dart';

import '../../autorization/helpers/font_size.dart';
import '../../autorization/pages/login_page.dart';
import '../../helpers/font_helper.dart';
import '../../main.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({Key? key, required this.model, required this.themeModel})
      : super(key: key);
  final RAModel model;
  final ThemeModel themeModel;
  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 25, top: 30),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: SvgPicture.asset("images/arrow-left.svg"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Localization().deleteAccount,
                  style: getFontStyle(
                      FontSize.xxLarge,
                      Theme.of(context).primaryColor,
                      FontWeight.w600,
                      widget.model.settings),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    Localization().deleteAccountWarningMessage,
                    style: getFontStyle(
                        FontSize.medium,
                        Theme.of(context).primaryColor,
                        FontWeight.w600,
                        widget.model.settings),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                MainButton(
                  text: Localization().deleteAccountConfirmMessage,
                  onTap: () {
                    deleteAccountAction();
                  },
                  general: widget.model.settings,
                  backgroundColor: Colors.redAccent,
                  textColor: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    Localization().deleteAccountConfirmHint,
                    style: getFontStyle(FontSize.medium, Colors.grey,
                        FontWeight.w600, widget.model.settings),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void deleteAccountAction() async {
    await displayTextInputDialog(context);
  }

  Future<void> displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(Localization().enterPassword),
            content: TextField(
              controller: passwordController,
              decoration:
                  InputDecoration(hintText: Localization().accountPassword),
            ),
            actions: <Widget>[
              MainButton(
                text: Localization().cancel,
                onTap: () {
                  Navigator.pop(context);
                },
                general: widget.model.settings,
                backgroundColor: Colors.redAccent,
                textColor: Colors.white,
              ),
              MainButton(
                text: Localization().submit,
                onTap: () async {
                  await reAuthenticateWithCredential(passwordController.text);
                },
                general: widget.model.settings,
                backgroundColor: Colors.greenAccent,
                textColor: Colors.white,
              ),
            ],
          );
        });
  }

  Future<void> reAuthenticateWithCredential(String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final credential = EmailAuthProvider.credential(
        email: user?.email ?? "",
        password: password,
      );
      await user?.reauthenticateWithCredential(credential);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid ?? "")
          .delete();
      await user?.delete();
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => LoginPage(
                  model: widget.model, themeModel: widget.themeModel)),
          (Route<dynamic> route) => false);
    } on Exception catch (e) {
      Navigator.pop(context);
      passwordController.text = "";
      var snackBar =
          SnackBar(content: Text(Localization().authInvalidPassword));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
