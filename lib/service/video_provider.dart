import 'package:flick_video_player/flick_video_player.dart';
import 'package:label_app/models/lesson.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoProvider {
  List<RALesson> lessons = [];
  List<dynamic> videoControllers = [];

  VideoProvider({required this.lessons});

  loadVideoControllers() {
    for (var lesson in lessons) {
      if (lesson.videoType == VideoType.youtube) {
        YoutubePlayerController controller = YoutubePlayerController(
          initialVideoId: YoutubePlayer.convertUrlToId(lesson.videoURL) ?? "",
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
          ),
        );
        RAController ctr = RAController(lesson: lesson, controller: controller);
        videoControllers.add(ctr);
      } else if (lesson.videoType == VideoType.firebase) {
        FlickManager flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.network(lesson.videoURL),
        );
        RAController ctr =
            RAController(lesson: lesson, controller: flickManager);
        videoControllers.add(ctr);
      } else {
        videoControllers.add(RAController(lesson: lesson, controller: null));
      }
    }
  }

  cleanAllControllers() {
    for (RAController controller in videoControllers) {
      if (controller.controller != null) {
        controller.controller.dispose();
      }
    }
  }

  YoutubePlayerController getYTController(int index) {
    return videoControllers[index].controller;
  }

  FlickManager getFirebaseController(int index) {
    return videoControllers[index].controller;
  }

  RALesson getCurrentLesson(int index) {
    return videoControllers[index].lesson;
  }

  pausePreviousVideos() {
    for (RAController controller in videoControllers) {
      if (controller.controller != null) {
        if (controller.lesson.videoType == VideoType.youtube) {
          controller.controller.pause();
        } else if (controller.lesson.videoType == VideoType.firebase) {
          controller.controller.flickVideoManager?.videoPlayerController
              ?.pause();
        }
      }
    }
  }
}

class RAController {
  RALesson lesson;
  dynamic controller;

  RAController({required this.lesson, required this.controller});
}
