import 'package:flutter/material.dart';
import 'package:label_app/autorization/pages/signup_page.dart';
import 'package:label_app/models/ra_model.dart';

import '../../app/splash_app.dart';
import '../../helpers/font_helper.dart';
import '../../helpers/globals.dart';
import '../../main.dart';
import '../components/main_button.dart';
import '../helpers/font_size.dart';
import '../helpers/theme_colors.dart';
import '../service/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.model, required this.themeModel})
      : super(key: key);
  final RAModel model;
  final ThemeModel themeModel;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AuthService _auth;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth = AuthService();
    // _auth.localize = widget.model.options.localization;
  }

  @override
  Widget build(BuildContext context) {
    if (isRTL) {
      return Directionality(
          textDirection: TextDirection.rtl, child: mainWidget());
    } else {
      return mainWidget();
    }
  }

  Widget mainWidget() {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 60, 30, 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _auth.localize.authLetsGetYouIn,
                  style: getFontStyle(
                      FontSize.xxLarge,
                      ThemeColors.whiteTextColor,
                      FontWeight.w600,
                      widget.model.settings),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    _auth.localize.authLoginToYourAccount,
                    style: getFontStyle(
                        FontSize.medium,
                        ThemeColors.greyTextColor,
                        FontWeight.w600,
                        widget.model.settings),
                  ),
                ),
                const SizedBox(height: 70),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ///Email Input Field
                      Visibility(
                        visible: true,
                        child: TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (_emailController.text.isEmpty) {
                              return _auth.localize.authThisFieldCantBeEmpty;
                            }
                            return null;
                          },
                          style: getFontStyle(14, ThemeColors.whiteTextColor,
                              FontWeight.normal, widget.model.settings),
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: ThemeColors.primaryColor,
                          decoration: InputDecoration(
                            fillColor: ThemeColors.textFieldBgColor,
                            filled: true,
                            hintText: _auth.localize.authEmail,
                            hintStyle: getFontStyle(
                                FontSize.medium,
                                ThemeColors.textFieldHintColor,
                                FontWeight.w400,
                                widget.model.settings),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      ///Password Input Field
                      Visibility(
                        visible: true,
                        child: TextFormField(
                          controller: _passwordController,
                          validator: (value) {
                            if (_passwordController.text.isEmpty) {
                              return _auth.localize.authThisFieldCantBeEmpty;
                            }
                            return null;
                          },
                          obscureText: true,
                          style: getFontStyle(14, ThemeColors.whiteTextColor,
                              FontWeight.normal, widget.model.settings),
                          keyboardType: TextInputType.visiblePassword,
                          cursorColor: ThemeColors.primaryColor,
                          decoration: InputDecoration(
                            fillColor: ThemeColors.textFieldBgColor,
                            filled: true,
                            hintText: _auth.localize.authPass,
                            hintStyle: getFontStyle(
                                FontSize.medium,
                                ThemeColors.textFieldHintColor,
                                FontWeight.w400,
                                widget.model.settings),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18)),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: true,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: GestureDetector(
                              onTap: () {
                                forgotPasswordAction(context);
                              },
                              child: Text(
                                _auth.localize.authForgotPass,
                                style: getFontStyle(
                                    FontSize.medium,
                                    ThemeColors.greyTextColor,
                                    FontWeight.w600,
                                    widget.model.settings),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 70),
                      Visibility(
                        visible: true,
                        child: MainButton(
                          text: _auth.localize.authSignIn,
                          onTap: () {
                            _formKey.currentState!.validate();
                            emailLoginAction();
                          },
                          general: widget.model.settings,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Visibility(
                        visible: showGoogleAuth(),
                        child: MainButton(
                          text: _auth.localize.authLoginGoogle,
                          backgroundColor: ThemeColors.whiteTextColor,
                          textColor: ThemeColors.scaffoldBgColor,
                          iconPath: 'images/google.png',
                          onTap: () {
                            googleLoginAction(context);
                          },
                          general: widget.model.settings,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Visibility(
                  visible: true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${_auth.localize.authDontHaveAccount} ",
                          style: getFontStyle(
                              FontSize.medium,
                              ThemeColors.whiteTextColor,
                              FontWeight.w600,
                              widget.model.settings),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(
                                model: widget.model,
                              ),
                            ),
                          ),
                          child: Text(
                            _auth.localize.authSignUp,
                            style: getFontStyle(
                                FontSize.medium,
                                ThemeColors.primaryColor,
                                FontWeight.w600,
                                widget.model.settings),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void googleLoginAction(BuildContext context) async {
    dynamic result = await _auth.signInGoogle(context);
    if (result != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SplashApp(
                  beApp: widget.model, themeModel: widget.themeModel)));
    }
  }

  void emailLoginAction() async {
    dynamic result = await _auth.signInWithEmail(
        _emailController.text, _passwordController.text);
    if (result == null) {
      var snackBar =
          SnackBar(content: Text(_auth.localize.authInvalidPassword));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SplashApp(
                  beApp: widget.model, themeModel: widget.themeModel)));
    }
  }

  void forgotPasswordAction(BuildContext context) async {
    if (_emailController.text.isEmpty) {
      var snackBar = SnackBar(content: Text(_auth.localize.authEmailRequired));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    await _auth.forgotPassword(_emailController.text, context);
  }

  bool showFacebookAuth() {
    if (widget.model.settings.enableFacebookLogin) {
      return true;
    } else {
      return false;
    }
  }

  bool showGoogleAuth() {
    return true;
  }
}
