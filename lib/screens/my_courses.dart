import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:label_app/models/localization.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:label_app/models/ra_user.dart';

import '../helpers/font_helper.dart';
import '../helpers/globals.dart';
import '../main.dart';
import '../models/course.dart';
import '../service/api_service.dart';
import '../widgets/loading.dart';
import '../widgets/tile_widget.dart';
import 'detail_screen.dart';

class MyCourses extends StatefulWidget {
  const MyCourses({Key? key, required this.appModel, required this.themeModel})
      : super(key: key);
  final RAModel appModel;
  final ThemeModel themeModel;
  @override
  State<MyCourses> createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses> {
  late RaUser user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 50, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      Localization().myCoursesTitle,
                      style: getFontStyle(28, Theme.of(context).primaryColor,
                          FontWeight.bold, widget.appModel.settings),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 100,
                      child: Text(
                        Localization().myCoursesSubtitle,
                        style: getFontStyle(20, Theme.of(context).primaryColor,
                            FontWeight.normal, widget.appModel.settings),
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                ProfilePicture(
                  name: FirebaseAuth.instance.currentUser?.displayName ?? "",
                  radius: 25,
                  fontsize: 20,
                  img: FirebaseAuth.instance.currentUser?.photoURL ?? "",
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder(
                future: APIService().getUserSettings(),
                builder:
                    (BuildContext context, AsyncSnapshot<RaUser> snapshot) {
                  if (!snapshot.hasData) {
                    return Loading(general: widget.appModel.settings);
                  } else {
                    if (snapshot.connectionState == ConnectionState.done) {
                      user = snapshot.data!;
                      if (user.favourites.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            const FaIcon(
                              FontAwesomeIcons.circleInfo,
                              color: Colors.grey,
                              size: 60,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              Localization().myCoursesError,
                              style: getFontStyle(
                                  20,
                                  Theme.of(context).primaryColor,
                                  FontWeight.normal,
                                  widget.appModel.settings),
                              maxLines: 3,
                            )
                          ],
                        );
                      }
                      return SingleChildScrollView(
                        child: StaggeredGrid.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          children: getCategories(),
                        ),
                      );
                    } else {
                      return Loading(general: widget.appModel.settings);
                    }
                  }
                })
          ],
        ),
      ),
    );
  }

  List<TileWidget> getCategories() {
    List<TileWidget> categories = [];
    for (Course course in user.favourites) {
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

  onTileTap(Course course) async {
    RaUser updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          appModel: widget.appModel,
          course: course,
          themeModel: widget.themeModel,
        ),
      ),
    );
    setState(() {
      user = updatedUser;
    });
  }

  String getCorrectCount(int number) {
    if (number == 1) {
      return "$number ${Localization().course}";
    } else {
      return "$number ${Localization().courses}";
    }
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
