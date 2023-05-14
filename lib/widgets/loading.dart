import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:label_app/models/ra_settings.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key, required this.general}) : super(key: key);
  final RASettings general;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.transparent,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [spinKit(general.loadingType)],
        ),
      ),
    );
  }

  Widget spinKit(int type) {
    if (type == 1) {
      return SpinKitRotatingPlain(
        color: general.getLoadingColor(),
        size: general.loadingSize.toDouble(),
      );
    } else if (type == 2) {
      return SpinKitDoubleBounce(
        color: general.getLoadingColor(),
        size: general.loadingSize.toDouble(),
      );
    } else if (type == 3) {
      return SpinKitWave(
        color: general.getLoadingColor(),
        size: general.loadingSize.toDouble(),
      );
    } else if (type == 4) {
      return SpinKitFadingFour(
        color: general.getLoadingColor(),
        size: general.loadingSize.toDouble(),
      );
    } else if (type == 5) {
      return SpinKitFadingCube(
        color: general.getLoadingColor(),
        size: general.loadingSize.toDouble(),
      );
    } else if (type == 6) {
      return SpinKitSpinningLines(
        color: general.getLoadingColor(),
        size: general.loadingSize.toDouble(),
      );
    } else if (type == 7) {
      return SpinKitFadingCircle(
        color: general.getLoadingColor(),
        size: general.loadingSize.toDouble(),
      );
    } else if (type == 8) {
      return SpinKitPulse(
        color: general.getLoadingColor(),
        size: general.loadingSize.toDouble(),
      );
    } else if (type == 9) {
      return SpinKitThreeBounce(
        color: general.getLoadingColor(),
        size: general.loadingSize.toDouble(),
      );
    } else if (type == 10) {
      return SpinKitChasingDots(
        color: general.getLoadingColor(),
        size: general.loadingSize.toDouble(),
      );
    } else if (type == 11) {
      return SpinKitRing(
        color: general.getLoadingColor(),
        size: general.loadingSize.toDouble(),
      );
    }
    return SpinKitWave(
      color: general.getLoadingColor(),
      size: general.loadingSize.toDouble(),
    );
  }
}
