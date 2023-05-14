import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/font_helper.dart';
import '../helpers/globals.dart';
import '../main.dart';
import '../models/localization.dart';
import '../models/onboarding_page.dart';
import '../service/api_service.dart';
import '../widgets/be_image.dart';
import '../widgets/loading.dart';
import 'mobile_app.dart';

class SplashApp extends StatefulWidget {
  const SplashApp({Key? key, required this.beApp, required this.themeModel})
      : super(key: key);
  final RAModel beApp;
  final ThemeModel themeModel;
  @override
  State<SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  bool isLoggedIn = false;
  bool isLanguageSelected = false;
  String title = "";
  @override
  void initState() {
    title = Localization().skip;
    super.initState();
    loadAppSettings();
  }

  Widget loadFirstRun() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder:
          (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Loading(
              general: widget.beApp.settings,
            );
          case ConnectionState.waiting:
            return Loading(
              general: widget.beApp.settings,
            );
          case ConnectionState.done:
            if (!snapshot.hasError) {
              return loadStartingScreen();
            } else {
              return Loading(
                general: widget.beApp.settings,
              );
            }
          case ConnectionState.active:
            // TODO: Handle this case.
            break;
        }
        return Loading(
          general: widget.beApp.settings,
        );
      },
    );
  }

  Widget loadStartingScreen() {
    return widget.beApp.options.onboardingPages.isEmpty
        ? BeApp(beAppModel: widget.beApp, themeModel: widget.themeModel)
        : isLoggedIn
            ? BeApp(beAppModel: widget.beApp, themeModel: widget.themeModel)
            : Scaffold(backgroundColor: Colors.white, body: onBoardingScreen());
  }

  Widget onBoardingScreen() {
    return SafeArea(
      child: IntroductionScreen(
        pages: onBoardingPages(),
        onDone: () async {
          moveToApp();
        },
        onSkip: () async {
          moveToApp();
        },
        showBackButton: false,
        showSkipButton: true,
        showNextButton: false,
        skip: Text(
          Localization().skip,
          style: getFontStyle(
              14, Colors.black, FontWeight.bold, widget.beApp.settings),
        ),
        done: Text(
          Localization().continueText,
          style: getFontStyle(
              14, Colors.black, FontWeight.bold, widget.beApp.settings),
        ),
      ),
    );
  }

  moveToApp() async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    await myPrefs.setBool("isFirstRun", true);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BeApp(
                beAppModel: widget.beApp, themeModel: widget.themeModel)));
  }

  List<PageViewModel> onBoardingPages() {
    return List.generate(widget.beApp.options.onboardingPages.length, (index) {
      OnboardingPage page = widget.beApp.options.onboardingPages[index];
      PageViewModel model = PageViewModel(
        title: page.title,
        body: page.text,
        image: Center(
          child: BeImage(
            link: page.imageUrl,
            width: 300,
            height: 330,
            fit: BoxFit.contain,
          ),
        ),
      );
      return model;
    });
  }

  loadAppSettings() async {
    APIService().logEvent(AnalyticsType.device);
    isLoggedIn =
        await MySharedPreferences.instance.getBooleanValue("isFirstRun");
    isLanguageSelected = await MySharedPreferences.instance
        .getBooleanValue("isLanguageSelected");
    if (!isLoggedIn) {
      APIService().logEvent(AnalyticsType.device);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);

    if (isRTL) {
      return Directionality(
          textDirection: TextDirection.rtl, child: loadFirstRun());
    } else {
      return loadFirstRun();
    }
  }
}

class MySharedPreferences {
  MySharedPreferences._privateConstructor();

  static final MySharedPreferences instance =
      MySharedPreferences._privateConstructor();
  setBooleanValue(String key, bool value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setBool(key, value);
  }

  Future<bool> getBooleanValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getBool(key) ?? false;
  }

  Future<int> getSelectedLanguage() async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getInt("SelectedLanguage") ?? 0;
  }

  setSelectedLanguage(int value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setInt("SelectedLanguage", value);
  }
}
