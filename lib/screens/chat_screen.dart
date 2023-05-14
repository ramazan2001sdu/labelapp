import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:label_app/models/localization.dart';
import 'package:label_app/models/ra_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/font_helper.dart';
import '../models/message.dart';
import '../service/api_service.dart';
import '../widgets/loading.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.model}) : super(key: key);
  final RAModel model;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? userName;
  String? userId;
  final nameController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  final scrollController = ScrollController();
  List<Message> messages = [];
  String messageText = "";
  bool _needsScroll = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
      _needsScroll = false;
    }

    userId = FirebaseAuth.instance.currentUser?.uid;
    userName = FirebaseAuth.instance.currentUser?.displayName;
    return stream();
  }

  Widget startWithNoAuthorization() {
    return FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder:
            (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (!snapshot.hasError && snapshot.hasData) {
            SharedPreferences preferences = snapshot.data!;
            if (preferences.getString("user_id") != null &&
                preferences.getString("user_name") != null) {
              userId = preferences.getString("user_id");
              userName = preferences.getString("user_name");

              return stream();
            }
            return Loading(general: widget.model.settings);
          }
          return Loading(
            general: widget.model.settings,
          );
        });
  }

  Widget stream() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("conversations")
          .doc(userId)
          .snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          var doc = snapshot.data as DocumentSnapshot;
          messages = APIService().getListMessages(doc);
          return chatArea();
        }
        return Loading(
          general: widget.model.settings,
        );
      },
    );
  }

  Widget chatArea() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Stack(
          children: <Widget>[
            ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 10, bottom: 70),
              physics: const ScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.only(
                      left: 14, right: 14, top: 10, bottom: 10),
                  child: Align(
                    alignment: (messages[index].userID != userId
                        ? Alignment.topLeft
                        : Alignment.topRight),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (messages[index].userID != userId
                            ? Colors.grey.shade200
                            : Colors.blue[200]),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: isLinkMessage(messages[index].message)
                          ? linkMessage(index)
                          : regularMessage(index),
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                            hintText: Localization().writeMessage,
                            hintStyle: getFontStyle(16, Colors.black,
                                FontWeight.normal, widget.model.settings),
                            border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        sendMessage();
                      },
                      backgroundColor: widget.model.settings.getTopBarColor(),
                      elevation: 0,
                      child: Icon(
                        Icons.send,
                        color: widget.model.settings.getTopBarItemsColor(),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage() async {
    if (messageController.text.isEmpty) {
      return;
    } else {
      Message message = Message(
          userID: userId ?? "",
          userName: userName ?? "",
          message: messageController.text);
      messages.add(message);
      messageController.text = "";
      await APIService().sendMessage(messages, userId ?? "", userName ?? "");
    }
  }

  void scrollToBottom() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  Widget regularMessage(int index) {
    return Text(
      messages[index].message,
      style: getFontStyle(
          15, Colors.black, FontWeight.normal, widget.model.settings),
    );
  }

  Widget linkMessage(int index) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(messages[index].message))) {
          await launchUrl(Uri.parse(messages[index].message));
        } else {
          // can't launch url
        }
      },
      child: Text(
        messages[index].message,
        style: getFontStyle(
            15, Colors.blue, FontWeight.normal, widget.model.settings),
      ),
    );
  }

  bool isLinkMessage(String msg) {
    String pattern =
        r'[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)';
    RegExp regExp = RegExp(pattern);
    if (msg.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(msg)) {
      return false;
    } else {
      return true;
    }
  }
}
