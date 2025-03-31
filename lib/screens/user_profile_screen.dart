import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spotbuddy/utils/globalFunctions.dart' as globalFunctions;
import 'package:spotbuddy/utils/globalVariables.dart' as global;
import 'ChatScreen.dart';
import 'package:share_plus/share_plus.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;

  const OtherUserProfileScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _OtherUserProfileScreenState createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  bool isLoading = true;
  bool isSendingRequest = false;
  bool isFriend = false;
  bool hasSentRequest = false;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// ✅ **Fetch User Data & Friendship Status**
  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data() as Map<String, dynamic>;
        });

        /// ✅ **Check if the logged-in user & the other user are friends**
        bool friends = await globalFunctions.areUsersFriends(
            global.g_currentUserId, widget.userId);
        setState(() {
          isFriend = friends;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("🚨 Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  void _sendFriendRequest() {
    setState(() => isSendingRequest = true);
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        hasSentRequest = true;
        isSendingRequest = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share,color: Colors.white,),
            onPressed: () {
              // _showOptionsMenu(context);
              _shareProfileLink();
            },
          ),
        ],
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
                  // _buildRecentActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    String profileImage = userData['profilePicture'] ?? "assets/profile.png";
    String name = userData['name'] ?? "Unknown User";
    String status = userData['status'] ?? "No status available";
    int karma = userData['karma'] ?? 0;
    int workouts = userData['workouts'] ?? 0;
    int buddies = userData['buddies'] ?? 0;

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
          CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey[300],
            backgroundImage: profileImage.startsWith("http")
                ? NetworkImage(profileImage)
                : AssetImage(profileImage) as ImageProvider,
          ),
          SizedBox(height: 16),
          Text(name,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 8),
          Text(status, style: TextStyle(fontSize: 16, color: Colors.grey[400])),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('$karma', 'Karma'),
              SizedBox(width: 24),
              _buildStatItem('$workouts', 'Workouts'),
              SizedBox(width: 24),
              _buildStatItem('$buddies', 'Buddies'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildActionButtons() {
    bool isPremiumUser = false; // TODO: Fetch from Firebase

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isFriend) ...[
            /// ✅ **Connect Button**
            ElevatedButton(
              onPressed: hasSentRequest || isSendingRequest
                  ? null
                  : _sendFriendRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text(
                "Connect +",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 16),
          ],

          /// ✅ **Message Button - Disabled if Not Friend or Premium**
          ElevatedButton(
            onPressed: isFriend || isPremiumUser
                ? () => _openChatScreen(widget.userId)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (isFriend || isPremiumUser) ? Colors.black : Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child:  Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.message, color: (isFriend || isPremiumUser) ? Colors.white : Colors.grey, size: 24),
                SizedBox(width: 8),
                Text(
                  "Message",
                  style: TextStyle(
                      color: (isFriend || isPremiumUser) ? Colors.white : Colors.grey,
                      fontSize: 19,
                      fontWeight: FontWeight.w600),
                ),
              ],
              /*
                    child: Icon(
            Icons.message,
            color: (isFriend || isPremiumUser) ? Colors.white : Colors.grey,
            size: 24,
          ),
               */
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
                userData['email'] ?? 'No Email',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Row(
          //   children: [
          //     Icon(Icons.calendar_today, color: Colors.grey[700], size: 20),
          //     SizedBox(width: 8),
          //     Text(
          //       'Member since: ${userData['memberSince']}',
          //       style: TextStyle(fontSize: 16),
          //     ),
          //   ],
          // ),
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
            'exp.png',
            'Experience',
            '${userData['gym_experience'] ?? "N/A"} years',
          ),
          SizedBox(height: 12),
          _buildStatRowForLocation(
            'Gym Location',
            userData['gym_location'] ?? "No Location",
            userData['gym_location_link'] ?? "na",
          ),
          SizedBox(height: 12),
          _buildStatRow(
            'weight.png',
            'Weight',
            '${userData['weight'] ?? "N/A"} kg',
          ),
          SizedBox(height: 12),
          _buildStatRow(
            "height.png",
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

  Widget _buildStatRow(String iconPath, String label, String value) {
    String icon= "assets/${iconPath}";
    return Row(
      children: [
        Image.asset(
          icon,
          width: 25,  // Adjust size as needed
          height: 25,
           // Apply tint if needed
        ),
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
  Widget _buildStatRowForLocation(String label, String value, String link) {
    String icon= "assets/pin.png";
    return Row(
      children: [
        Image.asset(
          icon,
          width: 25,  // Adjust size as needed
          height: 25,
          // Apply tint if needed
        ),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              globalFunctions.openGoogleMapsLink(link);
            },
            child: Text(globalFunctions.truncateText(value,4),style: TextStyle(decoration: TextDecoration.underline),),
          ),
        )
      ],
    );
  }


  void _openChatScreen(String receiverId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUserId: global.g_currentUserId,
          receiverId: receiverId,
          receiverName: userData['name'] ?? "Unknown",
        ),
      ),
    );
  }

  void _shareProfileLink() {
    String profileLink = "https://yourapp.com/profile/${widget.userId}"; // Change this with your actual profile link
    Share.share("Check out this profile: $profileLink");
  }

}
