import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:label_app/main.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:label_app/models/ra_user.dart';

import '../../app/splash_app.dart';
import '../pages/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key, required this.model, required this.themeModel})
      : super(key: key);
  final RAModel model;
  final ThemeModel themeModel;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<RaUser?>(context);
    if (user == null) {
      return LoginPage(model: model, themeModel: themeModel);
    } else {
      return SplashApp(beApp: model, themeModel: themeModel);
    }
  }
}
