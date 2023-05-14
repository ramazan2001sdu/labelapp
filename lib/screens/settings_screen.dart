import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:label_app/autorization/pages/login_page.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:label_app/models/ra_user.dart';
import 'package:label_app/screens/settings/about_screen.dart';
import 'package:label_app/screens/settings/delete_account.dart';
import 'package:label_app/screens/settings/edit_profile_screen.dart';
import 'package:label_app/widgets/loading.dart';

import '../helpers/font_helper.dart';
import '../main.dart';
import '../models/localization.dart';
import '../service/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen(
      {Key? key, required this.appModel, required this.themeModel})
      : super(key: key);
  final RAModel appModel;
  final ThemeModel themeModel;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  RaUser user = RaUser(uid: "", displayName: "", email: "");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: APIService().getUserSettings(),
        builder: (BuildContext context, AsyncSnapshot<RaUser> snapshot) {
          if (!snapshot.hasData) {
            return Stack(
              children: [
                //mainWidget(),
                Center(
                  child: Loading(general: widget.appModel.settings),
                )
              ],
            );
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              user =
                  snapshot.data ?? RaUser(uid: "", displayName: "", email: "");
            }
            return mainWidget();
          }
        });
  }

  Widget mainWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      child: ListView(
        children: [
          Text(
            Localization().settingsTitle,
            style: getFontStyle(30, Theme.of(context).primaryColor,
                FontWeight.bold, widget.appModel.settings),
          ),
          const SizedBox(
            height: 15,
          ),
          BigUserCard(
            backgroundColor: Colors.black87,
            // cardColor: Colors.black87,
            userName: FirebaseAuth.instance.currentUser?.displayName,
            userProfilePic: CachedNetworkImageProvider(
                FirebaseAuth.instance.currentUser?.photoURL ?? ""),
            cardActionWidget: SettingsItem(
              icons: Icons.edit,
              iconStyle: IconStyle(
                withBackground: true,
                borderRadius: 50,
                backgroundColor: Colors.yellow[600],
              ),
              title: Localization().editAccount,
              titleStyle: TextStyle(color: Theme.of(context).cardColor),
              subtitle: Localization().editAccountSubtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      model: widget.appModel,
                    ),
                  ),
                );
              },
            ),
          ),
          SettingsGroup(
            items: [
              SettingsItem(
                onTap: () {},
                icons: FontAwesomeIcons.bell,
                iconStyle: IconStyle(),
                title: Localization().pushNotifications,
                titleStyle: TextStyle(color: Theme.of(context).cardColor),
                subtitle: Localization().pushNotificationsSubtitle,
                trailing: Switch.adaptive(
                  value: user.isPushNotificationsEnabled,
                  inactiveTrackColor: Colors.grey,
                  activeColor: Colors.green,
                  onChanged: (value) async {
                    user.isPushNotificationsEnabled = value;
                    if (user.isPushNotificationsEnabled) {
                      await FirebaseMessaging.instance
                          .subscribeToTopic("messaging");
                    } else {
                      await FirebaseMessaging.instance
                          .unsubscribeFromTopic("messaging");
                    }
                    await APIService().updateUserSettings(user);
                    setState(() {});
                  },
                ),
              ),
              SettingsItem(
                onTap: () {},
                icons: Icons.dark_mode_rounded,
                iconStyle: IconStyle(
                  iconsColor: Colors.white,
                  withBackground: true,
                  backgroundColor: Colors.red,
                ),
                title: Localization().darkMode,
                titleStyle: TextStyle(color: Theme.of(context).cardColor),
                subtitle: Localization().darkModeSubtitle,
                trailing: Switch.adaptive(
                  value: user.isDarkModeEnabled,
                  inactiveTrackColor: Colors.grey,
                  activeColor: Colors.green,
                  onChanged: (value) async {
                    user.isDarkModeEnabled = value;
                    await APIService().updateUserSettings(user);
                    widget.themeModel.toggleMode();
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          SettingsGroup(
            items: [
              SettingsItem(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutScreen(
                        appModel: widget.appModel,
                      ),
                    ),
                  );
                },
                icons: Icons.info_rounded,
                iconStyle: IconStyle(
                  backgroundColor: Colors.purple,
                ),
                title: Localization().aboutUs,
                titleStyle: TextStyle(color: Theme.of(context).cardColor),
                subtitle: Localization().aboutUsSubtitle,
              ),
            ],
          ),
          // You can add a settings title
          SettingsGroup(
            settingsGroupTitle: Localization().account,
            settingsGroupTitleStyle: getFontStyle(
                25,
                Theme.of(context).primaryColor,
                FontWeight.bold,
                widget.appModel.settings),
            items: [
              SettingsItem(
                onTap: () {
                  signOutAction();
                },
                icons: Icons.exit_to_app_rounded,
                iconStyle: IconStyle(
                  backgroundColor: Colors.black26,
                ),
                title: Localization().signOut,
                titleStyle: TextStyle(color: Theme.of(context).cardColor),
                subtitle: Localization().signOutSubtitle,
              ),
              SettingsItem(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteAccount(
                          model: widget.appModel,
                          themeModel: widget.themeModel),
                    ),
                  );
                },
                icons: CupertinoIcons.delete_solid,
                iconStyle: IconStyle(
                  backgroundColor: Colors.redAccent,
                ),
                title: Localization().deleteAccount,
                subtitle: Localization().deleteAccountSubtitle,
                titleStyle: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  signOutAction() async {
    await FirebaseAuth.instance.signOut();
    Purchases.logOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => LoginPage(
                model: widget.appModel, themeModel: widget.themeModel)),
        (Route<dynamic> route) => false);
  }
}
