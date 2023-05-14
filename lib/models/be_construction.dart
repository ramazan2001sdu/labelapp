import 'package:flutter/material.dart';
import 'package:label_app/models/ra_model.dart';

import '../helpers/font_helper.dart';
import 'localization.dart';

class BeConstruction extends StatelessWidget {
  const BeConstruction({Key? key, required this.model}) : super(key: key);
  final RAModel model;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage(
                  "images/construction.png",
                ),
                width: 300,
                height: 300,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                Localization().weAreUnderMaintenance,
                textAlign: TextAlign.center,
                style: getFontStyle(
                    25, Colors.black, FontWeight.bold, model.settings),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                Localization().ourAppIsInMaintenance,
                textAlign: TextAlign.center,
                style: getFontStyle(
                    20, Colors.grey, FontWeight.normal, model.settings),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                Localization().weWillBeBackShortly,
                style: getFontStyle(
                    20, Colors.grey, FontWeight.normal, model.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
