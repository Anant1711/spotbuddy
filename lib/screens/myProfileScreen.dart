import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/globalVariables.dart' as globalVariable;

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final GlobalKey<ScaffoldState> _profileScaffoldKey = GlobalKey<ScaffoldState>();

  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
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

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // ✅ Wait for currentUserId
      );
    }

    return Scaffold(
      key: _profileScaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              // TODO: Implement edit profile functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.data!.exists) {
              return Center(child: Text("User not found"));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

            return Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    userData['profileImage'] ?? 'https://default.com/profile.png',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userData['name'] ?? 'Unknown User',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  userData['bio'] ?? 'Fitness Enthusiast',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('Workouts', userData['workouts']?.toString() ?? '0'),
                    _buildStatColumn('Buddies', userData['buddies']?.toString() ?? '0'),
                    _buildStatColumn('Karma', userData['karma']?.toString() ?? '0'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('My Achievements'),
                _buildAchievementsList(userData['achievements']),
                const SizedBox(height: 20),
                _buildSectionTitle('Fitness Goals'),
                _buildGoalsList(userData['goals']),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// ✅ **Build Stats Column**
  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  /// ✅ **Build Section Title**
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// ✅ **Build Achievements List**
  Widget _buildAchievementsList(dynamic achievements) {
    if (achievements == null || achievements.isEmpty) {
      return Center(child: Text("No Achievements Yet", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        var achievement = achievements[index] as Map<String, dynamic>;
        return ListTile(
          leading: Icon(Icons.emoji_events, color: Colors.amber),
          title: Text(achievement['title'] ?? "Unknown Achievement"),
          subtitle: Text(achievement['date'] ?? "No Date"),
        );
      },
    );
  }

  /// ✅ **Build Goals List**
  Widget _buildGoalsList(dynamic goals) {
    if (goals == null || goals.isEmpty) {
      return Center(child: Text("No Goals Set 🎯", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        var goal = goals[index] as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goal['title'] ?? "No Goal"),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (goal['progress'] ?? 0.0).toDouble(),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ],
          ),
        );
      },
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

//TODO: New UI
/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool isLoading = false;

  // Dummy user data for my profile
  final Map<String, dynamic> userData = {
    'name': 'John Smith',
    'status': 'Fitness Enthusiast',
    'profilePicture':
    'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/image-QPO2xJvrscRL3kyQNn5zG50lODp82k.png',
    'karma': 450,
    'workouts': 120,
    'buddies': 25,
    'bio':
    'Passionate about fitness and helping others achieve their goals. I love weight training and running marathons on weekends.',
    'workoutTypes': ['Weight Training', 'Cardio', 'HIIT'],
    'preferredWorkoutTime': 'Evening',
    'gym_experience': '3',
    'gym_location': 'Fitness First, Downtown',
    'weight': '75',
    'height': '180',
    'machine_weights': [
      {'exercise_name': 'Bench Press', 'weight': '85'},
      {'exercise_name': 'Squat', 'weight': '120'},
      {'exercise_name': 'Deadlift', 'weight': '140'},
    ],
    'email': 'john.smith@example.com',
    'memberSince': 'January 2023',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text('My Profile'),
      //   backgroundColor: Colors.black,
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.settings),
      //       onPressed: () {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           SnackBar(content: Text('Settings coming soon')),
      //         );
      //       },
      //     ),
      //   ],
      // ),
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
            _buildRecentActivity(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Profile tab
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.handshake_outlined), label: 'GymBuddy'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Message'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.popAndPushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.popAndPushNamed(context, '/findbuddy');
          } else if (index == 2) {
            Navigator.popAndPushNamed(context, '/messages');
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
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
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: NetworkImage(
                  userData['profilePicture'],
                ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Change profile picture')),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            userData['name'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            userData['status'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('${userData['karma']}', 'Karma'),
              SizedBox(width: 24),
              _buildStatItem('${userData['workouts']}', 'Workouts'),
              SizedBox(width: 24),
              _buildStatItem('${userData['buddies']}', 'Buddies'),
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
            userData['bio'],
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
                userData['email'],
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
    List<String> workoutTypes = List<String>.from(userData['workoutTypes']);
    String preferredTime = userData['preferredWorkoutTime'];

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
            '${userData['gym_experience']} years',
          ),
          SizedBox(height: 12),
          _buildStatRow(
            Icons.location_on,
            'Gym Location',
            userData['gym_location'],
          ),
          SizedBox(height: 12),
          _buildStatRow(
            Icons.monitor_weight,
            'Weight',
            '${userData['weight']} kg',
          ),
          SizedBox(height: 12),
          _buildStatRow(
            Icons.height,
            'Height',
            '${userData['height']} cm',
          ),

          // Machine weights section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              ...List<Map<String, dynamic>>.from(userData['machine_weights'])
                  .map((weight) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(weight['exercise_name']),
                    Row(
                      children: [
                        Text(
                          '${weight['weight']} kg',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                  Text('Edit record coming soon')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ))
                  .toList(),
            ],
          ),
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
}
*/
