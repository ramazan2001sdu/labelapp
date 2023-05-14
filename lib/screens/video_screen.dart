import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:label_app/models/lesson.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:label_app/screens/subscribe_screen.dart';
import 'package:label_app/service/video_provider.dart';
import 'package:label_app/widgets/loading.dart';
// import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../helpers/font_helper.dart';
import '../helpers/globals.dart';
import '../models/course.dart';
import '../models/entitlement.dart';
import '../models/localization.dart';
import '../service/subscription/revenue_cat.dart';
import 'detail_screen.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen(
      {Key? key,
      required this.appModel,
      required this.course,
      required this.index})
      : super(key: key);
  final RAModel appModel;
  final Course course;
  final int index;
  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoProvider provider;
  bool isLandscape = false;
  int playingIndex = 0;

  RevenueCatProvider catProvider = RevenueCatProvider();

  @override
  void initState() {
    playingIndex = widget.index;
    provider = VideoProvider(lessons: widget.course.lessons);
    provider.loadVideoControllers();
    catProvider = RevenueCatProvider();
    super.initState();
  }

  @override
  void dispose() {
    provider.cleanAllControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: FutureBuilder(
        future: catProvider.updatePurchasesStatus(),
        builder: (BuildContext context, AsyncSnapshot<Entitlement> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            isSubscribed =
                snapshot.data == Entitlement.subscribed ? true : false;
            return mainWidget();
          } else {
            return Stack(
              children: [
                mainWidget(),
                Center(
                  child: Loading(general: widget.appModel.settings),
                )
              ],
            );
          }
        },
      ),
    );
  }

  Widget mainWidget() {
    return Column(
      children: [
        Stack(
          children: [
            getVideoSource(),
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 40),
              child: GestureDetector(
                onTap: () {
                  if (isLandscape == false) {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                    Navigator.pop(context, true);
                  } else {
                    provider
                        .getYTController(playingIndex)
                        .toggleFullScreenMode();
                  }
                },
                child: SvgPicture.asset("images/arrow-left.svg"),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              color: Theme.of(context).backgroundColor,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Localization().courseLessons,
                              style: getFontStyle(
                                  24,
                                  Theme.of(context).primaryColor,
                                  FontWeight.bold,
                                  widget.appModel.settings)),
                          const SizedBox(height: 30),
                          Column(
                            children: getLessons(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getVideoSource() {
    if (provider.getCurrentLesson(playingIndex).videoType ==
        VideoType.firebase) {
      return firebaseVideo();
    } else if (provider.getCurrentLesson(playingIndex).videoType ==
        VideoType.youtube) {
      return youTubeVideo();
    } else {
      return vimeoVideo();
    }
  }

  Widget firebaseVideo() {
    return FlickVideoPlayer(
        flickManager: provider.getFirebaseController(playingIndex));
  }

  Widget vimeoVideo() {
    return SizedBox(
      height: 250,
      // child: VimeoVideoPlayer(
      //   vimeoPlayerModel: VimeoPlayerModel(
      //     url: provider.getCurrentLesson(playingIndex).videoURL,
      //     deviceOrientation: DeviceOrientation.portraitUp,
      //     systemUiOverlay: const [
      //       SystemUiOverlay.top,
      //       SystemUiOverlay.bottom,
      //     ],
      //   ),
      //   url: '',
      // ),
    );
  }

  Widget youTubeVideo() {
    return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: provider.getYTController(playingIndex),
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.green,
          progressColors: ProgressBarColors(
              playedColor: Colors.green,
              handleColor: Colors.greenAccent,
              bufferedColor: Colors.white.withAlpha(0),
              backgroundColor: Colors.grey),
        ),
        onExitFullScreen: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          if (isLandscape == true) {
            debugPrint("exit fullscreen");
            setState(() {
              isLandscape = false;
            });
          }
        },
        onEnterFullScreen: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          if (isLandscape == false) {
            debugPrint("enter fullscreen");
            setState(() {
              isLandscape = true;
            });
          }
        },
        builder: (context, player) {
          return Column(
            children: [
              SizedBox(
                height: isLandscape == true
                    ? MediaQuery.of(context).size.height - 5
                    : MediaQuery.of(context).size.height / 3.7,
                child: player,
              ),
            ],
          );
        });
  }

  List<CourseContent> getLessons(BuildContext context) {
    List<CourseContent> lessons = [];
    for (int i = 0; i < widget.course.lessons.length; i++) {
      String number = "";
      if (i > 9) {
        number = i.toString();
      } else {
        number = "0$i";
      }
      RALesson lesson = widget.course.lessons[i];
      CourseContent l = CourseContent(
        number: number,
        duration: lesson.duration,
        title: lesson.name,
        isDone: isSubscribed
            ? true
            : i > 0
                ? false
                : true,
        showPauseIcon: playingIndex == i ? true : false,
        index: i,
        onPlay: (index) async {
          if (isSubscribed || index == 0) {
            provider.pausePreviousVideos();
            setState(() {
              playingIndex = i;
            });
          } else {
            bool result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubscribeScreen(
                  appModel: widget.appModel,
                ),
              ),
            );
            if (result) {
              setState(() {
                debugPrint("refreshing...");
              });
            }
          }
        },
      );
      lessons.add(l);
    }
    return lessons;
  }
}
