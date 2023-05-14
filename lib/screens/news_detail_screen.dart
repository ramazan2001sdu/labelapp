import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:label_app/models/post.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:share_plus/share_plus.dart';

import '../models/localization.dart';
import '../service/api_service.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({Key? key, required this.appModel, required this.post})
      : super(key: key);
  final RAModel appModel;
  final Post post;
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void initState() {
    // TODO: implement initState
    APIService().increasePostWatchedCount(widget.post);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: widget.post.imageURL,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60.0),
                        topRight: Radius.circular(60.0)),
                  ),
                  child: const SizedBox(width: 1),
                ),
              ),
              Positioned(
                top: 10,
                left: 0,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      GestureDetector(
                          onTap: () {
                            Share.share(
                                "${widget.post.text} ${widget.post.imageURL}",
                                subject: widget.post.title);
                          },
                          child: const FaIcon(
                            FontAwesomeIcons.share,
                            color: Colors.white,
                            size: 26,
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                        fontSize: 28.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.timer,
                            color: Colors.grey,
                            size: 16.0,
                          ),
                          const SizedBox(width: 2.0),
                          Text(
                            widget.post.dateToString(),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16.0),
                          )
                        ],
                      ),
                      const SizedBox(width: 20.0),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.remove_red_eye,
                            color: Colors.grey,
                            size: 16.0,
                          ),
                          const SizedBox(width: 2.0),
                          Text(
                            "${widget.post.numberOfViews} ${Localization().views}",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16.0),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            widget.post.authorImageURL),
                        radius: 28.0,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        widget.post.authorName,
                        style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8),
                      )
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    widget.post.text,
                    style: const TextStyle(
                        fontSize: 18.0, color: Colors.grey, letterSpacing: 1),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
