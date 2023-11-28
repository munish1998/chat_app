import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:munish_chat_app/API/api.dart';
import 'package:munish_chat_app/Screen/HomeScreen.dart';
import 'package:munish_chat_app/customize/Colors.dart';
import 'package:munish_chat_app/customize/app_string.dart';
import 'package:munish_chat_app/firebase_options.dart';
import 'package:munish_chat_app/customize_snackbar/dialogs.dart';
import 'package:munish_chat_app/main.dart';
import 'package:munish_chat_app/models/chat_user.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void checkValues() {
 String email = emailController.text.trim();
 String password = passwordController.text.trim();

 if (email == "" || password == "") {
 print("Please enter login details");
//  Utils.showAlertDialog(context, "Error", "Field can't be empty");
 } else {
 login(email, password);
 }
 }

 void login(String email, String password) async {
 UserCredential? userCredential;

//  Utils.showLoadingDialog(context);

 try {
 userCredential = await FirebaseAuth.instance
 .signInWithEmailAndPassword(email: email, password: password);
 // Utils().closeLoader(context);
 } on FirebaseAuthException catch (ex) {
 Navigator.pop(context);
 print(ex.code.toString());
 }

 if (userCredential != null) {
 String uid = userCredential.user!.uid;
 DocumentSnapshot userData =
 await FirebaseFirestore.instance.collection('users').doc(uid).get();
 ChatUser chatuser =
 ChatUser.fromJson(userData.data() as Map<String, dynamic>);

 // ignore: use_build_context_synchronously
 Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomeScreen()));
 print("login sucessfully");
 }
 }

  _handleGoogleBtnClick() {
    // Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      if (user != null) {
        print('\nUser: ${user.user}');
        print('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await API.userexists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await API.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
              clientId: DefaultFirebaseOptions.currentPlatform.iosClientId)
          .signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await API.auth.signInWithCredential(credential);
    } catch (e) {
      print('\n_signInWithGoogle: $e');
       Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet!)');
      return null;
    }
  }
  void initState(){
    super.initState();
    Future.delayed(Duration(seconds: 5),(){
      setState(() {
      });
    });
  }
  @override
  Widget build(BuildContext context) {
  mq = MediaQuery.of(context).size;
  // return Scaffold(
  //     appBar: AppBar(
  //       centerTitle: true,
  //       title: Text('Welcome'),
  //       backgroundColor: Colors.orange,
  //     ),
  //     body: SafeArea(
  //       child: Column(
  //         children: [
  //           Padding(
  //             padding: EdgeInsets.only(left: 20,top: 40),
  //             child: Container(
  //               width: 350,
  //               child: TextFormField(
  //                 controller: emailController,
  //                 decoration: InputDecoration(
  //                   labelText: " email address",
  //                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))
  //                 ),
  //               ),
  //             ),
  //           ),
  //           SizedBox(height: 20,),
  //           Padding(
  //             padding: EdgeInsets.only(left: 20,top: 30),
  //             child: Container(
  //               width: 350,
  //               child: TextFormField(
  //                 controller: passwordController,
  //                 obscureText: true,
  //                 decoration: InputDecoration(
  //                   labelText: " password",
  //                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))
  //                 ),
  //               ),
  //             ),
  //           ),
  //           SizedBox(
  //             height: 20,
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               checkValues();
  //             },
  //             child: Text('Login'),
  //           ),
            
  //           CupertinoButton(child: Text('Create an account'), onPressed: (){
  //             Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));
  //           }),
  //              Positioned(
  //           bottom: mq.height * .15,
  //           left: mq.width * .05,
  //           width: mq.width * .9,
  //           height: mq.height * .06,
  //           child: ElevatedButton.icon(
  //               style: ElevatedButton.styleFrom(
  //                   backgroundColor: Color.fromARGB(255, 236, 238, 235),
  //                   shape: const StadiumBorder(),
  //                   elevation: 1),
  //               onPressed: () {
  //                 _handleGoogleBtnClick();
  //               },
  //               icon: Image.asset('assets/google.png', height: mq.height * .03),
  //               label: RichText(
  //                 text: const TextSpan(
  //                     style: TextStyle(color: Colors.black, fontSize: 16),
  //                     children: [
  //                       TextSpan(
  //                           text: appstring.googletext,
  //                           style: TextStyle(fontWeight: FontWeight.w500)),
  //                     ]),
  //               ))),
           
  //         ],
  //       ),
  //     ),
  //   );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(appstring.text),
        backgroundColor: appcolor.green,
      ),
      body: Stack(children: [
        Padding(
          padding: EdgeInsets.only(top: 140,left: 90),
          child: Text(appstring.text1,style: TextStyle(
            fontSize: 40,fontWeight: FontWeight.bold,color: appcolor.green
          ),),
        ),
      SizedBox(height: 50,),
        Center(
          child:Image.asset('assets/chat1_image.png',scale: 5,)
        ),
        Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .06,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 236, 238, 235),
                    shape: const StadiumBorder(),
                    elevation: 1),
                onPressed: () {
                  _handleGoogleBtnClick();
                },
                icon: Image.asset('assets/google.png', height: mq.height * .03),
                label: RichText(
                  text: const TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(
                            text: appstring.googletext,
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                ))),
      ]),
     );
  }
}

