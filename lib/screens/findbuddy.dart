/// ************************ Imports ************************ ///
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:spotbuddy/services/NetworkUtitliy.dart';
import '../utils/globalVariables.dart' as global;
import'../utils/globalFunctions.dart' as globalFunctions;
/// ************************ Import ************************ ///


class GymBuddyScreen extends StatefulWidget {
  const GymBuddyScreen({Key? key}) : super(key: key);

  @override
  State<GymBuddyScreen> createState() => _GymBuddyScreenState();
}

class _GymBuddyScreenState extends State<GymBuddyScreen> {
  /// ************************ Variables ************************ ///
  String m_CurrentLocation = "Location";
  String mLocationLink = "";
  List<String> _suggestions = [];
  List<String> _placeId = [];
  String _currentLocation = "Set Location";
  final TextEditingController _locationController = TextEditingController();
  bool isLoading = false; // Tracks whether location fetching is in progress
  /// ************************ Variables ************************ ///

  Future<void> fetchCurrentLocation() async {
    String newLocation = await globalFunctions.G_getLocationFromLatLong(global.g_currentUserLatitude,global.g_currentUserLongitude);
    setState(() {
      m_CurrentLocation = newLocation;
    });
  }

  void initState(){
    super.initState();
    fetchCurrentLocation();
  }

