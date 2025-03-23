/**************************** Imports ****************************/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:spotbuddy/firebase_options.dart';
import 'package:spotbuddy/screens/GoogleAuthScreen.dart';
import 'package:spotbuddy/screens/HomeScreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:spotbuddy/screens/PhoneAuthScreen.dart';
import 'package:spotbuddy/screens/basicDetailScreen.dart';
import 'package:spotbuddy/screens/findbuddy.dart';
import 'package:spotbuddy/screens/gender.dart';
import 'package:spotbuddy/screens/messageScreen.dart';
import 'package:spotbuddy/screens/myProfileScreen.dart';
import 'package:spotbuddy/screens/basicDetailScreen_2.dart';
import 'package:spotbuddy/screens/uploadPhotos.dart';
import 'package:spotbuddy/utils/globalVariables.dart' as global;
/**************************** Imports ****************************/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
        '/home': (context) => HomeScreen(),
        '/basicDetailsScreen': (context) => Basicdetailscreen(),
        '/basicDetailsScreen_2': (context) => basicDetailScreen_2(),
        '/genderScreen': (context) => GenderSelectionScreen(),
        '/phoneAuth': (context) => PhoneAuthScreen(),
        '/AuthScreen': (context) => GoogleAuthscreen(),
        '/messagescreen': (context) => MessagingScreenResponsive(),
        '/profile': (context) => MyProfileScreen(),
        '/findbuddy':(context) => GymBuddyScreen(),
        '/uploadPhotos':(context) => PhotoUploadScreen(),
      },
    );
  }

  ThemeData _buildTheme(brightness) {
    var baseTheme = ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: const Color(0xFFEFEFEF),
    );

    return baseTheme.copyWith(
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontFamily: "Lato", fontSize: 16,color: Colors.black),
        titleLarge: TextStyle(fontFamily: "Lato", fontWeight: FontWeight.bold, fontSize: 20,color: Colors.black),
      ),
    );
  }

}

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}
class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  var mLatitude = 0.0;
  var mLongitude = 0.0;

  @override
  void initState() {
    super.initState();
    print("checking Location:");
    _checkLocationPermission();
  }

  /// ✅ Ensure Firebase is fully initialized before checking auth state
  Future<User?> _getCurrentUser() async {
    await Future.delayed(Duration(seconds: 2)); // Ensures FirebaseAuth initializes properly
    return FirebaseAuth.instance.currentUser;

    //TODO: Add in shared Preference
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    // Check and request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied, handle accordingly
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return Future.error(
          'Location permissions are permanently denied, cannot request.');
    }

    // Permission granted, proceed to get the location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    mLatitude = position.latitude;
    mLongitude = position.longitude;

    //Setting Global Variables
    global.g_currentUserLatitude = position.latitude;
    global.g_currentUserLongitude = position.longitude;

    //TODO: Add in shared Preference

    print('Current location: ${position.latitude}, ${position.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getCurrentUser(), // ✅ Wait for Firebase Auth to fully initialize
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.fallingDot(
              color: const Color(0xff2226BA),
              size: 50,
            ),
          );
        }

        User? user = snapshot.data;

        if (user == null) {
          return GoogleAuthscreen(); // ✅ Ensure login screen is shown if user is not authenticated
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              var userData = userSnapshot.data!.data() as Map<String, dynamic>;

              bool isPhoneVerified = userData['isPhoneNumberVerified'] ?? false;
              bool isGender = userData['isGender'] ?? false;
              bool isBasicDetails = userData['isBasicDetails'] ?? false;
              bool isBasicDetails2 = userData['isBasicDetails2'] ?? false;

              if (!isPhoneVerified) {
                return PhoneAuthScreen.withOptions(
                    mLatitude, mLongitude, userData['userID']);
              } else if (!isGender) {
                return GenderSelectionScreen();
              } else if (!isBasicDetails) {
                return Basicdetailscreen();
              } else if (!isBasicDetails2) {
                return basicDetailScreen_2();
              } else {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({'CurrentLat': mLatitude, 'CurrentLong': mLongitude});

                return HomeScreen.withOptions(
                    mLatitude, mLongitude, userData['userID']);
              }
            }

            return GoogleAuthscreen();
          },
        );
      },
    );
  }
}

class FullScreenNoInternetCard extends StatelessWidget {
  const FullScreenNoInternetCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: const Center(
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, color: Colors.red, size: 60),
                SizedBox(width: 40),
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
