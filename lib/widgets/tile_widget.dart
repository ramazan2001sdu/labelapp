import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../helpers/font_helper.dart';
import '../models/ra_settings.dart';

class TileWidget extends StatelessWidget {
  const TileWidget(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.imageUrl,
      required this.isEven,
      required this.settings,
      required this.onTap})
      : super(key: key);
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isEven;
  final RASettings settings;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        height: isEven ? 200 : 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: getFontStyle(20, Colors.white, FontWeight.bold, settings),
            ),
            Text(
              subtitle,
              style: getFontStyle(15, Colors.white.withOpacity(.5), FontWeight.bold, settings),
            )
          ],
        ),
      ),
    );
  }
}
