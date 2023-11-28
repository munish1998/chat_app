import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:munish_chat_app/models/chat_user.dart';
import 'package:munish_chat_app/models/message.dart';

class API {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User get user => auth.currentUser!;
  static late ChatUser me;
  static Future<bool> userexists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getSelfinfo() async {
    return (await firestore
        .collection('users')
        .doc(user.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        print('My Data:${user.data()}');
      } else {
        await createUser().then((value) => getSelfinfo());
      }
    }));
  }

  static Future<void> createUser() async {
    // final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        name: user.displayName.toString(),
        about: " welcome to chat app",
        createdAt: '',
        id: user.uid,
        lastActive: '',
        isOnline: false,
        pushToken: '',
        email: user.email.toString(),
        blockedUsers: [],
        pinneduser: false);
    return (await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson()));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      // List<String> list
      ) {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return API.firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .snapshots();
  }

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';
  static Future<void> userUpdateInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time,
        isdelete: false,
        isStar: false);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages');
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    print('Extension: $ext');
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  static Future<List<ChatUser>> getUsersExceptCurrentUser() async {
    // Get a list of all users except the current user
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await getAllUsers().first;

    // Convert the Firestore query snapshot to a list of ChatUser objects
    final List<ChatUser> users = snapshot.docs
        .map((doc) => ChatUser.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Filter out the current user
    users.removeWhere((user) => user.id == API.user.uid);

    return users;
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> deleteformeMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return API.firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static void showForwardMessageDialog(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Forward Message'),
        content: Container(
          // Set a fixed height for the content
          height: 200,
          width: double.maxFinite,
          child: FutureBuilder<List<ChatUser>>(
            future: API.getUsersExceptCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final users = snapshot.data;
                return ListView.builder(
                  itemCount: users!.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user.name),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.image),
                      ),
                      onTap: () {
                        API.forwardMessage(user, message);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              } else {
                return const Text('No users available.');
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static void forwardMessage(ChatUser userToForward, Message message) {
    // Copy the message and change the 'fromId' to the current user's ID
    final forwardedMessage = Message(
        toId: userToForward.id,
        msg: message.msg,
        read: '',
        type: message.type,
        fromId: API.user.uid,
        sent: DateTime.now().millisecondsSinceEpoch.toString(),
        isdelete: false,
        isStar: false);

    // Send the forwarded message
    API.sendMessage(userToForward, forwardedMessage.msg, forwardedMessage.type);
  }

  static Future<void> deleteForMe(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'isdelete': true});
  }

  static Future<void> deleteForMeOtherUser(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'isdelete': true});
  }

  static Future<void> favourite(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'isStar': true});
  }

  static Future<void> Unfavpurite(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.fromId)}/message/')
        .doc(message.sent)
        .update({'isStar': false});
  }

  static Future<void> blockUser(
      ChatUser currentUser, String userIdToBlock) async {
    currentUser.blockedUsers.add(userIdToBlock);

    await firestore
        .collection("users")
        .doc(currentUser.id)
        .update({'blocked_users': currentUser.blockedUsers});
  }

  static Future<void> unblockUser(
      ChatUser currentUser, String userIdToUnblock) async {
    currentUser.blockedUsers.remove(userIdToUnblock);

    await firestore
        .collection("users")
        .doc(currentUser.id)
        .update({'blocked_users': currentUser.blockedUsers});
  }

  static Future<void> pinUser(ChatUser user) async {
    await firestore
        .collection('users')
        .doc(user.id)
        .update({'is_pinned': user.pinneduser});
  }

  static Future<void> changepinUser(ChatUser user) async {
    user.pinneduser = !user.pinneduser;
    await pinUser(user);
  }
}
