import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/globalFunctions.dart' as globalFunction;
import '../utils/globalVariables.dart' as globalVariable;

class MessagingScreenResponsive extends StatefulWidget {
  const MessagingScreenResponsive({super.key});

  @override
  State<MessagingScreenResponsive> createState() =>
      _MessagingScreenResponsiveState();
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
        body: Center(
            child: CircularProgressIndicator()), // Prevent Firestore errors
      );
    }

    final bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _messagingScaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Messages & Requests',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body:
          isWideScreen ? _buildWideScreenLayout() : _buildNarrowScreenLayout(),
      bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2,
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
        } else if (index == 1) {
          //navigation to Message screen
          Navigator.popAndPushNamed(context, "/findbuddy");
        } else if (index == 3) {
          // navigation to Profile screen
          Navigator.popAndPushNamed(context, "/profile");
        }
      },
    ),
    );
  }

  Widget _buildWideScreenLayout() {
    return Row(
      children: [
        Expanded(child: _buildMessagesColumn()),
        VerticalDivider(width: 1, thickness: 1, color: Colors.grey[300]),
        Expanded(child: _buildFriendRequestsColumn()),
      ],
    );
  }

  Widget _buildNarrowScreenLayout() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: const [
              Tab(text: 'Messages'),
              Tab(text: 'Friend Requests'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMessagesColumn(),
                _buildFriendRequestsColumn(),
              ],
            ),
          ),
        ],
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

            return ListTile(
              leading: CircleAvatar(
                  // backgroundImage: NetworkImage(msg['senderAvatar'] ?? 'https://default-image.com'),
                  ),
              title: FutureBuilder<String>(
                future: globalFunction.fetchUserName(
                    msg['senderId']), // Fetch username asynchronously
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading...",
                        style: TextStyle(fontWeight: FontWeight.bold));
                  }
                  if (snapshot.hasError) {
                    return Text("Unknown User",
                        style: TextStyle(fontWeight: FontWeight.bold));
                  }
                  return Text(snapshot.data ?? "Unknown User",
                      style: TextStyle(fontWeight: FontWeight.bold));
                },
              ),
              subtitle: Text(globalFunction.truncateText(msg['text'], 4),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Text(globalFunction.formatTimestamp(msg['timestamp'])),
              onTap: () {
                // TODO: Open chat screen
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
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: CircularProgressIndicator());
        }

        List<dynamic> friendRequests = snapshot.data!['friendRequests'] ?? [];

        if (friendRequests.isEmpty) {
          return Center(child: Text("No friend requests"));
        }

        return ListView.builder(
          itemCount: friendRequests.length,
          itemBuilder: (context, index) {
            String senderId = friendRequests[index];

            if (senderId.isEmpty) {
              return SizedBox.shrink();
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(senderId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return SizedBox.shrink();
                }

                var user = userSnapshot.data!;
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          // backgroundImage: NetworkImage(user['profileImage'] ?? 'https://default-image.com'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              // Text(user['workoutTypes'] ?? 'Unknown', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptFriendRequest(senderId),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectFriendRequest(senderId),
                        ),
                      ],
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

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Friend request accepted!")));
    _sendMessage(senderId, "Hello this is First Message");
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

  /// ✅ Send Message
  void _sendMessage(String receiverId, String message) async {
    if (receiverId.isEmpty || currentUserId.isEmpty) {
      print("🚨 Error: sender or receiver ID is empty!");
      return;
    }

    DocumentReference receiverMessages = FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('messages')
        .doc();
    DocumentReference senderMessages = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('messages')
        .doc();

    Map<String, dynamic> messageData = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await receiverMessages.set(messageData);
    await senderMessages.set(messageData);

    print("✅ Message sent to $receiverId");
  }
}
