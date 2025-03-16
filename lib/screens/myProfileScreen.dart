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
