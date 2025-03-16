import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "findbuddy.dart";
import "../utils/globalVariables.dart" as global;

class HomeScreen extends StatefulWidget {
  late var lat, long;
  late String mUid;

  HomeScreen();
  HomeScreen.withOptions(this.lat, this.long, this.mUid);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // String g_userName = "";
  GlobalKey<ScaffoldState> _homeScreenscaffoldKey =
  GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  Future<void> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    String? userID = prefs.getString('userId');
    debugPrint("User Name: $userName");
    setState(() {
      global.g_currentUsername = userName ?? ''; // Use a fallback if userName is null
      global.g_currentUserId = userID ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _homeScreenscaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            _homeScreenscaffoldKey.currentState?.openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: const NetworkImage(
                'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/image-QPO2xJvrscRL3kyQNn5zG50lODp82k.png',
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello,',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
            ),
            Text(
              global.g_currentUsername,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Member',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promotions Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_offer,
                              color: Colors.purple[300], size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Promotions',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Brand and Gym Promotions will come here...',
                        style:
                        TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: const Text(
                          '24 May 2024',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'My Healthy Lifestyle',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLifestyleItem(
                      Icons.assignment, 'Bookings', () {}),
                  _buildLifestyleItem(
                      Icons.fitness_center, 'Gym', () {}),
                  _buildLifestyleItem(Icons.person, 'Trainer', () {}),
                  _buildLifestyleItem(
                      Icons.help_outline, 'Inquiry', () {}),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Common Service',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildServiceCard(
                      'Fitness\nEquipment', Colors.blue, () {}),
                  _buildServiceCard(
                      'Couple\nFitness', Colors.purple, () {}),
                  _buildServiceCard(
                      'Trainer\nClass', Colors.orange, () {}),
                  _buildServiceCard(
                      'Nutrition\nPrograms', Colors.green, () {}),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.popAndPushNamed(
                context,
                '/findbuddy');
          } else if (index == 2) {
            Navigator.popAndPushNamed(
                context,
                '/messagescreen');
            debugPrint('Messages Tab: $index');
          } else if (index == 3) {
            Navigator.popAndPushNamed(
                context,
                '/profile');
            debugPrint('Profile Tab: $index');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.handshake_outlined), label: 'GymBuddy'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Message'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildLifestyleItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

