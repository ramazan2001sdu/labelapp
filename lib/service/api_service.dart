import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:label_app/models/category.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:universal_platform/universal_platform.dart';

import '../models/be_analytics.dart';
import '../models/course.dart';
import '../models/message.dart';
import '../models/onboarding_page.dart';
import '../models/post.dart';
import '../models/ra_options.dart';
import '../models/ra_settings.dart';
import '../models/ra_user.dart';

enum AnalyticsType { visitors, userShares, subscribers, openedCourses, device }

class APIService {
  final CollectionReference settingsCollection =
      FirebaseFirestore.instance.collection("settings");
  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection("conversations");
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("users");

  //SETTINGS FUNCTIONS---------------------------------------------------------------------
  Future<RAModel> getAppModel() async {
    RAOptions options = RAOptions();
    RASettings general = RASettings();

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("settings").get();
    RAModel app = RAModel(options: options, settings: general);

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.id == "settings") {
          app.settings = RASettings.fromJson(
              documentSnapshot.data() as Map<dynamic, dynamic>);
        }
        if (documentSnapshot.id == "options") {
          app.options = RAOptions.fromJson(
              documentSnapshot.data() as Map<dynamic, dynamic>);
        }
      }
      return app;
    }
    return app;
  }

  Future updateSettings(RASettings settings) async {
    await settingsCollection.doc("settings").set(settings.toJson());
  }

  Future<RASettings> requestSettings() async {
    DocumentSnapshot<Object?> snapshot =
        await settingsCollection.doc("settings").get();
    RASettings settings = RASettings();

    if (snapshot.data() == null) {
      return settings;
    }
    return RASettings.fromJson(snapshot.data() as Map<dynamic, dynamic>);
  }

  Future<RAOptions> requestOptions() async {
    DocumentSnapshot<Object?> snapshot =
        await settingsCollection.doc("options").get();

    if (snapshot.data() == null) {
      return RAOptions();
    }

    Map<dynamic, dynamic> itemsMaps = snapshot.data() as Map<dynamic, dynamic>;

    return RAOptions.fromJson(itemsMaps);
  }
  //----------------------------------------------------------------------------------------

  Future updateOnBoardingPages(List<OnboardingPage> items) async {
    bool keyExist = await checkIfKeyExist("items");
    if (keyExist) {
      await settingsCollection
          .doc("options")
          .update({"onBoardingPages": items.map((v) => v.toJson()).toList()});
    } else {
      await settingsCollection
          .doc("options")
          .set({"onBoardingPages": items.map((v) => v.toJson()).toList()});
    }
  }

  Future checkIfKeyExist(String key) async {
    DocumentSnapshot<Object?> snapshot =
        await settingsCollection.doc("options").get();
    if (snapshot.data() != null) {
      return true;
    } else {
      return false;
    }
  }

  sendMessage(List<Message> messages, String userId, String username) async {
    await FirebaseFirestore.instance
        .collection("conversations")
        .doc(userId)
        .set({
      "messages": messages.map((v) => v.toJson()).toList(),
      "user_name": username
    });
  }

  List<Message> getListMessages(DocumentSnapshot data) {
    List<Message> messages = [];
    if (data.exists && data["messages"] != null) {
      data['messages'].forEach((v) {
        messages.add(Message.fromJson(v));
      });
      return messages;
    }
    return messages;
  }

  Future<List<Message>> getMessages(String userId) async {
    DocumentSnapshot<Object?> snapshot = await FirebaseFirestore.instance
        .collection("conversations")
        .doc(userId)
        .get();
    List<Message> messages = [];
    if (snapshot.data() != null) {
      Map<dynamic, dynamic> data = snapshot.data() as Map<dynamic, dynamic>;
      if (data["messages"] != null) {
        data['messages'].forEach((v) {
          messages.add(Message.fromJson(v));
        });
        return messages;
      }
    }
    return messages;
  }

  Future registerUser(User user, String registerType, String name) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "user_id": user.uid,
      "display_name": user.displayName ?? name,
      "email": user.email,
      "type": registerType,
    });
  }

  Future<RaUser> addToFavourites(Course course) async {
    DocumentSnapshot<Object?> snapshot = await usersCollection
        .doc(FirebaseAuth.instance.currentUser?.uid ?? "")
        .get();
    if (snapshot.data() != null) {
      Map<dynamic, dynamic> userData = snapshot.data() as Map<dynamic, dynamic>;
      RaUser user = RaUser.fromJson(userData);
      user.favourites.add(course);
      await updateUserSettings(user);
      return user;
    }
    return RaUser(uid: "", displayName: "", email: "");
  }

  Future<RaUser> removeFromFavourites(Course course) async {
    DocumentSnapshot<Object?> snapshot = await usersCollection
        .doc(FirebaseAuth.instance.currentUser?.uid ?? "")
        .get();
    if (snapshot.data() != null) {
      Map<dynamic, dynamic> userData = snapshot.data() as Map<dynamic, dynamic>;
      RaUser user = RaUser.fromJson(userData);

      for (Course c in user.favourites) {
        if (c.name == course.name) {
          user.favourites.remove(c);
          break;
        }
      }
      await updateUserSettings(user);
      return user;
    }
    return RaUser(uid: "", displayName: "", email: "");
  }

  Future<bool> isCourseInFavourites(Course course) async {
    DocumentSnapshot<Object?> snapshot = await usersCollection
        .doc(FirebaseAuth.instance.currentUser?.uid ?? "")
        .get();
    if (snapshot.data() != null) {
      Map<dynamic, dynamic> userData = snapshot.data() as Map<dynamic, dynamic>;
      RaUser user = RaUser.fromJson(userData);
      for (Course c in user.favourites) {
        if (c.name == course.name) {
          return true;
        }
      }
    }
    return false;
  }

  logEvent(AnalyticsType type) async {
    DocumentSnapshot<Object?> snapshot = await FirebaseFirestore.instance
        .collection("analytics")
        .doc("analytics")
        .get();

    if (snapshot.data() != null) {
      Map<dynamic, dynamic> analyticsData =
          snapshot.data() as Map<dynamic, dynamic>;
      BeAnalytics analytics = BeAnalytics.fromJson(analyticsData);
      if (type == AnalyticsType.visitors) {
        analytics.visitors++; //userShares, feedbacks, userRates,
      } else if (type == AnalyticsType.subscribers) {
        analytics.subscribers++;
      } else if (type == AnalyticsType.userShares) {
        analytics.userShares++;
      } else if (type == AnalyticsType.openedCourses) {
        analytics.openedCourses++;
      } else if (type == AnalyticsType.device) {
        if (UniversalPlatform.isAndroid) {
          analytics.androidDevices++;
        } else {
          analytics.appleDevices++;
        }
      }
      await FirebaseFirestore.instance
          .collection("analytics")
          .doc("analytics")
          .update(analytics.toJson());
    } else {
      BeAnalytics analytics = BeAnalytics();
      if (type == AnalyticsType.visitors) {
        analytics.visitors++; //userShares, feedbacks, userRates,
      } else if (type == AnalyticsType.subscribers) {
        analytics.subscribers++;
      } else if (type == AnalyticsType.userShares) {
        analytics.userShares++;
      } else if (type == AnalyticsType.openedCourses) {
        analytics.openedCourses++;
      } else if (type == AnalyticsType.device) {
        if (UniversalPlatform.isAndroid) {
          analytics.androidDevices++;
        } else {
          analytics.appleDevices++;
        }
      }
      await FirebaseFirestore.instance
          .collection("analytics")
          .doc("analytics")
          .set(analytics.toJson());
    }
  }

  increasePostWatchedCount(Post post) async {
    DocumentSnapshot<Object?> snapshot =
        await settingsCollection.doc("options").get();
    if (snapshot.data() != null) {
      Map<dynamic, dynamic> itemsMaps =
          snapshot.data() as Map<dynamic, dynamic>;
      RAOptions options = RAOptions.fromJson(itemsMaps);
      for (Post inPost in options.posts) {
        if (inPost.title == post.title && inPost.text == post.text) {
          inPost.numberOfViews += 1;
          break;
        }
      }
      await updatePosts(options.posts);
    }
  }

  increaseCourseWatchedCount(Course course) async {
    DocumentSnapshot<Object?> snapshot =
        await settingsCollection.doc("options").get();

    if (snapshot.data() != null) {
      Map<dynamic, dynamic> itemsMaps =
          snapshot.data() as Map<dynamic, dynamic>;
      RAOptions options = RAOptions.fromJson(itemsMaps);
      for (RACategory category in options.categories) {
        bool isFound = false;
        for (Course inCourse in category.courses) {
          if (inCourse.name == course.name &&
              inCourse.description == course.description &&
              inCourse.level == course.level) {
            inCourse.numberOfWatchers += 1;
            isFound = true;

            break;
          }
        }
        if (isFound) {
          break;
        }
      }
      await updateCategories(options.categories);
    }
  }

  increaseCourseFavoritesCount(Course course) async {
    DocumentSnapshot<Object?> snapshot =
        await settingsCollection.doc("options").get();

    if (snapshot.data() != null) {
      Map<dynamic, dynamic> itemsMaps =
          snapshot.data() as Map<dynamic, dynamic>;
      RAOptions options = RAOptions.fromJson(itemsMaps);
      for (RACategory category in options.categories) {
        bool isFound = false;
        for (Course inCourse in category.courses) {
          if (inCourse.name == course.name &&
              inCourse.description == course.description &&
              inCourse.level == course.level) {
            inCourse.numberOfFavourites += 1;
            isFound = true;

            break;
          }
        }
        if (isFound) {
          break;
        }
      }
      await updateCategories(options.categories);
    }
  }

  decreaseCourseFavoritesCount(Course course) async {
    DocumentSnapshot<Object?> snapshot =
        await settingsCollection.doc("options").get();

    if (snapshot.data() != null) {
      Map<dynamic, dynamic> itemsMaps =
          snapshot.data() as Map<dynamic, dynamic>;
      RAOptions options = RAOptions.fromJson(itemsMaps);
      for (RACategory category in options.categories) {
        bool isFound = false;
        for (Course inCourse in category.courses) {
          if (inCourse.name == course.name &&
              inCourse.description == course.description &&
              inCourse.level == course.level) {
            inCourse.numberOfFavourites -= 1;
            isFound = true;

            break;
          }
        }
        if (isFound) {
          break;
        }
      }
      await updateCategories(options.categories);
    }
  }

  Future updateCategories(List<RACategory> items) async {
    bool keyExist = await checkIfKeyExist("categories");
    if (keyExist) {
      await settingsCollection
          .doc("options")
          .update({"categories": items.map((v) => v.toJson()).toList()});
    } else {
      await settingsCollection
          .doc("options")
          .set({"categories": items.map((v) => v.toJson()).toList()});
    }
  }

  Future updatePosts(List<Post> items) async {
    bool keyExist = await checkIfKeyExist("posts");
    if (keyExist) {
      await settingsCollection
          .doc("options")
          .update({"posts": items.map((v) => v.toJson()).toList()});
    } else {
      await settingsCollection
          .doc("options")
          .set({"posts": items.map((v) => v.toJson()).toList()});
    }
  }

  updateUserSettings(RaUser user) async {
    await usersCollection
        .doc(FirebaseAuth.instance.currentUser?.uid ?? "")
        .set(user.toJson());
  }

  Future<RaUser> getUserSettings() async {
    DocumentSnapshot<Object?> snapshot = await usersCollection
        .doc(FirebaseAuth.instance.currentUser?.uid ?? "")
        .get();

    if (snapshot.data() == null) {
      return RaUser(uid: "", displayName: "", email: "");
    }

    Map<dynamic, dynamic> itemsMaps = snapshot.data() as Map<dynamic, dynamic>;

    return RaUser.fromJson(itemsMaps);
  }

  List<Course> searchCourses(List<RACategory> categories, String searchedText) {
    List<Course> results = [];

    for (RACategory category in categories) {
      for (Course course in category.courses) {
        bool isFound = false;
        for (String tag in course.tags) {
          if (tag.toLowerCase().contains(searchedText.toLowerCase()) ||
              searchedText.toLowerCase().contains(tag.toLowerCase())) {
            isFound = true;
          }
        }
        if (isFound) {
          results.add(course);
        } else {
          if (course.name.toLowerCase().contains(searchedText.toLowerCase())) {
            results.add(course);
          } else {
            if (course.teacher
                .toLowerCase()
                .contains(searchedText.toLowerCase())) {
              results.add(course);
            }
          }
        }
      }
    }

    return results;
  }
}
