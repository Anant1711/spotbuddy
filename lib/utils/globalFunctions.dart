import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
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

Future<String> fetchUserName(String userId) async {
  if (userId.isEmpty) {
    print("🚨 Error: userId is empty!");
    return "Unknown User";
  }

  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      return userDoc['name'] ?? "Unknown User";
    } else {
      print("Error: User not found for ID $userId");
      return "Unknown User";
    }
  } catch (e) {
    print("Firestore error while fetching userName: $e");
    return "Unknown User";
  }
}

String formatTimestamp(dynamic timestamp) {
  if (timestamp is Timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
    return "${dateTime.hour}:${dateTime.minute} ${dateTime.hour >= 12 ? 'PM' : 'AM'}"; // Format as HH:MM AM/PM
  }
  return "Unknown Time"; // Fallback if timestamp is null or invalid
}

Future<bool> areUsersFriends(String currentUserId, String otherUserId) async {
  if (currentUserId.isEmpty || otherUserId.isEmpty) {
    print("🚨 Error: One of the user IDs is empty!");
    return false;
  }

  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    List<dynamic> friendsList = userDoc['friends'] ?? [];

    return friendsList.contains(otherUserId); // ✅ Check if otherUserId exists in friends list
  } catch (e) {
    print("🚨 Firestore error while checking friendship: $e");
    return false;
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
double _degToRad(double deg) {
  return deg * (pi / 180);
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  print("User lat: $lat1 Long: $lon1");
  print("Second Person lat: $lat2 Long: $lon2");
  const double R = 6371; // Radius of the Earth in kilometers
  final double dLat = _degToRad(lat2 - lat1);
  final double dLon = _degToRad(lon2 - lon1);
  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  print("R * c = ${R*c}");
  return R * c; // Distance in kilometers
}