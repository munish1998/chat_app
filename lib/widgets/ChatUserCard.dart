import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:munish_chat_app/API/api.dart';
import 'package:munish_chat_app/Screen/ChatScreen.dart';
import 'package:munish_chat_app/customize/Colors.dart';
import 'package:munish_chat_app/customize_snackbar/my_date_util.dart';
import 'package:munish_chat_app/main.dart';
import 'package:munish_chat_app/models/chat_user.dart';
import 'package:munish_chat_app/models/message.dart';
import 'package:munish_chat_app/widgets/Dialog/Profile_Dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({
    super.key,
    required this.user,
  });

  @override
  State<ChatUserCard> createState() => ChatUserCardState();

  static fromJson(Map<String, dynamic> data) {}
}

class ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        pindialogBox();
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: mq.width * .0, vertical: 4),
        color: appcolor.chatusercard_green,
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Chatscreen(user: widget.user)));
            },
            child: StreamBuilder(
              stream: API.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) _message = list[0];
                int unreadMessageCount = list.where((message) {
                  return message.fromId != API.user.uid && message.read.isEmpty;
                }).length;

                return ListTile(
                    leading: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(
                                  user: widget.user,
                                ));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .03),
                        child: CachedNetworkImage(
                          width: mq.height * .055,
                          height: mq.height * .055,
                          imageUrl: widget.user.image,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                  child: Icon(CupertinoIcons.person)),
                        ),
                      ),
                    ),
                    title: Text(widget.user.name),
                    subtitle: Text(
                        _message != null
                            ? _message!.type == Type.image
                                ? 'image'
                                : _message!.msg
                            : widget.user.about,
                        maxLines: 1),
                    trailing: _message == null
                        ? null //show nothing when no message is sent
                        : unreadMessageCount > 0
                            ? Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                    color: appcolor.green,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text(unreadMessageCount.toString())),
                              )
                            : Text(
                                MyDateUtil.getLastMessageTime(
                                    context: context, time: _message!.sent),
                                style: const TextStyle(
                                    color: appcolor.getlast_message_black),
                              ));
              },
            )),
      ),
    );
  }

  void pindialogBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.user.pinneduser ? 'Unpin User' : 'Pin User'),
          content: Text(widget.user.pinneduser
              ? 'Do you want to unpin this user?'
              : 'Do you want to pin this user?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Toggle the pin status locally
                print("Hello");
                API.changepinUser(widget.user);

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text(widget.user.pinneduser ? 'Unpin' : 'Pin'),
            ),
          ],
        );
      },
    );
  }
}
