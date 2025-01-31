import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/globalVariables.dart' as global;
import 'dart:convert';
import 'package:spotbuddy/services/NetworkUtitliy.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> G_getLocationFromLatLong(double lat, double lng) async {
  late String currentLocation;
  Uri uri = Uri.https(
    "maps.googleapis.com",
    "maps/api/geocode/json",
    {
      "latlng": "$lat,$lng",
      "key": global.g_Google_Maps_Api,
    },
  );

  String? response = await NetworkUtitliy.fetchURL(uri);
  if (response != null) {
    Map<String, dynamic> json = jsonDecode(response);
    print(response);
    if (json['status'] == 'OK') {
      currentLocation = json['results'][0]['formatted_address'];
      print("Current Location: $currentLocation");
     // mCurrentLocation = currentLocation;
      return currentLocation;
      // setState(() {
      //   _suggestions.insert(0, "$currentLocation");
      // });
    } else {
      print('Error fetching location: ${json['status']}');
      print('Error details: ${json['error_message']}'); // Log detailed error message
    }
  }
  return "";
}

String truncateText(String text, int maxWords) {
  List<String> words = text.split(' ');
  if (words.length <= maxWords) {
    return text; // Return original text if it meets the word count
  } else {
    return words.take(maxWords).join(' ') +
        '...'; // Truncate and add ellipsis
  }
}

Future<void> signOut() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await _auth.signOut();
}

Future<void> signOutGoogle() async {
  try {
    // Sign out from Google
    await googleSignIn.signOut();

    // Sign out from Firebase
    await _auth.signOut();

    print("User signed out from Google and Firebase.");
  } catch (e) {
    print("Error signing out: $e");
  }
}