import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:label_app/models/ra_model.dart';

import '../helpers/font_helper.dart';
import '../models/localization.dart';
import '../widgets/post_widget.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key, required this.appModel}) : super(key: key);
  final RAModel appModel;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, top: 25, right: 20),
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        Localization().newsTitle,
                        style: getFontStyle(28, Theme.of(context).primaryColor,
                            FontWeight.bold, widget.appModel.settings),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 100,
                        child: Text(
                          Localization().newsSubtitle,
                          style: getFontStyle(
                              20,
                              Theme.of(context).primaryColor,
                              FontWeight.normal,
                              widget.appModel.settings),
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
            ),
            PostWidget(
              posts: widget.appModel.options.posts,
              onTap: (post) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(
                      appModel: widget.appModel,
                      post: post,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
