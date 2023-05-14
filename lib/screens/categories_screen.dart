import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:label_app/models/ra_model.dart';

import '../helpers/font_helper.dart';
import '../main.dart';
import '../models/category.dart';
import '../models/localization.dart';
import '../widgets/tile_widget.dart';
import 'category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen(
      {Key? key, required this.appModel, required this.themeModel})
      : super(key: key);
  final RAModel appModel;
  final ThemeModel themeModel;
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: SvgPicture.asset("images/arrow-left.svg"),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(Localization().allCategories,
                      style: getFontStyle(24, Theme.of(context).primaryColor,
                          FontWeight.bold, widget.appModel.settings)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: StaggeredGrid.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: getCategories(),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<TileWidget> getCategories() {
    List<TileWidget> categories = [];
    for (RACategory cat in widget.appModel.options.categories) {
      TileWidget tile = TileWidget(
          title: cat.name,
          subtitle: getCorrectCount(cat.courses.length),
          imageUrl: cat.imageUrl,
          isEven: false,
          settings: widget.appModel.settings,
          onTap: () {
            onTileTap(cat);
          });
      categories.add(tile);
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
}
