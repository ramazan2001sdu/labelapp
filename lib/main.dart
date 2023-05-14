import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:label_app/models/ra_user.dart';
import 'package:label_app/service/api_service.dart';
import 'package:label_app/service/subscription/purchase_service.dart';

import 'app/service_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );

  await FirebaseMessaging.instance.subscribeToTopic("messaging");

  await PurchaseService.init();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // TODO: handle the received notifications
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint("Push Notifications Permissions Granted Token: ${token ?? ""}");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeModel>(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder: (_, model, __) {
          return FutureBuilder(
            future: APIService().getUserSettings(),
            builder: (BuildContext context, AsyncSnapshot<RaUser> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data != null) {
                  RaUser user = snapshot.data!;
                  if (user.isDarkModeEnabled) {
                    model.changeToDark();
                  } else {
                    model.changeToLight();
                  }
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(
                        brightness: Brightness.light,
                        backgroundColor: Colors.white,
                        primaryColor: const Color.fromRGBO(33, 33, 33, 1),
                        cardColor: const Color.fromRGBO(33, 33, 33, 1),
                        canvasColor: Colors.white), // Provide light theme.
                    darkTheme: ThemeData(
                        brightness: Brightness.dark,
                        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
                        primaryColor: Colors.white,
                        cardColor: const Color.fromRGBO(33, 33, 33, 1),
                        canvasColor: Colors.black), // Provide dark theme.
                    themeMode: model.mode, // Decides which theme to show.
                    home: ServiceWidget(
                      themeModel: model,
                    ),
                  );
                } else {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(
                        brightness: Brightness.light,
                        backgroundColor: Colors.white,
                        primaryColor: const Color.fromRGBO(33, 33, 33, 1),
                        cardColor: const Color.fromRGBO(33, 33, 33, 1),
                        canvasColor: Colors.white), // Provide light theme.
                    darkTheme: ThemeData(
                        brightness: Brightness.dark,
                        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
                        primaryColor: Colors.white,
                        cardColor: const Color.fromRGBO(33, 33, 33, 1),
                        canvasColor: Colors.black), // Provide dark theme.
                    themeMode: model.mode, // Decides which theme to show.
                    home: ServiceWidget(
                      themeModel: model,
                    ),
                    debugShowMaterialGrid: false,
                  );
                }
              } else {
                return Container(
                  color: Colors.black87,
                );
              }
            },
          );
        },
      ),
    );
  }
}

class ThemeModel with ChangeNotifier {
  ThemeMode _mode;
  ThemeMode get mode => _mode;
  ThemeModel({ThemeMode mode = ThemeMode.light}) : _mode = mode;

  void toggleMode() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void changeToDark() {
    _mode = ThemeMode.dark;
  }

  void changeToLight() {
    _mode = ThemeMode.light;
  }
}
