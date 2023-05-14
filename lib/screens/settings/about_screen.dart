import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/be_image.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key, required this.appModel}) : super(key: key);
  final RAModel appModel;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 25, top: 30),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: SvgPicture.asset("images/arrow-left.svg"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                BeImage(
                  link: widget.appModel.settings.logoUrl,
                  width: 250,
                  height: 250,
                ),
                const SizedBox(
                  height: 10,
                ),
                socialIcons(),
                const SizedBox(
                  height: 30,
                ),
                HtmlWidget(widget.appModel.settings.aboutUs)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget socialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Visibility(
            visible: widget.appModel.settings.facebook.isNotEmpty,
            child: GestureDetector(
              onTap: () {
                lunchUrl(widget.appModel.settings.facebook);
              },
              child: SizedBox(
                width: 40,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FaIcon(FontAwesomeIcons.facebook,
                      color: Theme.of(context).primaryColor),
                ),
              ),
            )),
        Visibility(
            visible: widget.appModel.settings.instagram.isNotEmpty,
            child: GestureDetector(
              onTap: () {
                lunchUrl(widget.appModel.settings.instagram);
              },
              child: SizedBox(
                width: 40,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FaIcon(FontAwesomeIcons.instagram,
                      color: Theme.of(context).primaryColor),
                ),
              ),
            )),
        Visibility(
            visible: widget.appModel.settings.twitter.isNotEmpty,
            child: GestureDetector(
              onTap: () {
                lunchUrl(widget.appModel.settings.twitter);
              },
              child: SizedBox(
                width: 40,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FaIcon(FontAwesomeIcons.twitter,
                      color: Theme.of(context).primaryColor),
                ),
              ),
            )),
        Visibility(
            visible: widget.appModel.settings.pinterest.isNotEmpty,
            child: GestureDetector(
              onTap: () {
                lunchUrl(widget.appModel.settings.pinterest);
              },
              child: SizedBox(
                width: 40,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FaIcon(FontAwesomeIcons.pinterest,
                      color: Theme.of(context).primaryColor),
                ),
              ),
            )),
        Visibility(
            visible: widget.appModel.settings.linkedin.isNotEmpty,
            child: GestureDetector(
              onTap: () {
                lunchUrl(widget.appModel.settings.linkedin);
              },
              child: SizedBox(
                width: 40,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FaIcon(FontAwesomeIcons.linkedin,
                      color: Theme.of(context).primaryColor),
                ),
              ),
            )),
        Visibility(
            visible: widget.appModel.settings.tiktok.isNotEmpty,
            child: GestureDetector(
              onTap: () {
                lunchUrl(widget.appModel.settings.tiktok);
              },
              child: SizedBox(
                width: 40,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FaIcon(FontAwesomeIcons.tiktok,
                      color: Theme.of(context).primaryColor),
                ),
              ),
            )),
        Visibility(
            visible: widget.appModel.settings.youtube.isNotEmpty,
            child: GestureDetector(
              onTap: () {
                lunchUrl(widget.appModel.settings.youtube);
              },
              child: SizedBox(
                width: 40,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FaIcon(FontAwesomeIcons.youtube,
                      color: Theme.of(context).primaryColor),
                ),
              ),
            )),
        Visibility(
            visible: widget.appModel.settings.vimeo.isNotEmpty,
            child: GestureDetector(
              onTap: () {
                lunchUrl(widget.appModel.settings.vimeo);
              },
              child: SizedBox(
                width: 15,
                height: 40,
                child: FaIcon(
                  FontAwesomeIcons.vimeo,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )),
      ],
    );
  }

  void lunchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw "Could not launch $url";
    }
  }
}
