import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:label_app/models/ra_user.dart';
import 'package:label_app/widgets/loading.dart';

import '../../helpers/font_helper.dart';
import '../../helpers/globals.dart';
import '../../models/localization.dart';
import '../components/main_button.dart';
import '../helpers/font_size.dart';
import '../helpers/theme_colors.dart';
import '../service/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key, required this.model}) : super(key: key);
  final RAModel model;
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  File fileImage = File("");
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

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
      appBar: AppBar(
        backgroundColor: ThemeColors.scaffoldBgColor,
        elevation: 0,
      ),
      body: isLoading
          ? Loading(general: widget.model.settings)
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Localization().authNewHere,
                        style: getFontStyle(
                            FontSize.xxLarge,
                            ThemeColors.whiteTextColor,
                            FontWeight.w600,
                            widget.model.settings),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          Localization().authFillForm,
                          style: getFontStyle(
                              FontSize.medium,
                              ThemeColors.greyTextColor,
                              FontWeight.w600,
                              widget.model.settings),
                        ),
                      ),
                      const SizedBox(height: 70),
                      GestureDetector(
                          onTap: () {
                            pickImage();
                          },
                          child: Center(
                              child: fileImage.path != ""
                                  ? profileImage()
                                  : const ProfilePicture(
                                      name: "U P", radius: 50, fontsize: 40))),
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            ///Name Input Field
                            TextFormField(
                              controller: _nameController,
                              validator: (value) {
                                if (_nameController.text.isEmpty) {
                                  return Localization()
                                      .authThisFieldCantBeEmpty;
                                }
                                return null;
                              },
                              style: getFontStyle(
                                  14,
                                  ThemeColors.whiteTextColor,
                                  FontWeight.normal,
                                  widget.model.settings),
                              keyboardType: TextInputType.name,
                              cursorColor: ThemeColors.primaryColor,
                              decoration: InputDecoration(
                                fillColor: ThemeColors.textFieldBgColor,
                                filled: true,
                                hintText: Localization().authFullName,
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
                            const SizedBox(height: 16),

                            ///E-mail Input Field
                            TextFormField(
                              controller: _emailController,
                              validator: (value) {
                                if (_emailController.text.isEmpty) {
                                  return Localization()
                                      .authThisFieldCantBeEmpty;
                                }
                                return null;
                              },
                              style: getFontStyle(
                                  14,
                                  ThemeColors.whiteTextColor,
                                  FontWeight.normal,
                                  widget.model.settings),
                              cursorColor: ThemeColors.primaryColor,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                fillColor: ThemeColors.textFieldBgColor,
                                filled: true,
                                hintText: Localization().authEmail,
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
                            const SizedBox(height: 16),

                            ///Password Input Field
                            TextFormField(
                              controller: _passwordController,
                              validator: (value) {
                                if (_passwordController.text.isEmpty) {
                                  return Localization()
                                      .authThisFieldCantBeEmpty;
                                }
                                return null;
                              },
                              obscureText: true,
                              style: getFontStyle(
                                  14,
                                  ThemeColors.whiteTextColor,
                                  FontWeight.normal,
                                  widget.model.settings),
                              keyboardType: TextInputType.visiblePassword,
                              cursorColor: ThemeColors.primaryColor,
                              decoration: InputDecoration(
                                fillColor: ThemeColors.textFieldBgColor,
                                filled: true,
                                hintText: Localization().authPass,
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
                            const SizedBox(height: 70),
                            MainButton(
                              text: Localization().authSignUp,
                              onTap: () {
                                _formKey.currentState!.validate();
                                signUpAction();
                              },
                              general: widget.model.settings,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget profileImage() {
    return Container(
      width: 100,
      height: 100,
      decoration:
          const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.file(
          fileImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void pickImage() async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 75);
    if (image != null) {
      setState(() {
        fileImage = File(image.path);
      });
    }
  }

  void signUpAction() async {
    setState(() {
      isLoading = true;
    });
    RaUser? user = await AuthService().registerWithEmail(_emailController.text,
        _passwordController.text, _nameController.text, fileImage);
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }
}
