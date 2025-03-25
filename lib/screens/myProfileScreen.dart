import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import '../utils/globalVariables.dart' as globalVariable;

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final GlobalKey<ScaffoldState> _profileScaffoldKey = GlobalKey<ScaffoldState>();

  String? currentUserId;
  Map<String, dynamic> userData = {};
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    String userId = globalVariable.g_currentUserId; // 🔥 Replace with actual user ID from Firebase Auth
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  /// ✅ **Fetch Current User ID**
  void _fetchCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  /// ✅ **Pick Image from Gallery & Upload to Firebase**
  Future<void> _changeProfilePicture() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      File file = File(pickedFile.path);
      String userId = globalVariable.g_currentUserId; // Replace with actual user ID
      String filePath = "user_photos/$userId/profile.jpg";

      Reference ref = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);

      setState(() => isLoading = true);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profilePicture': downloadUrl,
      });

      setState(() {
        userData['profilePicture'] = downloadUrl;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      print("🚨 Error updating profile picture: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // ✅ Wait for currentUserId
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Profile',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            _buildActionButtons(),
            _buildInfoSection('About'),
            _buildWorkoutPreferences(),
            _buildGymStats(),
            // _buildRecentActivity(),  //TODO
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
  Widget _buildProfileHeader() {
    ImageProvider profileImage = userData['profilePicture'] != null &&
        userData['profilePicture'].isNotEmpty
        ? NetworkImage(userData['profilePicture'])
        : AssetImage('assets/profile.png') as ImageProvider; // ✅ Default image
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white,
                backgroundImage: profileImage

              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.black, size: 20),
                  onPressed: () {
                    _changeProfilePicture();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            globalVariable.g_currentUsername ?? "Unknown", // ✅ Fetching from Firestore with fallback
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            userData['status'] ?? "No status available", // ✅ Fetching from Firestore with fallback
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('${userData['karma'] ?? 0}', 'Karma'), // ✅ Default to 0 if missing
              SizedBox(width: 24),
              _buildStatItem('${userData['workouts'] ?? 0}', 'Workouts'), // ✅ Default to 0
              SizedBox(width: 24),
              _buildStatItem('${userData['buddies'] ?? 0}', 'Buddies'), // ✅ Default to 0
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Edit profile coming soon')),
                );
              },
              icon: Icon(Icons.edit, color: Colors.white),
              label:
              Text('Edit Profile', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share profile coming soon')),
                );
              },
              icon: Icon(Icons.share, color: Colors.black),
              label:
              Text('Share Profile', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit bio coming soon')),
                  );
                },
              ),
            ],
          ),
          Text(
            userData['bio'] ?? "No Bio",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.email, color: Colors.grey[700], size: 20),
              SizedBox(width: 8),
              Text(
                globalVariable.g_currentUserEmailId ?? 'No Email',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Member since: ${userData['memberSince']}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutPreferences() {
    List<String> workoutTypes = userData['workoutTypes'] != null
        ? List<String>.from(userData['workoutTypes'] as List<dynamic>)
        : []; // ✅ Default to empty list if null

    String preferredTime = userData['workoutTime'] is String
        ? userData['workoutTime']
        : (userData['workoutTime'] is List<dynamic>)
        ? (userData['workoutTime'] as List<dynamic>).join(", ")
        : "N/A"; // ✅ Default to "N/A" if null


    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workout Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit preferences coming soon')),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey[700]),
              SizedBox(width: 8),
              Text(
                'Preferred Time: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                preferredTime,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Workout Types:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: workoutTypes
                .map((type) => Chip(
              label: Text(type),
              backgroundColor: Colors.grey[200],
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGymStats() {
    // ✅ Handle `machine_weights` safely
    List<Map<String, dynamic>> machineWeights = (userData['machine_weights'] ?? [])
        .map<Map<String, dynamic>>((weight) => Map<String, dynamic>.from(weight))
        .toList();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gym Stats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit stats coming soon')),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildStatRow(
            Icons.fitness_center,
            'Experience',
            '${userData['gym_experience'] ?? "N/A"} years',
          ),
          SizedBox(height: 12),
          _buildStatRow(
            Icons.location_on,
            'Gym Location',
            userData['gym_location'] ?? "No Location",
          ),
          SizedBox(height: 12),
          _buildStatRow(
            Icons.monitor_weight,
            'Weight',
            '${userData['weight'] ?? "N/A"} kg',
          ),
          SizedBox(height: 12),
          _buildStatRow(
            Icons.height,
            'Height',
            '${userData['height'] ?? "N/A"} cm',
          ),

          // ✅ Show "Personal Records" only if machine weights exist
          if (machineWeights.isNotEmpty) ...[
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Records',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 18),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Add record coming soon')),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Column(
              children: machineWeights.map((weight) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(weight['exercise_name'] ?? "Unknown Exercise"),
                      Row(
                        children: [
                          Text(
                            '${weight['weight'] ?? "N/A"} kg',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Edit record coming soon')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  Widget _buildRecentActivity() {
    // Dummy activity data
    final activities = [
      {
        'type': 'workout',
        'description': 'Completed a chest day workout',
        'time': DateTime.now().subtract(Duration(days: 1)),
      },
      {
        'type': 'achievement',
        'description': 'Set a new personal record on bench press',
        'time': DateTime.now().subtract(Duration(days: 3)),
      },
      {
        'type': 'buddy',
        'description': 'Connected with Sarah Williams',
        'time': DateTime.now().subtract(Duration(days: 5)),
      },
    ];

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('View all activity coming soon')),
                  );
                },
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...activities.map((activity) => _buildActivityItem(
            activity['type'] as String,
            activity['description'] as String,
            activity['time'] as DateTime,
          )),
        ],
      ),
    );
  }
  Widget _buildActivityItem(String type, String description, DateTime time) {
    IconData icon;
    Color iconColor;

    switch (type) {
      case 'workout':
        icon = Icons.fitness_center;
        iconColor = Colors.blue;
        break;
      case 'achievement':
        icon = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case 'buddy':
        icon = Icons.people;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.event_note;
        iconColor = Colors.grey;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(time),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  /// ✅ **Build Bottom Navigation Bar**
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 3,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.handshake_outlined), label: 'GymBuddy'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Message'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.popAndPushNamed(context, '/home');
        } else if (index == 1) {
          Navigator.popAndPushNamed(context, '/findbuddy');
        } else if (index == 2) {
          Navigator.popAndPushNamed(context, '/messagescreen');
        }
      },
    );
  }

}