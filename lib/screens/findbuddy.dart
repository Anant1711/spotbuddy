import 'package:flutter/material.dart';
import 'package:spotbuddy/screens/HomeScreen.dart';
import 'package:spotbuddy/screens/messageScreen.dart';
import 'package:spotbuddy/screens/profileScreen.dart';
import '../utils/globalVariables.dart' as global;

class GymBuddyScreen extends StatefulWidget {
  const GymBuddyScreen({Key? key}) : super(key: key);

  @override
  State<GymBuddyScreen> createState() => _GymBuddyScreenState();
}

class _GymBuddyScreenState extends State<GymBuddyScreen> {
  GlobalKey<ScaffoldState> _findbuddyscaffoldKey =
      GlobalKey<ScaffoldState>();
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
          Text(
            global.g_currentUsername,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 17),
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.black),
            onPressed: () {
              // TODO: Implement action for the dropdown
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
            // TODO: Implement navigation to Message screen
            Navigator.popAndPushNamed(context, "/messagescreen");
          } else if (index == 3) {
            // TODO: Implement navigation to Profile screen
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
}
