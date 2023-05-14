import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:label_app/autorization/components/main_button.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:label_app/service/subscription/purchase_service.dart';
import 'package:label_app/widgets/loading.dart';

import '../helpers/font_helper.dart';
import '../models/localization.dart';
import '../service/api_service.dart';
import '../widgets/subscription_card.dart';

enum PaymentPeriod { monthly, yearly }

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({Key? key, required this.appModel}) : super(key: key);
  final RAModel appModel;
  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  int currentStep = 0;
  int selectedPlan = 1;
  List<Offering> subscriptions = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQw7NwJtcjG5VI1tRqrgNFs9vgz99v7NEpz3w&usqp=CAU",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: const BorderRadius.only(
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            FutureBuilder(
              future: PurchaseService.fetchOffers(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Offering>> snapshot) {
                if (snapshot.hasData) {
                  subscriptions = snapshot.data ?? [];
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: currentStep == 0 ? unlockWidget() : planWidget(),
                    ),
                  );
                } else {
                  return Loading(general: widget.appModel.settings);
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget unlockWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          Localization().subscriptionTitle,
          style: getFontStyle(28, Theme.of(context).primaryColor,
              FontWeight.bold, widget.appModel.settings),
        ),
        const SizedBox(height: 20.0),
        Text(
          Localization().subscriptionSubtitle,
          style: getFontStyle(
              18, Colors.grey, FontWeight.normal, widget.appModel.settings),
        ),
        const SizedBox(height: 50.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20.0),
            Text(
              "${Localization().starting} ${getProductPrice(PaymentPeriod.monthly)}",
              style: getFontStyle(18, Theme.of(context).primaryColor,
                  FontWeight.normal, widget.appModel.settings),
            )
          ],
        ),
        const SizedBox(height: 20.0),
        MainButton(
            text: Localization().choosePlan,
            onTap: () {
              setState(() {
                currentStep = 1;
              });
            },
            general: widget.appModel.settings),
        const SizedBox(height: 20.0),
        GestureDetector(
          onTap: () {
            Purchases.restorePurchases();
          },
          child: Text(
            Localization().subscribedAlready,
            style: getFontStyle(18, Colors.blueAccent, FontWeight.bold,
                widget.appModel.settings),
          ),
        )
      ],
    );
  }

  String getProductPrice(PaymentPeriod period) {
    String price = "\$0.00";
    for (Offering offer in subscriptions) {
      if (period == PaymentPeriod.monthly) {
        if (offer.monthly != null && offer.monthly?.storeProduct != null) {
          price =
              "${offer.monthly!.storeProduct!.priceString}/${Localization().month}";
          break;
        }
      } else if (period == PaymentPeriod.yearly) {
        if (offer.annual != null && offer.annual?.storeProduct != null) {
          price =
              "${offer.annual!.storeProduct!.priceString}/${Localization().year}";
          break;
        }
      }
    }

    return price;
  }

  Package? getSubscriptionPackage(PaymentPeriod period) {
    dynamic package;
    for (Offering offer in subscriptions) {
      if (period == PaymentPeriod.monthly) {
        if (offer.monthly != null && offer.monthly?.storeProduct != null) {
          package = offer.monthly!;
          break;
        }
      } else if (period == PaymentPeriod.yearly) {
        if (offer.annual != null && offer.annual?.storeProduct != null) {
          package = offer.annual!;
          break;
        }
      }
    }

    return package;
  }

  Widget planWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                Localization().choosePlan,
                style: getFontStyle(18, Theme.of(context).primaryColor,
                    FontWeight.normal, widget.appModel.settings),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3), shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentStep = 0;
                    });
                  },
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.xmark,
                      color: Colors.black,
                      size: 13,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        SubscriptionCard(
          price: getProductPrice(PaymentPeriod.monthly),
          type: Localization().monthly,
          isSelected: selectedPlan == 0 ? true : false,
          onTap: () {
            setState(() {
              selectedPlan = 0;
            });
          },
          settings: widget.appModel.settings,
        ),
        SubscriptionCard(
            price: getProductPrice(PaymentPeriod.yearly),
            type: Localization().annually,
            isSelected: selectedPlan == 1 ? true : false,
            onTap: () {
              setState(() {
                selectedPlan = 1;
              });
            },
            settings: widget.appModel.settings),
        const SizedBox(
          height: 20,
        ),
        MainButton(
            text: Localization().continueCheckout,
            onTap: () {
              if (selectedPlan == 0) {
                makePurchase(getSubscriptionPackage(PaymentPeriod.monthly));
              } else {
                makePurchase(getSubscriptionPackage(PaymentPeriod.yearly));
              }
            },
            general: widget.appModel.settings),
      ],
    );
  }

  void makePurchase(Package? package) async {
    bool isSuccess = await PurchaseService.makePurchase(package);
    if (isSuccess) {
      APIService().logEvent(AnalyticsType.subscribers);
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(Localization().paymentError),
      ));
    }
  }
}
