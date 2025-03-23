import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotbuddy/screens/user_profile_screen.dart';
import 'ChatScreen.dart';
import '../utils/globalFunctions.dart' as globalFunction;
import '../utils/globalVariables.dart' as globalVariable;

class MessagingScreenResponsive extends StatefulWidget {
  const MessagingScreenResponsive({super.key});

  @override
  State<MessagingScreenResponsive> createState() => _MessagingScreenResponsiveState();
}

class _MessagingScreenResponsiveState extends State<MessagingScreenResponsive> {
  GlobalKey<ScaffoldState> _messagingScaffoldKey = GlobalKey<ScaffoldState>();
  String currentUserId = ""; // Store User ID

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
  }

  /// ✅ Fetch `currentUserId` only once in `initState()`
  void _fetchCurrentUserId() async {
    setState(() {
      currentUserId = globalVariable.g_currentUserId;
    });

    if (currentUserId.isEmpty) {
      print("🚨 Error: User ID is empty! Ensure authentication is completed.");
    } else {
      print("✅ currentUserId: $currentUserId");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // Prevent Firestore errors
      );
    }

    return DefaultTabController(
      length: 2, // ✅ Two Tabs (Messages & Friend Requests)
      child: Scaffold(
        key: _messagingScaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Messages & Requests',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: const [
              Tab(text: 'Messages'),
              Tab(text: 'Friend Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMessagesColumn(),
            _buildFriendRequestsColumn(),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  /// ✅ Fetch Messages From Firestore
  Widget _buildMessagesColumn() {
    if (currentUserId.isEmpty) {
      return Center(child: Text("Fetching messages..."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var messages = snapshot.data!.docs;

        if (messages.isEmpty) {
          return Center(child: Text("No messages yet"));
        }

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var msg = messages[index];
            String chatId = msg.id; // Chat ID from Firestore

            return FutureBuilder<String>(
              future: globalFunction.fetchUserName(msg['receiverId']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text("Loading...", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Fetching details..."),
                  );
                }
                if (snapshot.hasError) {
                  return ListTile(
                    title: Text("Unknown User", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Could not fetch user details"),
                  );
                }

                String receiverName = snapshot.data ?? "Unknown User";

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 25.0),
                  title: Text(receiverName, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(globalFunction.truncateText(msg['lastMessage'], 4),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(globalFunction.formatTimestamp(msg['timestamp'])),
                  onTap: () {
                    globalFunction.navigateWithSlideAnimation(context,ChatScreen(
                      currentUserId: currentUserId, // Pass logged-in user ID
                      receiverId: msg['receiverId'],
                      receiverName: receiverName,
                    ),);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ChatScreen(
                    //       currentUserId: currentUserId, // Pass logged-in user ID
                    //       receiverId: msg['receiverId'],
                    //       receiverName: receiverName,
                    //     ),
                    //   ),
                    // );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// ✅ Fetch Friend Requests From Firestore
  Widget _buildFriendRequestsColumn() {
    if (currentUserId.isEmpty) {
      return Center(child: Text("Fetching friend requests..."));
    }

    print("🔍 Fetching friend requests for userId: $currentUserId");

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: CircularProgressIndicator());
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;

        // ✅ Ensure friendRequests field exists in Firestore document
        if (userData == null || !userData.containsKey('friendRequests')) {
          return Center(child: Text("No friend requests found."));
        }

        List<dynamic> friendRequests = userData['friendRequests'];

        // ✅ Ensure it's a valid list
        if (friendRequests.isEmpty || friendRequests is! List) {
          return Center(child: Text("No friend requests."));
        }

        return ListView.builder(
          itemCount: friendRequests.length,
          itemBuilder: (context, index) {
            var request = friendRequests[index];

            // ✅ Ensure each request is a string
            if (request is! String) {
              return SizedBox.shrink();
            }

            String senderId = request.trim();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(senderId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return SizedBox.shrink();
                }

                var user = userSnapshot.data!.data() as Map<String, dynamic>?;

                // ✅ Ensure user document contains expected fields
                String userName = user?['name'] ?? "Unknown User";

                // ✅ Handle 'workoutTypes' as String OR List
                var workoutTypeData = user?['workoutTypes'];
                String workoutType = "";

                if (workoutTypeData is String) {
                  workoutType = workoutTypeData; // ✅ Direct String value
                } else if (workoutTypeData is List) {
                  workoutType = workoutTypeData.join(", "); // ✅ Convert List to comma-separated String
                } else {
                  workoutType = "Unknown"; // ✅ Default fallback
                }

                return Card(
                  color: Colors.grey[100],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // ✅ Rounded corners
                  child: InkWell(
                    onTap: () {
                      print("Tapped on ${user?['name']}");
                      globalFunction.navigateWithSlideAnimation(context, OtherUserProfileScreen(userId: senderId));
                    },
                    borderRadius: BorderRadius.circular(12), // ✅ Ripple effect on tap
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center, // ✅ Center-align contents
                        children: [
                          /// ✅ **User Avatar & Name**
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(user?['profileImage'] ?? 'https://default-image.com'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  userName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 20, thickness: 1), // ✅ Adds a separator line

                          /// ✅ **Accept & Decline Buttons (Side-by-side)**
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () => _acceptFriendRequest(senderId),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green, textStyle: const TextStyle(fontSize: 20),
                                ),
                                child: const Text("Let's Workout"),
                              ),
                              TextButton(
                                onPressed: () => _rejectFriendRequest(senderId),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red, textStyle: const TextStyle(fontSize: 20),
                                ),
                                child: const Text("Decline"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );


              },
            );

          },
        );
      },
    );
  }

  /// ✅ Accept Friend Request
  void _acceptFriendRequest(String senderId) async {
    DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(currentUserId);
    DocumentReference senderRef =
    FirebaseFirestore.instance.collection('users').doc(senderId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(userRef, {
        'friends': FieldValue.arrayUnion([senderId]),
        'friendRequests': FieldValue.arrayRemove([senderId]),
      });

      transaction.update(senderRef, {
        'friends': FieldValue.arrayUnion([currentUserId]),
      });
    });

  }

  /// ✅ Reject Friend Request
  void _rejectFriendRequest(String senderId) async {
    DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(currentUserId);
    await userRef.update({
      'friendRequests': FieldValue.arrayRemove([senderId]),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Friend request rejected.")));
  }
  /// ✅ Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.handshake_outlined), label: 'GymBuddy'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Message'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.popAndPushNamed(context, '/home');
        } else if (index == 1) {
          Navigator.popAndPushNamed(context, "/findbuddy");
        } else if (index == 3) {
          Navigator.popAndPushNamed(context, "/profile");
        }
      },
    );
  }


}
