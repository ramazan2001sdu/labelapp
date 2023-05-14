import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:label_app/app/starter_app.dart';
import 'package:label_app/main.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:label_app/models/ra_options.dart';
import 'package:label_app/models/ra_settings.dart';
import 'package:label_app/widgets/loading.dart';

import '../service/api_service.dart';

class ServiceWidget extends StatefulWidget {
  const ServiceWidget({Key? key, required this.themeModel}) : super(key: key);
  final ThemeModel themeModel;
  @override
  State<ServiceWidget> createState() => _ServiceWidgetState();
}

class _ServiceWidgetState extends State<ServiceWidget> {
  @override
  void initState() {
    // TODO: implement initState
    APIService().logEvent(AnalyticsType.visitors);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: APIService().getAppModel(),
        builder: (BuildContext context, AsyncSnapshot<RAModel> snapshot) {
          if (!snapshot.hasData) {
            return Loading(general: RASettings());
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              RAModel raModel = snapshot.data ??
                  RAModel(options: RAOptions(), settings: RASettings());

              if (raModel.settings.enableLandscape) {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                  DeviceOrientation.landscapeRight,
                  DeviceOrientation.landscapeLeft,
                ]);
              } else {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
              }
              return StarterApp(model: raModel, themeModel: widget.themeModel);
            } else {
              return const SpinKitCircle(
                color: Colors.black,
              );
            }
          }
        });
  }
}
