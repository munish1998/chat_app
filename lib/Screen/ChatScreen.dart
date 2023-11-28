
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munish_chat_app/API/api.dart';
import 'package:munish_chat_app/Screen/view_profile_screen.dart';
import 'package:munish_chat_app/customize/Colors.dart';
import 'package:munish_chat_app/customize_snackbar/my_date_util.dart';
import 'package:munish_chat_app/models/chat_user.dart';
import 'package:munish_chat_app/models/message.dart';
import 'package:munish_chat_app/widgets/MessageCard.dart';

class Chatscreen extends StatefulWidget {
  final ChatUser user;
  const Chatscreen({super.key, required this.user});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final _textController = TextEditingController();
   List<Message> _list=[];
   bool _showEmoji=false,_isUploading=false;
  @override
  Widget build(BuildContext context) {
     SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.white));
        return  SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: appBar(),
          backgroundColor: appcolor.green,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                    stream: API.getAllMessages(widget.user),
                    builder:(context, snapshot) {
                      switch(snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:  
              case ConnectionState.active:
              case ConnectionState.done: 
              final data=snapshot.data?.docs;
              _list=data?.map((e) => Message.fromJson(e.data())).toList()??[];
              if( _list.isNotEmpty){
                return ListView.builder(
                     // reverse: true,
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
              return MessageCard(message: _list[index],);
                      },
                    );
              }
              else{
                return Center(child: Text("Say Hii👋",style: TextStyle(fontSize: 30,color: Colors.black,fontWeight: FontWeight.bold),));
              }
                      }
                     
                    }
                  ),
            ),
             if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2))),

           widget.user.blockedUsers.contains(API.user.uid)?
           ElevatedButton(
            onPressed:() {
              
            }, 
            child: Text("Unblock User to Send Messagged",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),)):

            _chatInput(),

            if(_showEmoji)
            SizedBox(
              height: 30,
              child: EmojiPicker(
                textEditingController: _textController,
                config: Config(
                  columns: 7,
                  emojiSizeMax: 32*(Platform.isIOS?1.30:1.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget appBar(){  
  return InkWell(
    onTap: () { 
      Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewProfileScreen(user: widget.user)));
    },
    child: StreamBuilder(
      stream: API.getUserInfo(widget.user),
      builder: (context, snapshot) {
         final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
        return Row(
      children: [
        IconButton(
          onPressed:() { 
            Navigator.pop(context);
          },
         icon: Icon(Icons.arrow_back,color: Colors.black54,)
        ),
                     ClipRRect(
                           borderRadius:
                          BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            imageUrl: list.isNotEmpty?list[0].image:widget.user.image,
                            errorWidget: (context, url, error) =>
                            const CircleAvatar(
                              backgroundColor: appcolor.green,
                            child: Icon(CupertinoIcons.person,color: Colors.white,)),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.user.name,style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400
                                    ),),
                                    Text(list.isNotEmpty?list[0].isOnline?'online'
                                    :MyDateUtil.getLastActiveTime
                                    (context: context, lastActive: list[0].lastActive)
                                    :MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                                    style: TextStyle(
                                     fontSize: 15,
                                      color: Colors.black54
                                    ),)
                                  ],
                                )
      ],
    );
      },
    )
  );
  }
Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _showEmoji=!_showEmoji;
                        });
                      },
                      icon: const Icon(Icons.emoji_emotions,
                          color: appcolor.green, size: 25)),

                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: appcolor.green),
                        border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed:() async {
                         final ImagePicker picker = ImagePicker();
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        for (var i in images) {
                          print('Image Path: ${i.path}');
                          setState(() => _isUploading = true);
                          await API.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      }, 
                       
                      
                      icon: const Icon(Icons.image,
                          color: appcolor.green, size: 26)),
                  IconButton(
                      onPressed: ()  async {
                       final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          print('Image Path: ${image.path}');
                          setState(() => _isUploading = true);
                          await API.sendChatImage(
                              widget.user, File(image.path));
                             setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: appcolor.green, size: 26)),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if(_textController.text.isNotEmpty){
                 API.sendMessage(widget.user,_textController.text,Type.text);
                _textController.text='';
              } 
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: appcolor.green,
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }

}
