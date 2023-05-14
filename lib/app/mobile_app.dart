import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:label_app/models/ra_options.dart';
import 'package:label_app/models/ra_settings.dart';
import 'package:label_app/screens/home_screen.dart';

import '../main.dart';
import '../models/be_construction.dart';
import '../widgets/loading.dart';

class BeApp extends StatefulWidget {
  const BeApp({Key? key, required this.beAppModel, required this.themeModel})
      : super(key: key);
  final RAModel beAppModel;
  final ThemeModel themeModel;
  @override
  State<BeApp> createState() => _BeAppState();
}

class _BeAppState extends State<BeApp> {
  bool refresh = true;

  @override
  void initState() {
    // TODO: implement initState

    if (widget.beAppModel.settings.enableScreenSecurity) {
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return releaseApp();
  }

  Widget releaseApp() {
    return widget.beAppModel.settings.instantUpdates
        ? appWithInstantUpdates()
        : HomeScreen(
            appModel: widget.beAppModel, themeModel: widget.themeModel);
  }

  Widget appWithInstantUpdates() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("settings").snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (snapshot.connectionState == ConnectionState.active &&
            !snapshot.hasError) {
          RASettings general = RASettings();
          RAOptions options = RAOptions();
          for (QueryDocumentSnapshot documentSnapshot
              in snapshot.data?.docs ?? []) {
            if (documentSnapshot.id == "settings") {
              general = RASettings.fromJson(
                  documentSnapshot.data() as Map<dynamic, dynamic>);
              widget.beAppModel.settings = general;
            }
            if (documentSnapshot.id == "options") {
              options = RAOptions.fromJson(
                  documentSnapshot.data() as Map<dynamic, dynamic>);
              widget.beAppModel.options = options;
            }
          }
          if (general.enableConstructionMode) {
            return BeConstruction(
              model: widget.beAppModel,
            );
          }
          if (refresh) {
            refresh = false;
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {});
              }
            });
            return Loading(
              general: widget.beAppModel.settings,
            );
          }
          return HomeScreen(
              appModel: widget.beAppModel, themeModel: widget.themeModel);
        } else {
          return Loading(
            general: widget.beAppModel.settings,
          );
        }
      },
    );
  }
}
