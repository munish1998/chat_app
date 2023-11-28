import 'package:flutter/material.dart';
import 'package:munish_chat_app/Routes/route_name.dart';
import 'package:munish_chat_app/Screen/HomeScreen.dart';
import 'package:munish_chat_app/Screen/LoginScreen.dart';
import 'package:munish_chat_app/Screen/complete_profile.dart';

class Routes{

 static Route<dynamic> generateRoute(RouteSettings settings){

 switch(settings.name){

 case RouteName.home:
 return MaterialPageRoute(builder: (BuildContext context) =>const HomeScreen());

 case RouteName.login:
 return MaterialPageRoute(builder: (BuildContext context) =>const LoginScreen());

//  case RoutesName.signUp:
//  return MaterialPageRoute(builder: (BuildContext context) =>const SignUpScreen());

//  case RoutesName.splash:
//  return MaterialPageRoute(builder: (BuildContext context) =>const SplashScreen());

 case RouteName.completeProfile:
 Map<String, dynamic> map1 = settings.arguments as Map<String, dynamic>;
 return MaterialPageRoute(builder: (BuildContext context) =>CompleteProfile(userModel: map1['chatuser'], firebaseUser: map1['firebaseUser']));

 default:
 return MaterialPageRoute(builder:(_){
 return const Scaffold(
 body: Center(
 child: Text("No Route Defined"),
 ),
 );
 }); 
 }
 }
}
