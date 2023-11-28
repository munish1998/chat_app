import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:munish_chat_app/API/api.dart';
import 'package:munish_chat_app/Screen/ProfileScreen.dart';
import 'package:munish_chat_app/customize/Colors.dart';
import 'package:munish_chat_app/main.dart';
import 'package:munish_chat_app/models/chat_user.dart';
import 'package:munish_chat_app/widgets/ChatUserCard.dart';

void main() {
  Firebase.initializeApp();
  runApp(const MyApp());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  List<ChatUser> list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  void initState() {
    super.initState();
    API.getSelfinfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      print('Message: $message');
      if (API.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          API.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          API.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appcolor.green,
          leading: const Icon(CupertinoIcons.home),
          title: _isSearching
              ? TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Name, Email, ...'),
                  autofocus: true,
                  style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                  onChanged: (val) {
                    _searchList.clear();

                    for (var i in list) {
                      if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                          i.email.toLowerCase().contains(val.toLowerCase())) {
                        _searchList.add(i);
                        setState(() {
                          _searchList;
                        });
                      }
                    }
                  },
                )
              : const Text('We Chat'),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search)),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: API.me)));
                },
                icon: const Icon(Icons.person))
          ],
        ),
        body: StreamBuilder(
           // stream: API.firestore.collection('users').snapshots(),
            stream: API.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];

                  // final List<ChatUser> pinmyUsers =
                  //     list.where((user) => user.pinneduser).toList();
                  // final List<ChatUser> unPinmyUsers =
                  //     list.where((user) => !user.pinneduser).toList();

                
                  // final List<ChatUser> sortMyUser = [ ...pinmyUsers, ...unPinmyUsers];
                  final List<ChatUser> pinmyUsers =list.where((user) => user.pinneduser).toList();
                  final List<ChatUser>unPinmyUsers=list.where((user) =>!user.pinneduser ).toList();
                  final List<ChatUser>sortMyUser=[...pinmyUsers,...unPinmyUsers];
                  if (sortMyUser.isNotEmpty) {
                    return ListView.builder(
                      itemCount:
                          _isSearching ? _searchList.length : sortMyUser.length,
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                            user: _isSearching
                                ? _searchList[index]
                                : sortMyUser[index]
                                );
                      },
                    );
                  } else {
                    return Center(
                        child: Text(
                      "No connections found",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ));
                  }
              }
            }));
  }
}
