import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/globalVariables.dart' as global;

class basicDetailScreen_2 extends StatefulWidget {
  const basicDetailScreen_2({super.key});

  @override
  State<basicDetailScreen_2> createState() => _basicDetailScreen_2State();
}

class _basicDetailScreen_2State extends State<basicDetailScreen_2> {

  /// **************************** Variables **************************** ///
  final _formKey2 = GlobalKey<FormState>();
  String? _selectedWorkoutTime;
  List<String> _selectedWorkoutDays = [];
  List<String> _selectedWorkoutTypes = [];
  final List<String> _workoutDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    '6 Days Workout (GYM-Rat)'
  ];
  final List<String> _workoutTimes = [
    'Morning',
    'Afternoon',
    'Evening',
    'Flexible'
  ];
  final List<String> _workoutTypes = [
    'Cardio',
    'Strength Training',
    'CrossFit',
    'Yoga'
  ];
  /// **************************** Variables **************************** ///

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey2,
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
                  // TextFormField(
                  //   controller: _weightController,
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  //   decoration: InputDecoration(
                  //     labelText: 'Weight (kg)',
                  //     hintText: 'Your Body Weight in Kg',
                  //     hintStyle: TextStyle(color: Colors.grey[500]),
                  //     filled: true,
                  //     fillColor: Colors.grey[300],
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: BorderSide.none,
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: BorderSide(color: Colors.black54, width: 2),
                  //     ),
                  //     errorBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: BorderSide(color: Colors.red, width: 1.5),
                  //     ),
                  //     labelStyle: TextStyle(
                  //       color: Colors.grey[700],
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  //   keyboardType: TextInputType.number,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter your weight';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  Text(
                    'Workout Days',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    children: _workoutDays.map((type) {
                      final bool isSelected = _selectedWorkoutDays.contains(type);
                      return FilterChip(
                        backgroundColor: Colors.grey[300],
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                        checkmarkColor: Colors.white,
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedWorkoutDays.add(type);
                            } else {
                              _selectedWorkoutDays.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Preferred Workout Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    children: _workoutTimes.map((time) {
                      final bool isSelected = _selectedWorkoutTime == time;
                      return ChoiceChip(
                        backgroundColor: Colors.grey[300],
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: isSelected ? Colors.white : Colors.black87),
                        checkmarkColor: Colors.white,
                        label: Text(time),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedWorkoutTime = selected ? time : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 30),
                  // const SizedBox(height: 16),

                  Text(
                    'Workout Types',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    children: _workoutTypes.map((type) {
                      final bool isSelected = _selectedWorkoutTypes.contains(type);
                      return FilterChip(
                        backgroundColor: Colors.grey[300],
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                        checkmarkColor: Colors.white,
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedWorkoutTypes.add(type);
                            } else {
                              _selectedWorkoutTypes.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
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
  Future<void> _submitForm() async{
    debugPrint(_selectedWorkoutDays.toString());
    debugPrint(_selectedWorkoutTypes.toString());
    debugPrint(_selectedWorkoutTime.toString());

    await FirebaseFirestore.instance.collection('users')
        .doc(global.g_currentUserId)
        .update({
      'isBasicDetails2':true,
      'workoutDays':_selectedWorkoutDays,
      'workoutTime': _selectedWorkoutTime,
      'workoutTypes':_selectedWorkoutTypes,
    });

    // Navigator.popAndPushNamed(context, '/home');
    Navigator.popAndPushNamed(context, '/uploadPhotos');
  }
}
