import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:label_app/models/ra_model.dart';

import '../helpers/font_helper.dart';
import '../helpers/globals.dart';
import '../main.dart';
import '../models/course.dart';
import '../models/localization.dart';
import '../widgets/tile_widget.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen(
      {Key? key,
      required this.appModel,
      required this.courses,
      required this.searchedText,
      required this.themeModel})
      : super(key: key);
  final RAModel appModel;
  final List<Course> courses;
  final String searchedText;
  final ThemeModel themeModel;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 50, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: SvgPicture.asset("images/arrow-left.svg"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${Localization().searching} ${widget.searchedText}",
                        style: getFontStyle(24, Theme.of(context).primaryColor,
                            FontWeight.bold, widget.appModel.settings),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 100,
                        child: Text(
                          "${Localization().foundResult} ${getCorrectCount()}",
                          style: getFontStyle(
                              18,
                              Theme.of(context).primaryColor,
                              FontWeight.normal,
                              widget.appModel.settings),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              mainWidget()
            ],
          ),
        ),
      ),
    );
  }

  List<TileWidget> getCategories() {
    List<TileWidget> categories = [];
    for (Course course in widget.courses) {
      TileWidget tile = TileWidget(
          title: course.name,
          subtitle: "",
          imageUrl: course.imageURL,
          isEven: false,
          settings: widget.appModel.settings,
          onTap: () {
            onTileTap(course);
          });
      categories.add(tile);
    }
    return categories;
  }

  Widget mainWidget() {
    if (widget.courses.isNotEmpty) {
      return StaggeredGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: getCategories(),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          const FaIcon(
            FontAwesomeIcons.magnifyingGlass,
            color: Colors.grey,
            size: 60,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            Localization().searchError,
            style: getFontStyle(20, Theme.of(context).primaryColor,
                FontWeight.normal, widget.appModel.settings),
            maxLines: 3,
          )
        ],
      );
    }
  }

  String getCorrectCount() {
    if (widget.courses.length == 1) {
      return "${widget.courses.length} ${Localization().course}";
    } else {
      return "${widget.courses.length} ${Localization().courses}";
    }
  }

  onTileTap(Course course) async {
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

class CourseContent extends StatelessWidget {
  String number = "";
  double duration = 0;
  String title = "";
  bool isDone = false;

  CourseContent({
    Key? key,
    required this.number,
    required this.duration,
    required this.title,
    this.isDone = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: <Widget>[
          Text(
            number,
            style: kHeadingextStyle.copyWith(
              color: kTextColor.withOpacity(.15),
              fontSize: 32,
            ),
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$duration ${Localization().mins}\n",
                  style: TextStyle(
                    color: kTextColor.withOpacity(.5),
                    fontSize: 18,
                  ),
                ),
                TextSpan(
                  text: title,
                  style: kSubtitleTextSyule.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(left: 20),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kGreenColor.withOpacity(isDone ? 1 : .5),
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white),
          )
        ],
      ),
    );
  }
}
