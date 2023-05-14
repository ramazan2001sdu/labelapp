import 'course.dart';

class RaUser {
  String uid = "";
  String displayName = "";
  String email = "";
  bool isPushNotificationsEnabled = false;
  bool isDarkModeEnabled = false;
  List<Course> favourites = [];

  RaUser(
      {required this.uid, required this.displayName, required this.email, this.isDarkModeEnabled = false, this.isPushNotificationsEnabled = false});

  RaUser.fromJson(Map<dynamic, dynamic> json) {
    uid = json["uid"] ?? "";
    email = json['email'] ?? "";
    displayName = json['display_name'] ?? "";
    isPushNotificationsEnabled = json['isPushNotificationsEnabled'] ?? false;
    isDarkModeEnabled = json['isDarkModeEnabled'] ?? false;
    if (json["favourites"] != null) {
      json['favourites'].forEach((v) {
        favourites.add(Course.fromJson(v));
      });
    } else {
      favourites = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["uid"] = uid;
    data["email"] = email;
    data["display_name"] = displayName;
    data["isPushNotificationsEnabled"] = isPushNotificationsEnabled;
    data["isDarkModeEnabled"] = isDarkModeEnabled;
    data["favourites"] = favourites.map((v) => v.toJson()).toList();

    return data;
  }
}
