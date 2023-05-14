import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:label_app/models/ra_model.dart';

import '../autorization/service/auth_service.dart';
import '../autorization/wrapper/auth_wrapper.dart';
import '../main.dart';
import '../models/ra_user.dart';

class StarterApp extends StatelessWidget {
  StarterApp({Key? key, required this.model, required this.themeModel})
      : super(key: key);
  final RAModel model;
  final ThemeModel themeModel;
  @override
  Widget build(BuildContext context) {
    return getStartingWidget(model);
  }

  Widget getStartingWidget(RAModel model) {
    return StreamProvider<RaUser?>.value(
        initialData: RaUser(uid: "", displayName: "", email: ""),
        value: AuthService().user,
        child: AuthWrapper(model: model, themeModel: themeModel));
  }
}
