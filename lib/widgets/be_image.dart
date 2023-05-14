import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BeImage extends StatelessWidget {
  const BeImage({Key? key, required this.link, this.width, this.height, this.fit}) : super(key: key);
  final String link;
  final double? width;
  final double? height;
  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: link,
      width: width ?? 100,
      height: height ?? 100,
      fit: fit ?? BoxFit.contain,
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
