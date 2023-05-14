import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:label_app/main.dart';
import 'package:label_app/models/course.dart';
import 'package:label_app/models/lesson.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:label_app/models/ra_user.dart';
import 'package:label_app/screens/subscribe_screen.dart';
import 'package:label_app/screens/video_screen.dart';
import 'package:label_app/service/subscription/revenue_cat.dart';
import 'package:label_app/widgets/loading.dart';
import 'package:share_plus/share_plus.dart';

import '../helpers/font_helper.dart';
import '../helpers/globals.dart';
import '../models/entitlement.dart';
import '../models/localization.dart';
import '../service/api_service.dart';
import 'information_screen.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen(
      {Key? key,
      required this.appModel,
      required this.course,
      required this.themeModel})
      : super(key: key);
  final RAModel appModel;
  final Course course;
  final ThemeModel themeModel;
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool isCourseInFavourites = false;
  RaUser user = RaUser(uid: "", displayName: "", email: "");
  RevenueCatProvider provider = RevenueCatProvider();

  @override
  void initState() {
    // TODO: implement initState
    APIService().logEvent(AnalyticsType.openedCourses);
    provider = RevenueCatProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: FutureBuilder(
          future: Future.wait([
            APIService().isCourseInFavourites(widget.course),
            provider.updatePurchasesStatus(),
          ]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) {
              return Stack(
                children: [
                  mainWidget(provider.entitlement),
                  Center(
                    child: Loading(general: widget.appModel.settings),
                  ),
                ],
              );
            } else {
              if (snapshot.connectionState == ConnectionState.done) {
                isCourseInFavourites = snapshot.data[0]!;
                isSubscribed =
                    snapshot.data[1] == Entitlement.subscribed ? true : false;
                return mainWidget(provider.entitlement);
              } else {
                return Stack(
                  children: [
                    mainWidget(provider.entitlement),
                    Center(
                      child: Loading(general: widget.appModel.settings),
                    ),
                  ],
                );
              }
            }
          }),
    );
  }

  Widget mainWidget(Entitlement entitlement) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: MediaQuery.of(context).size.width,
                    child: CachedNetworkImage(
                      imageUrl: widget.course.imageURL,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.45,
                    color: Colors.black.withOpacity(0.4),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 10, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(user);
                              },
                              child: const FaIcon(
                                FontAwesomeIcons.chevronLeft,
                                color: Colors.white,
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                iconSize: 18,
                                icon: const FaIcon(
                                  FontAwesomeIcons.ellipsisVertical,
                                  color: Colors.white,
                                ),
                                items: <String>[
                                  Localization().information,
                                  Localization().share
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == Localization().information) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InformationScreen(
                                          course: widget.course,
                                          model: widget.appModel,
                                          themeModel: widget.themeModel,
                                        ),
                                      ),
                                    );
                                  } else {
                                    APIService()
                                        .logEvent(AnalyticsType.userShares);
                                    Share.share(
                                        "${Localization().shareMessage} ${widget.course.name} ${widget.course.imageURL}");
                                  }
                                },
                              ),
                            )
                            //SvgPicture.asset("images/more-vertical.svg"),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipPath(
                          clipper: BestSellerClipper(),
                          child: Container(
                            color: kBestSellerColor,
                            padding: const EdgeInsets.only(
                                left: 10, top: 5, right: 20, bottom: 5),
                            child: Text(
                              widget.course.level.toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).cardColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(widget.course.name,
                            style: getFontStyle(26, Colors.white,
                                FontWeight.bold, widget.appModel.settings)),
                        const SizedBox(height: 16),
                        Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.personChalkboard,
                                  color: Colors.white.withOpacity(.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(widget.course.teacher,
                                    style: getFontStyle(
                                        13,
                                        Colors.white.withOpacity(.8),
                                        FontWeight.normal,
                                        widget.appModel.settings)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.peopleGroup,
                                  color: Colors.white.withOpacity(.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(widget.course.numberOfWatchers.toString(),
                                    style: getFontStyle(
                                        13,
                                        Colors.white.withOpacity(.8),
                                        FontWeight.normal,
                                        widget.appModel.settings)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.solidStar,
                                  color: Colors.white.withOpacity(.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                    widget.course.numberOfFavourites.toString(),
                                    style: getFontStyle(
                                        13,
                                        Colors.white.withOpacity(.8),
                                        FontWeight.normal,
                                        widget.appModel.settings)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Localization().courseLessons,
                              style: getFontStyle(
                                  24,
                                  Theme.of(context).primaryColor,
                                  FontWeight.bold,
                                  widget.appModel.settings)),
                          const SizedBox(height: 30),
                          Column(
                            children: getLessons(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 50,
                  color: kTextColor.withOpacity(.1),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    addToFavorites();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    height: 56,
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDEE),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: isCourseInFavourites
                          ? const FaIcon(
                              FontAwesomeIcons.solidStar,
                              color: Colors.redAccent,
                            )
                          : const FaIcon(
                              FontAwesomeIcons.star,
                              color: Colors.redAccent,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      startWatching();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: kBlueColor,
                      ),
                      child: Text(
                        isSubscribed == true
                            ? Localization().startCourse
                            : Localization().subscribe,
                        style: getFontStyle(20, Colors.white, FontWeight.bold,
                            widget.appModel.settings),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<CourseContent> getLessons(BuildContext context) {
    List<CourseContent> lessons = [];
    for (int i = 0; i < widget.course.lessons.length; i++) {
      String number = "";
      if (i > 9) {
        number = i.toString();
      } else {
        number = "0$i";
      }
      RALesson lesson = widget.course.lessons[i];
      CourseContent l = CourseContent(
        number: number,
        duration: lesson.duration,
        title: lesson.name,
        isDone: isSubscribed
            ? true
            : i > 0
                ? false
                : true,
        index: i,
        onPlay: (index) async {
          if (isSubscribed == true || index == 0) {
            bool result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoScreen(
                  appModel: widget.appModel,
                  course: widget.course,
                  index: i,
                ),
              ),
            );
            if (result) {
              setState(() {});
            }
          } else {
            bool result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SubscribeScreen(appModel: widget.appModel)));
            if (result) {
              setState(() {});
            }
          }
        },
      );
      lessons.add(l);
    }
    return lessons;
  }

  void addToFavorites() async {
    if (isCourseInFavourites) {
      user = await APIService().removeFromFavourites(widget.course);
      APIService().decreaseCourseFavoritesCount(widget.course);
      setState(() {
        isCourseInFavourites = false;
      });
    } else {
      user = await APIService().addToFavourites(widget.course);
      APIService().increaseCourseFavoritesCount(widget.course);
      setState(() {
        isCourseInFavourites = true;
      });
    }
  }

  void startWatching() async {
    await provider.updatePurchasesStatus();
    isSubscribed =
        provider.entitlement == Entitlement.subscribed ? true : false;

    if (isSubscribed) {
      APIService().increaseCourseWatchedCount(widget.course);
      bool result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoScreen(
            appModel: widget.appModel,
            course: widget.course,
            index: 0,
          ),
        ),
      );
      if (result) {
        setState(() {
          debugPrint("refreshing");
        });
      }
    } else {
      bool result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubscribeScreen(
            appModel: widget.appModel,
          ),
        ),
      );
      if (result) {
        setState(() {
          debugPrint("refreshing");
        });
      }
    }
  }
}

