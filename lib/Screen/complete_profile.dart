import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munish_chat_app/Screen/HomeScreen.dart';
import 'package:munish_chat_app/models/chat_user.dart';

class CompleteProfile extends StatefulWidget {
  final ChatUser userModel;
  final User firebaseUser;
  const CompleteProfile(
      {super.key,
      required this.userModel,
      required this.firebaseUser,
      requireduserModel});

  @override
  State<CompleteProfile> createState() => CompleteProfileState();
}

class CompleteProfileState extends State<CompleteProfile> {
  File? imagefile;
  TextEditingController fullNameController = TextEditingController();
  void selectimage(ImageSource source) async {
    XFile? pickedfile = await ImagePicker().pickImage(source: source);

    if (pickedfile != null) {
      print("no image selected");
      File convertedImage = File(pickedfile.path);
      setState(() {
        imagefile = convertedImage;
      });
    }
  }

  void checkValues() {
    String fullname = fullNameController.text.trim();

    if (fullname == "" || imagefile == null) {
      print("Please fill all the fields");
    } else {
      print("Uploading data..");
      uploadData();
    }
  }

  void uploadData() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.id.toString())
        .putFile(imagefile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullname = fullNameController.text.trim();

    widget.userModel.name = fullname;
    widget.userModel.image = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.id)
        .set(widget.userModel.toJson())
        .then((value) {
      print("Data uploaded!");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    });
  }

  void showphotooption() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("upload profile picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    selectimage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.album),
                  title: Text("select from gallery"),
                ),
                ListTile(
                  onTap: () {
                    selectimage(ImageSource.camera);
                  },
                  leading: Icon(Icons.album),
                  title: Text("Take a picture"),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  showphotooption();
                },
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      imagefile != null ? FileImage(imagefile!) : null,
                  child: Icon(
                    Icons.person,
                    size: 60,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  checkValues();
                },
                color: Theme.of(context).colorScheme.secondary,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
