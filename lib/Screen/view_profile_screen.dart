import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:munish_chat_app/API/api.dart';
import '../main.dart';
import '../models/chat_user.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  ViewProfileScreen({super.key, required this.user});
  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  bool isblocked = false;

  @override
  void initState() {
    super.initState();
    isblocked = widget.user.blockedUsers.contains(API.user.uid);
  }

  // String? image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(title: Text(widget.user.name)),
          floatingActionButton: //user about
              const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Joined On: ',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ),
              // Text(
              //     MyDateUtil.getLastMessageTime(
              //         context: context,
              //         time: widget.user.createdAt,
              //         showYear: true),
              //     style: const TextStyle(color: Colors.black54, fontSize: 15)),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * .03),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                  SizedBox(height: mq.height * .03),
                  Text(widget.user.email,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 16)),
                  SizedBox(height: mq.height * .05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'About: ',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      Text(widget.user.about,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 15)),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () async {
                            await API.blockUser(widget.user, API.user.uid);

                            setState(() {
                              widget.user.blockedUsers.add(API.user.uid);
                            });
                            print('User Blocked');
                          },
                          child: const Text(
                            'Block',
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          )),
                      ElevatedButton(
                          onPressed: () async {
                            if (widget.user.blockedUsers
                                .contains(API.user.uid)) {
                              await API.unblockUser(widget.user, API.user.uid);
                              setState(() {
                                widget.user.blockedUsers.remove(API.user.uid);
                              });
                              print('User Unlocked');
                            }
                          },
                          child: const Text(
                            'UnBlock',
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          )),
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }
}
