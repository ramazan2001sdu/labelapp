import 'package:flutter/material.dart';
import 'package:label_app/models/ra_settings.dart';

import '../helpers/font_helper.dart';
import '../models/localization.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard(
      {Key? key,
      required this.price,
      required this.type,
      required this.isSelected,
      required this.onTap,
      required this.settings})
      : super(key: key);
  final String price;
  final String type;
  final bool isSelected;
  final Function onTap;
  final RASettings settings;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.all(7.0),
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isSelected == true ? Colors.blueAccent : Colors.grey)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 14, color: Colors.grey, letterSpacing: 3),
                ),
                Radio(
                    value: isSelected == true ? 1 : 0,
                    groupValue: 1,
                    onChanged: (value) {
                      onTap();
                    })
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              price,
              style: getFontStyle(18, Theme.of(context).primaryColor,
                  FontWeight.bold, settings),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "${Localization().then} $price. ${Localization().cancelAnytime}.",
              style: getFontStyle(16, Colors.grey, FontWeight.normal, settings),
            ),
          ],
        ),
      ),
    );
  }
}