class CourseContent extends StatelessWidget {
  String number = "";
  String duration = "0";
  String title = "";
  bool isDone = false;
  bool showPauseIcon = false;
  Function onPlay;
  int index = 0;
  CourseContent(
      {Key? key,
      required this.number,
      required this.duration,
      required this.title,
      this.isDone = false,
      required this.index,
      required this.onPlay,
      this.showPauseIcon = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 40,
            child: Text(
              number,
              textAlign: TextAlign.right,
              style: kHeadingextStyle.copyWith(
                color: Theme.of(context).primaryColor.withOpacity(.35),
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width - 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$duration ${Localization().mins}",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(.5),
                    fontSize: 18,
                  ),
                ),
                Text(
                  title,
                  textAlign: TextAlign.left,
                  maxLines: 5,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          // Expanded(
          //   child: RichText(
          //     text: TextSpan(
          //       children: [
          //         TextSpan(
          //           text: "$duration ${Localization().mins}\n",
          //           style: TextStyle(
          //             color: Theme.of(context).primaryColor.withOpacity(.5),
          //             fontSize: 18,
          //           ),
          //         ),
          //         TextSpan(
          //           text: title,
          //           style: kSubtitleTextSyule.copyWith(
          //             fontWeight: FontWeight.w600,
          //             color: Theme.of(context).primaryColor,
          //             height: 1.5,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              onPlay(index);
            },
            child: Container(
              margin: const EdgeInsets.only(left: 20),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: showPauseIcon == false
                    ? kGreenColor.withOpacity(isDone ? 1 : .5)
                    : Colors.redAccent.withOpacity(isDone ? 1 : .5),
              ),
              child: showPauseIcon == false
                  ? const Icon(Icons.play_arrow, color: Colors.white)
                  : const Icon(Icons.pause, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

class BestSellerClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    var path = Path();
    path.lineTo(size.width - 20, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 20, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
