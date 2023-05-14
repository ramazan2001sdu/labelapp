import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:label_app/models/course.dart';
import 'package:label_app/models/localization.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:label_app/screens/categories_screen.dart';
import 'package:label_app/screens/category_screen.dart';
import 'package:label_app/screens/chat_screen.dart';
import 'package:label_app/screens/my_courses.dart';
import 'package:label_app/screens/search_screen.dart';
import 'package:label_app/screens/settings_screen.dart';
import 'package:label_app/service/api_service.dart';
import 'package:label_app/widgets/courses_widget.dart';
import 'package:label_app/widgets/loading.dart';

import '../autorization/helpers/font_size.dart';
import '../helpers/font_helper.dart';
import '../helpers/globals.dart';
import '../main.dart';
import '../models/category.dart';
import 'news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.appModel, required this.themeModel})
      : super(key: key);
  final RAModel appModel;
  final ThemeModel themeModel;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchFieldControllerr = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      bottomNavigationBar: classicBottomNavigation(),
      body: setSelectedScreen(),
    );
  }

  Widget setSelectedScreen() {
    if (_selectedIndex == 0) {
      return homeScreen();
    } else if (_selectedIndex == 1) {
      return MyCourses(
        appModel: widget.appModel,
        themeModel: widget.themeModel,
      );
    } else if (_selectedIndex == 2) {
      return ChatScreen(model: widget.appModel);
    } else if (_selectedIndex == 3) {
      return NewsScreen(appModel: widget.appModel);
    } else if (_selectedIndex == 4) {
      return SettingsScreen(
          appModel: widget.appModel, themeModel: widget.themeModel);
    } else {
      return Loading(general: widget.appModel.settings);
    }
  }

  Widget homeScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 50, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "${Localization().homeScreenHey} ${FirebaseAuth.instance.currentUser?.displayName},",
                      style: getFontStyle(28, Theme.of(context).primaryColor,
                          FontWeight.bold, widget.appModel.settings),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 100,
                      child: Text(
                        Localization().homeScreenTitle,
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
            //const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 30),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 1.0,
                          spreadRadius: 0.0,
                          offset: Offset(
                              1.0, 1.0), // shadow direction: bottom right
                        )
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        SvgPicture.asset("images/search.svg"),
                        Expanded(
                          child: TextFormField(
                            controller: searchFieldControllerr,
                            style: getFontStyle(FontSize.xLarge, Colors.black,
                                FontWeight.w400, widget.appModel.settings),
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.grey,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              fillColor: Colors.white.withAlpha(0),
                              filled: true,
                              hintText: Localization().homeScreenSearch,
                              hintStyle: getFontStyle(
                                  FontSize.xLarge,
                                  Colors.grey,
                                  FontWeight.w400,
                                  widget.appModel.settings),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F7),
                        shape: const CircleBorder()),
                    child: const FaIcon(
                      FontAwesomeIcons.magnifyingGlassArrowRight,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      List<Course> results = APIService().searchCourses(
                          widget.appModel.options.categories,
                          searchFieldControllerr.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(
                            appModel: widget.appModel,
                            courses: results,
                            searchedText: searchFieldControllerr.text,
                            themeModel: widget.themeModel,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(Localization().homeScreenBrowseCategories,
                      style: getFontStyle(24, Theme.of(context).primaryColor,
                          FontWeight.bold, widget.appModel.settings)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoriesScreen(
                            appModel: widget.appModel,
                            themeModel: widget.themeModel,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      Localization().seeAll,
                      style: getFontStyle(18, kBlueColor, FontWeight.normal,
                          widget.appModel.settings),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Column(
              children: getCategories(),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  List<Widget> getCategories() {
    List<Widget> categories = [];
    for (RACategory cat in widget.appModel.options.categories) {
      CoursesWidget coursesWidget = CoursesWidget(
        category: cat,
        appModel: widget.appModel,
        themeModel: widget.themeModel,
        onCourseClick: () {},
      );
      categories.add(coursesWidget);
      SizedBox box = const SizedBox(
        height: 20,
      );
      categories.add(box);
    }
    return categories;
  }

  String getCorrectCount(int number) {
    if (number == 1) {
      return "$number ${Localization().course}";
    } else {
      return "$number ${Localization().courses}";
    }
  }

  onTileTap(RACategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(
          appModel: widget.appModel,
          category: category,
          themeModel: widget.themeModel,
        ),
      ),
    );
  }

  Widget classicBottomNavigation() {
    return BottomNavigationBar(
      items: classicNavItems(),
      type: widget.appModel.settings.enableShowTitlesAlwaysForBottomMenu
          ? BottomNavigationBarType.fixed
          : BottomNavigationBarType.shifting, //fixed to show all labels
      showSelectedLabels: true,
      showUnselectedLabels: false,
      backgroundColor: widget.themeModel.mode == ThemeMode.dark
          ? Theme.of(context).backgroundColor
          : widget.appModel.settings.getBottomBarColor(),
      selectedItemColor:
          widget.appModel.settings.enableShowTitlesAlwaysForBottomMenu == false
              ? null
              : widget.themeModel.mode == ThemeMode.dark
                  ? Colors.white
                  : widget.appModel.settings.getBottomBarSelectedItemsColor(),
      unselectedItemColor:
          widget.appModel.settings.enableShowTitlesAlwaysForBottomMenu == false
              ? null
              : widget.appModel.settings.getBottomBarItemsColor(),
      unselectedIconTheme: IconThemeData(
          color: widget.appModel.settings.getBottomBarItemsColor()),
      selectedIconTheme: IconThemeData(
          color: widget.appModel.settings.getBottomBarSelectedItemsColor()),
      fixedColor:
          widget.appModel.settings.enableShowTitlesAlwaysForBottomMenu == true
              ? null
              : widget.appModel.settings.getBottomBarItemsColor(),
      currentIndex: _selectedIndex,
      selectedLabelStyle:
          widget.appModel.settings.enableShowTitlesAlwaysForBottomMenu == false
              ? null
              : getFontStyle(
                  11,
                  widget.appModel.settings.getBottomBarSelectedItemsColor(),
                  FontWeight.normal,
                  widget.appModel.settings),
      unselectedLabelStyle:
          widget.appModel.settings.enableShowTitlesAlwaysForBottomMenu == false
              ? null
              : getFontStyle(
                  11,
                  widget.appModel.settings.getBottomBarItemsColor(),
                  FontWeight.normal,
                  widget.appModel.settings),
      onTap: _onItemTapped,
    );
  }

  List<BottomNavigationBarItem> classicNavItems() {
    List<String> menuItems = [
      Localization().navBarDiscover,
      Localization().navBarMyCourses,
      Localization().navBarChat,
      Localization().navBarNews,
      Localization().navBarSettings
    ];
    List<String> menuIcons = [
      "images/icons/dashboard.svg",
      "images/icons/courses.svg",
      "images/icons/chat.svg",
      "images/icons/news.svg",
      "images/icons/settings.svg",
    ];
    List<BottomNavigationBarItem> items =
        List.generate(menuItems.length, (index) {
      return BottomNavigationBarItem(
          label: menuItems[index],
          backgroundColor: widget.appModel.settings.getBottomBarColor(),
          activeIcon: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: SvgPicture.asset(
              menuIcons[index],
              //color: Colors.white,
              width: 17,
              height: 17,
            ),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: SvgPicture.asset(
              menuIcons[index],
              height: 27,
              width: 27,
            ),
          ));
    });
    return items;
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        //_selectedPage = index;
        _selectedIndex = index;
      });
    }
  }
}
