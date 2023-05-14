import 'package:purchases_flutter/purchases_flutter.dart';

import '../../models/entitlement.dart';

class RevenueCatProvider {
  RevenueCatProvider() {
    init();
  }

  Entitlement _entitlement = Entitlement.free;
  Entitlement get entitlement => _entitlement;

  Future init() async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      updatePurchasesStatus();
    });
  }

  Future<Entitlement> updatePurchasesStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();

    final entitlements = customerInfo.entitlements.active.values.toList();
    _entitlement = entitlements.isEmpty ? Entitlement.free : Entitlement.subscribed;
    print(entitlements);
    return _entitlement;
  }
}
