import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:spotbuddy/services/NetworkUtitliy.dart';
import '../utils/globalVariables.dart' as global;

class Basicdetailscreen extends StatefulWidget {
  const Basicdetailscreen({super.key});

  @override
  State<Basicdetailscreen> createState() => _BasicdetailscreenState();
}

class _BasicdetailscreenState extends State<Basicdetailscreen> {
  /// ************************************* Variables *************************************///
  final _formKey = GlobalKey<FormState>();
  List<String> _suggestions = [];
  List<String> _placeId = [];
  bool isLoading = false;
  String m_CurrentLocation = "Location";
  String _currentLocation = "";
  late String mCurrentLocation,mLocationLink;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _gymLocationController = TextEditingController();
  DateTime? _selectedDate;
  List<MachineWeight> _machineWeights = [];
  late double m_gymLatitude;
  late double m_gymLongitutde;
  /// ************************************* Variables *************************************///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Main content
                  const Text(
                    'Tell us about yourself',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We\'ll use this information to personalize your experience.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Weight
                  TextFormField(
                    controller: _weightController,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      hintText: 'Your Body Weight in Kg',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black54, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 1.5),
                      ),
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Height
                  TextFormField(
                    controller: _heightController,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Height (cm)',
                      hintText: 'Your Height in cm',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black54, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 1.5),
                      ),
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Gym Experience
                  TextFormField(
                    controller: _experienceController,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Gym Experience (Years)',
                      hintText: 'Your Gym Experience',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black54, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 1.5),
                      ),
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your gym experience';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          hintText: 'Exercise Name',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black54, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : '',
                        ),
                        validator: (value) {
                          if (_selectedDate == null) {
                            return 'Please select your date of birth';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gym Location
                  GestureDetector(
                    onTap: () {
                      //open Bottom Sheet
                      _showLocationBottomSheet(context);
                      print("Location Pressed");
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _gymLocationController,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold),
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          labelText: "Gym Location",
                          filled: true,
                          fillColor: Colors.grey[300],
                          prefixIcon:
                          Icon(Icons.location_on, color: Colors.blueAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.blueAccent, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your gym location';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Machine Weights
                  ..._machineWeights
                      .map((weight) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: weight.nameController,
                            decoration: InputDecoration(
                              labelText: 'Exercise',
                              hintText: 'Exercise Name',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.black54, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.red, width: 1.5),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: weight.weightController,
                            decoration: InputDecoration(
                              labelText: 'Weight (kg)',
                              labelStyle: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: 'Your Weight on this Exercise',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.black54, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.red, width: 1.5),
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeMachineWeight(weight),
                        ),
                      ],
                    ),
                  ))
                      .toList(),

                  // Add Machine Weight button
                  ElevatedButton.icon(
                    onPressed: _addMachineWeight,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Machine Weight'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _addMachineWeight() {
    setState(() {
      _machineWeights.add(MachineWeight(
        nameController: TextEditingController(),
        weightController: TextEditingController(),
      ));
    });
  }

  void _removeMachineWeight(MachineWeight weight) {
    setState(() {
      _machineWeights.remove(weight);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Process the form data
      print('Weight: ${_weightController.text}');
      print('Height: ${_heightController.text}');
      print(
          'Machine Weights: ${_machineWeights.map((w) => '${w.nameController.text}: ${w.weightController.text}kg').join(', ')}');
      print('Gym Experience: ${_experienceController.text} months');
      print(
          'Date of Birth: ${DateFormat('dd-MM-yyyy').format(_selectedDate!)}');
      print('Gym Location: ${_gymLocationController.text}');

      // TODO: Navigate to the next screen or send data to backend
      _updateInCloud();
      Navigator.popAndPushNamed(context, '/basicDetailsScreen_2');
    }
  }

  Future<void> _updateInCloud()async {
    List<Map<String, dynamic>> machineWeights = _machineWeights.map((w) {
      return {
        'exercise_name': w.nameController.text,
        'weight': w.weightController.text,
      };
    }).toList();

    await FirebaseFirestore.instance.collection('users')
        .doc(global.g_currentUserId)
        .update({
      'isBasicDetails':true,
      'weight':_weightController.text,
      'height': _heightController.text,
      'gym_experience':_experienceController.text,
      'dob':DateFormat('dd-MM-yyyy').format(_selectedDate!),
      'gym_location':_gymLocationController.text,
      'gym_location_link':mLocationLink,
      'gym_lat':m_gymLatitude,
      'gym_long':m_gymLongitutde,
      'machine_weights': machineWeights,
    });
  }

  /// Google Maps Functions START ///

  // Function to get current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showTopFlushBarForEnableLocation(
          context, "Location is disabled, Please enable it");
      return Future.error('Location services are disabled.');
    }

    // Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current position
    Position position =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    print("Setting - lat: ${position.latitude} long: ${position.longitude}");
    m_gymLongitutde = position.longitude;
    m_gymLatitude = position.latitude;

    // Fetch location address from coordinates
    await _getLocationFromLatLong(position.latitude, position.longitude);

    // **Ensure UI Updates before closing modal**
    if (mounted) {
      setState(() {
        _gymLocationController.text = m_CurrentLocation;
        _currentLocation = m_CurrentLocation;
      });
    }

    generateGoogleMapsLinkFromLatLong(position.latitude, position.longitude);
  }

  // BottomSheet widget
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
                              _gymLocationController.text = m_CurrentLocation;
                              _currentLocation = m_CurrentLocation;
                            });
                            setState(() {
                              _gymLocationController.text = m_CurrentLocation;
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
                              isLoading = true; // Show loading inside modal
                            });

                            await _getCurrentLocation(); // Fetch location

                            /// **Ensure UI Updates before closing the bottom sheet**
                            setModalState(() {
                              isLoading = false; // Hide loading
                              _gymLocationController.text = m_CurrentLocation;
                              _currentLocation = m_CurrentLocation;
                            });

                            /// **Force update UI before closing**
                            Future.delayed(const Duration(milliseconds: 300), () {
                              if (mounted) {
                                setState(() {
                                  _gymLocationController.text = m_CurrentLocation;
                                  _currentLocation = m_CurrentLocation;
                                });
                              }
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
                                _gymLocationController.text = _suggestions[index];
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
      if (json['status'] == 'OK') {
        currentLocation = json['results'][0]['formatted_address'];
        print("Current Location: $currentLocation");

        // **First update global variable**
        m_CurrentLocation = currentLocation;

        // **Then update UI**
        if (mounted) {
          setState(() {
            _gymLocationController.text = m_CurrentLocation;
            _currentLocation = m_CurrentLocation;
          });
        }
      } else {
        print('Error fetching location: ${json['status']}');
        print('Error details: ${json['error_message']}');
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

        m_gymLongitutde = longitude;
        m_gymLatitude = latitude;

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
class MachineWeight {
  final TextEditingController nameController;
  final TextEditingController weightController;

  MachineWeight({required this.nameController, required this.weightController});
}
