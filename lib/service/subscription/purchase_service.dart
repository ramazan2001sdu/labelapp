import 'package:flutter/services.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  static const _apiKey = 'goog_UBkAqJlRcFminWFIekBMeeCULCR';

  static Future init() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.configure(PurchasesConfiguration(_apiKey));
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      return current == null ? [] : [current];
    } on PlatformException catch (e) {
      return [];
    }
  }

  static Future<bool> makePurchase(Package? package) async {
    if (package != null) {
      try {
        await Purchases.purchasePackage(package);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
