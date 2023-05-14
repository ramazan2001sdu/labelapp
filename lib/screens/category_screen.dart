import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:label_app/models/category.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:label_app/screens/detail_screen.dart';

import '../helpers/font_helper.dart';
import '../helpers/globals.dart';
import '../main.dart';
import '../models/course.dart';
import '../models/localization.dart';
import '../widgets/tile_widget.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen(
      {Key? key,
      required this.appModel,
      required this.category,
      required this.themeModel})
      : super(key: key);
  final RAModel appModel;
  final RACategory category;
  final ThemeModel themeModel;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        children: [
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: widget.category.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.35,
                color: Colors.black.withOpacity(0.4),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const FaIcon(
                            FontAwesomeIcons.chevronLeft,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ClipPath(
                      clipper: BestSellerClipper(),
                      child: Container(
                        color: kBestSellerColor,
                        padding: const EdgeInsets.only(
                            left: 10, top: 5, right: 20, bottom: 5),
                        child: Text(
                          Localization().category.toUpperCase(),
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).cardColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(widget.category.name,
                        style: getFontStyle(26, Colors.white, FontWeight.bold,
                            widget.appModel.settings)),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Text(getCorrectCount(widget.category.courses.length),
                            style: getFontStyle(
                                16,
                                Colors.white.withOpacity(.8),
                                FontWeight.normal,
                                widget.appModel.settings)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50)),
                  color: Theme.of(context).backgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: StaggeredGrid.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: getCategories(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<TileWidget> getCategories() {
    List<TileWidget> categories = [];
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
      categories.add(tile);
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