  GlobalKey<ScaffoldState> _findbuddyscaffoldKey = GlobalKey<ScaffoldState>();
  String selectedTab = "My Workouts";
  String selectedWorkout = "Weight Training";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _findbuddyscaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: GestureDetector(
          onTap: () {
            _findbuddyscaffoldKey.currentState?.openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: CircleAvatar(
              backgroundImage: const NetworkImage(
                'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/image-QPO2xJvrscRL3kyQNn5zG50lODp82k.png',
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _showLocationBottomSheet(context);
            },
            child: Text(
              globalFunctions.truncateText(m_CurrentLocation, 3), // Truncate to 3 words
              style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900),
              overflow: TextOverflow.ellipsis, // Handle overflow
              softWrap: true, // Allow wrapping if needed
            ),
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.black),
            onPressed: () {
              _showLocationBottomSheet(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 70.0, horizontal: 16.0),
          children: <Widget>[
            ListTile(
              title: const Text(
                'Home',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Workout Types
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildWorkoutButton('Weight Training', Icons.fitness_center),
                const SizedBox(width: 12),
                _buildWorkoutButton('Cardio', Icons.directions_run),
                const SizedBox(width: 12),
                _buildWorkoutButton('Yoga', Icons.self_improvement),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Session Cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildSessionCard(
                  type: 'Weight Training',
                  name: 'Alex Johnson',
                  karma: '350',
                  status: 'Looking for Partner',
                  time: '27 Jan, 6:00 AM',
                  location: 'FitZone Gym, Downtown',
                  distance: '1.5 Kms',
                  level: 'Advanced',
                  slots: 2,
                ),
                const SizedBox(height: 16),
                _buildSessionCard(
                  type: 'Weight Training',
                  name: 'Alex Johnson',
                  karma: '350',
                  status: 'Looking for Partner',
                  time: '27 Jan, 6:00 AM',
                  location: 'FitZone Gym, Downtown',
                  distance: '1.5 Kms',
                  level: 'Advanced',
                  slots: 2,
                ),
                const SizedBox(height: 16),
                _buildSessionCard(
                  type: 'Weight Training',
                  name: 'Sarah Williams',
                  karma: '275',
                  status: 'Morning Workout',
                  time: '27 Jan, 7:30 AM',
                  location: 'PowerHouse Fitness',
                  distance: '2.3 Kms',
                  level: 'Intermediate',
                  slots: 3,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.handshake_outlined), label: 'GymBuddy'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Message'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.popAndPushNamed(
              context,
              '/home');
          } else if (index == 2) {
            //navigation to Message screen
            Navigator.popAndPushNamed(context, "/messagescreen");
          } else if (index == 3) {
            // navigation to Profile screen
            Navigator.popAndPushNamed(context, "/profile");
          }
        },
      ),
    );
  }

  Widget _buildWorkoutButton(String title, IconData icon) {
    final isSelected = selectedWorkout == title;
    return ElevatedButton.icon(
      onPressed: () => setState(() => selectedWorkout = title),
      icon: Icon(icon),
      label: Text(title,style: TextStyle(fontWeight: FontWeight.w900),),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.black : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSessionCard({
    required String type,
    required String name,
    required String karma,
    required String status,
    required String time,
    required String location,
    required String distance,
    required String level,
    required int slots,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$type • Regular',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(Icons.bookmark_border, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                      'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/image-QPO2xJvrscRL3kyQNn5zG50lODp82k.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name | $karma Karma | $status',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '$location • $distance',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    level,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  /// Google Maps Functions START ///

  // Function to get current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, so request the user to enable them
      showTopFlushBarForEnableLocation(context,"Location is disabled, Please enable it");
      return Future.error('Location services are disabled.');
    }

    // Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try requesting permissions again
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Use the current coordinates (latitude, longitude) to fetch the location address
    print("lat: ${position.latitude} long: ${position.longitude}");
    _getLocationFromLatLong(position.latitude, position.longitude);
    generateGoogleMapsLinkFromLatLong(position.latitude, position.longitude);
  }

  void _showLocationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        final mediaQuery = MediaQuery.of(context);
        final modalHeight = mediaQuery.size.height * 0.8;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SizedBox(
              height: modalHeight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Location",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// **Search Location Field**
                    Form(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                            hintText: 'Search Location',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: const Icon(Icons.location_pin,
                                color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                          ),
                          onChanged: (value) {
                            _placeAutoComplete(value);
                            setModalState(() {
                              _locationController.text = m_CurrentLocation;
                              _currentLocation = m_CurrentLocation;
                            });
                            setState(() {
                              _locationController.text = m_CurrentLocation;
                              _currentLocation = m_CurrentLocation;
                            });
                          },
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// **Use My Current Location Button**
                    Center(
                      child: SizedBox(
                        width: mediaQuery.size.width * 0.8,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null // Disable button when loading
                              : () async {
                            setModalState(() {
                              isLoading = true; // Show loading
                            });

                            await _getCurrentLocation(); // Fetch location

                            setModalState(() {
                              isLoading = false; // Hide loading
                              _locationController.text = m_CurrentLocation;
                              _currentLocation = m_CurrentLocation;
                            });

                            Navigator.of(context).pop(true); // Close modal
                            FocusScope.of(context).unfocus();
                            _suggestions.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blueAccent,
                          ),
                          child: isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Use my current location',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// **Location Suggestions List**
                    Expanded(
                      child: isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blueAccent,
                        ),
                      )
                          : ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _suggestions[index],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              setModalState(() {
                                _locationController.text = _suggestions[index];
                                m_CurrentLocation = _suggestions[index];
                                _currentLocation = _suggestions[index];
                              });

                              _fetchPlaceDetails(_placeId[index]);
                              Navigator.of(context).pop(true);
                              FocusScope.of(context).unfocus();
                              _suggestions.clear();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Reverse geocode to get address from lat/lng
  Future<void> _getLocationFromLatLong(double lat, double lng) async {
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
        m_CurrentLocation = currentLocation;
        _currentLocation = currentLocation;

        setState(() {
          _suggestions.insert(0, "$currentLocation");
        });
      } else {
        print('Error fetching location: ${json['status']}');
        print('Error details: ${json['error_message']}'); // Log detailed error message
      }
    }
  }

  //Widget for Location Permission
  void showTopFlushBarForEnableLocation(BuildContext context, String message) {
    Flushbar(
      messageColor: Colors.black,
      message: message,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(8),
      icon: const Icon(
        Icons.location_off_outlined,
        size: 30.0,
        color: Colors.red,
      ),
      flushbarPosition: FlushbarPosition.TOP, // Positioning at the top
      duration: Duration(seconds: 10), // Display duration
      backgroundColor: Colors.white,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeInOut,
      reverseAnimationCurve: Curves.easeOut,
      // Adding a button to enable location services
      mainButton: TextButton(
        onPressed: () {
          // Navigate to the device location settings
          Geolocator.openLocationSettings();
          // Optionally, dismiss the Flushbar
          Navigator.of(context).pop();
        },
        child: Text(
          'Enable',
          style: TextStyle(color: Colors.blue),
        ),
      ),
    ).show(context);
  }

  void _fetchPlaceDetails(String placeId) async {
    print("Fetching details for Place ID: $placeId");

    Uri uri = Uri.https(
      "maps.googleapis.com",
      "maps/api/place/details/json",
      {
        "place_id": placeId,
        "key": global.g_Google_Maps_Api,
      },
    );

    String? response = await NetworkUtitliy.fetchURL(uri);
    if (response != null) {
      Map<String, dynamic> json = jsonDecode(response);
      if (json['status'] == 'OK') {
        Map<String, dynamic> location = json['result']['geometry']['location'];
        double latitude = location['lat'];
        double longitude = location['lng'];

        // Get formatted address from API response
        String formattedAddress = json['result']['formatted_address'];

        // Update global and UI variables
        setState(() {
          m_CurrentLocation = formattedAddress;
          _currentLocation = formattedAddress;
        });

        print("Updated Location: $m_CurrentLocation");
        generateGoogleMapsLinkFromLatLong(latitude, longitude);
      } else {
        print('Error fetching place details: ${json['status']}');
      }
    }
  }


  //For Redirect user to Google maps with party location
  String generateGoogleMapsLinkFromLatLong(double lat, double lng) {
    mLocationLink = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    return "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
  }

  void _placeAutoComplete(String query) async {
    Uri uri = Uri.https(
      "maps.googleapis.com",
      "maps/api/place/autocomplete/json",
      {
        "input": query,
        "key": global.g_Google_Maps_Api,
      },
    );

    String? response = await NetworkUtitliy.fetchURL(uri);
    print(response);
    if (response != null) {
      Map<String, dynamic> json = jsonDecode(response);
      if (json['status'] == 'OK') {
        List<dynamic> predictions = json['predictions'];
        List<String> placeId = [];
        List<String> suggestions = [];
        for(var prediction in predictions){
          suggestions.add(prediction['description'].toString());
          placeId.add(prediction['place_id'].toString());
        }

        setState(() {
          _suggestions = suggestions; // Update the suggestions list
          _placeId = placeId;
        });
      } else {
        print('Error fetching suggestions: ${json['status']}');
      }
    }
  }

/// Google Maps Function END ///
}
