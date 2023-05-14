import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:label_app/models/category.dart';
import 'package:label_app/models/localization.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:label_app/widgets/tile_widget.dart';

import '../helpers/font_helper.dart';
import '../main.dart';
import '../models/course.dart';
import '../screens/detail_screen.dart';

class CoursesWidget extends StatefulWidget {
  const CoursesWidget(
      {Key? key,
      required this.category,
      required this.appModel,
      required this.themeModel,
      required this.onCourseClick})
      : super(key: key);
  final RACategory category;
  final Function onCourseClick;
  final RAModel appModel;
  final ThemeModel themeModel;

  @override
  State<CoursesWidget> createState() => _CoursesWidgetState();
}

class _CoursesWidgetState extends State<CoursesWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.category.name,
                style: getFontStyle(22, Theme.of(context).primaryColor,
                    FontWeight.bold, widget.appModel.settings)),
            Text("${widget.category.courses.length} ${Localization().courses}",
                style: getFontStyle(
                    17,
                    Theme.of(context).primaryColor.withOpacity(0.5),
                    FontWeight.bold,
                    widget.appModel.settings)),
          ],
        ),
        const SizedBox(
          height: 6,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: getCourses(),
          ),
        )
      ],
    );
  }

  List<Widget> getCourses() {
    List<Widget> categories = [];
    for (Course course in widget.category.courses) {
      TileWidget tile = TileWidget(
          title: course.name,
          subtitle: "",
          imageUrl: course.imageURL,
          isEven: false,
          settings: widget.appModel.settings,
          onTap: () {
            onTileTap(course);
          });
      SizedBox box = SizedBox(
        width: 200,
        child: tile,
      );
      SizedBox width = const SizedBox(
        width: 10,
      );
      categories.add(box);
      categories.add(width);
    }
    return categories;
  }

  onTileTap(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          appModel: widget.appModel,
          course: course,
          themeModel: widget.themeModel,
        ),
      ),
    );
  }
}
