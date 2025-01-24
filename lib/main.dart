/**************************** Imports ****************************/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:spotbuddy/firebase_options.dart';
import 'package:spotbuddy/screens/AuthScreen.dart';
/**************************** Imports ****************************/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,);
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
    // await FirebaseAppCheck.instance.activate(
    //   // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    //   // argument for `webProvider`
    //   webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    //   // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    //   // your preferred provider. Choose from:
    //   // 1. Debug provider
    //   // 2. Safety Net provider
    //   // 3. Play Integrity provider
    //   androidProvider: AndroidProvider.debug,
    //   // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    //   // your preferred provider. Choose from:
    //   // 1. Debug provider
    //   // 2. Device Check provider
    //   // 3. App Attest provider
    //   // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    //   appleProvider: AppleProvider.appAttest,
    // );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  runApp(const SpotBuddyApp());
}

class SpotBuddyApp extends StatelessWidget {
  const SpotBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: const Color(0xffDCDBE2),
      theme: _buildTheme(Brightness.light),
      title: 'SpotBuddy',
      home: AuthenticationWrapper(),
      routes: {
        '/home':(context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        'AuthScreen': (context) => Authscreen(),
      },
    );
  }

  ThemeData _buildTheme(brightness) {
    var baseTheme = ThemeData(brightness: brightness);

    return baseTheme.copyWith(
      textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingAnimationWidget.fallingDot(color: const Color(0xff2226BA), size: 50);
        } else if (snapshot.hasData) {
          return HomeScreen(); // Use HomeScreen here
        } else {
          return Authscreen(); // Show AuthScreen for unauthenticated users
        }
      },
    );
  }
}
