import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:label_app/main.dart';
import 'package:label_app/models/course.dart';
import 'package:label_app/models/ra_model.dart';

import '../helpers/font_helper.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen(
      {Key? key,
      required this.course,
      required this.model,
      required this.themeModel})
      : super(key: key);
  final Course course;
  final RAModel model;
  final ThemeModel themeModel;
  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.themeModel.mode == ThemeMode.dark ? true : false;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25, top: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: SvgPicture.asset("images/arrow-left.svg"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 25, top: 10),
                child: ProfilePicture(
                  name: widget.course.name,
                  radius: 18,
                  fontsize: 20,
                  img: widget.course.imageURL,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.course.name,
                  style: getFontStyle(28, Theme.of(context).primaryColor,
                      FontWeight.bold, widget.model.settings),
                ),
                const SizedBox(
                  height: 20,
                ),
                HtmlWidget(
                  widget.course.description,
                  customStylesBuilder: (element) {
                    return {'color': isDarkMode ? 'white' : 'black'};
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
