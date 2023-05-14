import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/post.dart';

class PostWidget extends StatelessWidget {
  final List<Post> posts;
  final Function onTap;
  const PostWidget({super.key, required this.onTap, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: posts.length,
            itemBuilder: (BuildContext context, int index) {
              final Post post = posts[index];
              return GestureDetector(
                onTap: () => {onTap(posts[index])},
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Stack(
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width - 40,
                          height: MediaQuery.of(context).size.width * 0.90,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.0),
                              color: Colors.white,
                              boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0.0, 4.0), blurRadius: 10.0, spreadRadius: 0.10)]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14.0),
                            child: CachedNetworkImage(
                              imageUrl: post.imageURL,
                              fit: BoxFit.cover,
                            ),
                          )),
                      Positioned(
                        bottom: 10.0,
                        left: 10.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.60,
                              child: Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(radius: 10.0, backgroundImage: CachedNetworkImageProvider(post.authorImageURL)),
                                const SizedBox(width: 8.0),
                                Text(post.authorName, style: const TextStyle(color: Colors.white, fontSize: 14.0)),
                              ],
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10.0,
                        right: 10.0,
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.timer,
                              size: 10.0,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5.0),
                            Text(post.dateToString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ))
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10.0,
                        right: 10.0,
                        child: GestureDetector(
                            onTap: () {
                              Share.share("${post.text} ${post.imageURL}", subject: post.title);
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.share,
                              color: Colors.white,
                              size: 26,
                            )),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 5.0)
      ],
    );
  }
}
