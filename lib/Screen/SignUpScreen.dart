// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:munish_chat_app/Routes/route_name.dart';
// import 'package:munish_chat_app/models/chat_user.dart';
// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({ Key? key }) : super(key: key);

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {

//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController cPasswordController = TextEditingController();

//   // void createAccount() async {
//   //   String email = emailController.text.trim();
//   //   String password = passwordController.text.trim();
//   //   String cPassword = cPasswordController.text.trim();

//   //   if(email == "" || password == "" || cPassword == "") {
//   //     log("Please fill all the details!");
//   //   }
//   //   else if(password != cPassword) {
//   //     log("Passwords do not match!");
//   //   }
//   //   else {
//   //     try {
//   //       UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
//   //       if(userCredential.user != null) {
//   //         print("user created");
//   //       }
//   //     } on FirebaseAuthException catch(ex) {
//   //       print(ex.code.toString());
//   //     }
//   //   }
//   // }
//   void checkUser () async{
//  String email = emailController.text.trim();
//  String password = passwordController.text.trim();
//  String cpassword = cPasswordController.text.trim();

//  if (email== "" || password=="" || cpassword==""){
//  print("Please fill all the remaining feilds");
//  // Utils.showAlertDialog(context, "Error", "Please fill all the remaining feilds");
//  }
//  else if (password != cpassword){
//  print("Password doesn't match");
//  //Utils.showAlertDialog(context, "Error", "Password doesn't match");
//  }
//  else {
//  // print("Data uploading....");
//  createAccount(email, password);
//  }
// }

// void createAccount (String email, String password) async{
//  UserCredential? userCredential;

//  //Utils.showLoadingDialog(context, "Creating new account");
//  try{
//  // create new Account
//  userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//  email: email, 
//  password: password
//  );
//  } on FirebaseAuthException catch(ex){
//  //Navigator.pop(context);
//  //Utils.showAlertDialog(context,"An error occoured", ex.message.toString());
//  print(ex.code.toString());
//  }

//  if (userCredential != null) {
//  final time=DateTime.now().millisecondsSinceEpoch.toString();
 
//  String uid = userCredential.user!.uid;
//  ChatUser newUser = ChatUser(
//  isOnline: false, 
//  id: uid, 
//  createdAt:time, 
//  pushToken: '', 
//  image: "", 
//  email: email, 
//  about: "Available Now", 
//  lastActive: time, 
//  name: "", 
// //  blockedUsers: [], 
// //  isPinned: false
//  );
//  // print(userCredential.credential);
//  await FirebaseFirestore.instance.collection("users").doc(uid).set(newUser.toJson()).then((value) {
//  print("New User created");
//  Navigator.popUntil(context, ModalRoute.withName('login'));
//  Navigator.pushNamed(context, RouteName.completeProfile,arguments: {
//  'chatuser' : newUser,
//  'firebaseUser' : userCredential!.user
//  });
//  });
 
//  }
// }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           title: Text("Create an account"),
//         ),
//         body: SafeArea(
//           child: ListView(
//             children: [
    
//               Padding(
//                 padding: EdgeInsets.all(15),
//                 child: Column(
//                   children: [
                    
//                     TextField(
//                       controller: emailController,
//                       decoration: InputDecoration(
//                         labelText: "Email Address"
//                       ),
//                     ),
    
//                     SizedBox(height: 10,),
    
//                     TextField(
//                       controller: passwordController,
//                       decoration: InputDecoration(
//                         labelText: "Password"
//                       ),
//                     ),

//                     SizedBox(height: 10,),
//                     TextField(
//                       controller: cPasswordController,
//                       decoration: InputDecoration(
//                         labelText: "Confirm Password"
//                       ),
//                     ),
//                     SizedBox(height: 20,),
//                     CupertinoButton(
//                       onPressed: () {
//                         checkUser();
                        
//                       },
//                       color: Colors.blue,
//                       child: Text("Create Account"),
//                     )
    
//                   ],
//                 ),
//               )
    
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }