import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spotbuddy/utils/globalFunctions.dart' as globalFunctions;
import 'package:spotbuddy/utils/globalVariables.dart' as global;
import 'ChatScreen.dart';

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
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context);
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
                  // _buildInfoSection('About'),
                  // _buildWorkoutPreferences(),
                  // _buildGymStats(),
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

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListTile(
          leading: Icon(Icons.report),
          title: Text('Report User'),
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Report submitted')));
          },
        );
      },
    );
  }
}
