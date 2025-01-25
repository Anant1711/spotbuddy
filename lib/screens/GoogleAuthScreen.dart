/**************************** Imports ****************************/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotbuddy/screens/HomeScreen.dart';
/**************************** Imports ****************************/

class GoogleAuthscreen extends StatefulWidget {
  const GoogleAuthscreen({super.key});

  @override
  State<GoogleAuthscreen> createState() => _GoogleAuthscreenState();
}

class _GoogleAuthscreenState extends State<GoogleAuthscreen> {
  /**************************** Variables ****************************/
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  /**************************** Variables ****************************/

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Sign in Aborted");
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final User? currentUser = userCredential.user;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Check if the user is new
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        // Navigate to Phone Authentication page for new users
        if (currentUser != null) {

          //Adding in Shared Pref
          prefs.setString("userName", currentUser.displayName ?? '');
          prefs.setString("userId", currentUser.uid);
          prefs.setString("email", currentUser.email??'');

          //Creating Field on CLOUD
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .set({
            'userID': currentUser.uid,
            'name': currentUser.displayName ?? 'Guest',
            'email': currentUser.email,
            'isPhoneNumberVerified': false,
          });
        }
        Navigator.pushReplacementNamed(context, '/phoneAuth');
      } else {
        prefs.setString("userName", currentUser?.displayName ?? '');
        prefs.setString("userId", currentUser!.uid);
        prefs.setString("email", currentUser.email??'');
        // Navigate to Homepage for existing users
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        bool isPhoneVerified = userDoc['isPhoneNumberVerified'] ?? false;

        if (isPhoneVerified) {
          // Navigate to homepage if phone is verified
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Navigate to phone authentication if phone is not verified
          Navigator.pushReplacementNamed(context, '/phoneAuth');
        }
      }
    }     catch (e) {
      if (e is FirebaseAuthException) {
        print('FirebaseAuthException: ${e.message}');
      } else if (e is PlatformException) {
        print('PlatformException: ${e.message}');
        print('PlatformException code: ${e.code}');
        print('PlatformException details: ${e.details}');
        print('Stacktrace: ${e.stacktrace}');
      } else {
        print('Unknown error: $e');
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Background color
      body: Column(
        children: [
          const Spacer(), // Pushes content to the bottom
          Center(
            child: ElevatedButton(
              onPressed: () {
                _signInWithGoogle(); // Your sign-in logic
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20), // Adjust padding as needed
                backgroundColor: const Color(0xffffffff), // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ), // Circular button shape
              ),
              // Adjust the size of the icon
              child: Image.asset(
                'assets/googleicon.png',
                height: 40, // Increase the height to make the icon larger
                width: 40,  // Increase the width to make the icon larger
              ),
            ),
          ),
          const SizedBox(height: 120), // Add some space between button and bottom edge
        ],
      ),
    );
  }

}
