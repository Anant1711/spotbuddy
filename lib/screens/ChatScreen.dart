import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId; // Logged-in user ID
  final String receiverId; // The person they are chatting with
  final String receiverName; // Receiver's Name

  const ChatScreen({
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    _deleteOldMessages(); // 🔥 Cleanup old messages on chat screen open
  }
  final _textKey = GlobalKey<FormState>();
  TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats') // ✅ Fetch from shared chat collection
                  .doc(_getChatId(widget.currentUserId, widget.receiverId))
                  .collection('messages') // ✅ Messages inside this chat
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // ✅ Show loading indicator
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Column(
                    children: [
                      _buildChatDeletionNote(), // ✅ Show note even if no messages exist
                      Expanded(child: Center(child: Text("No messages yet"))),
                    ],
                  );
                }

                var messages = snapshot.data!.docs;

                return Column(
                  children: [
                    _buildChatDeletionNote(), // ✅ Add the note above messages
                    Expanded(
                      child: ListView.builder(
                        reverse: true, // Show latest message at the bottom
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          var msg = messages[index];
                          bool isMe = msg['senderId'] == widget.currentUserId;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.black : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg['text'],
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isMe ? Colors.white : Colors.black),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// ✅ Function to Send Messages and Store in `/chats/{chatId}/messages/{messageId}`
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    String messageText = _messageController.text.trim();
    _messageController.clear();

    String chatId = _getChatId(widget.currentUserId, widget.receiverId);

    _storeMessage(chatId, widget.currentUserId, widget.receiverId, messageText);
  }

  /// ✅ Store Message in Firestore Under Shared `chats/{chatId}/messages/`
  void _storeMessage(String chatId, String senderId, String receiverId, String text) {
    FirebaseFirestore.instance
        .collection('chats') // 🔥 Centralized chat collection
        .doc(chatId)
        .collection('messages') // ✅ Messages stored here
        .add({
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // ✅ Update chat preview for both users
    FirebaseFirestore.instance.collection('users').doc(senderId).collection('messages').doc(chatId).set({
      'lastMessage': text,
      'timestamp': FieldValue.serverTimestamp(),
      'receiverId': receiverId,
    }, SetOptions(merge: true));

    FirebaseFirestore.instance.collection('users').doc(receiverId).collection('messages').doc(chatId).set({
      'lastMessage': text,
      'timestamp': FieldValue.serverTimestamp(),
      'receiverId': senderId,
    }, SetOptions(merge: true));
  }

  /// ✅ Create a Unique Chat ID Between Two Users
  String _getChatId(String user1, String user2) {
    return (user1.hashCode <= user2.hashCode) ? '$user1-$user2' : '$user2-$user1';
  }

  /// ✅ **Helper Function to Build Chat Deletion Note**
  Widget _buildChatDeletionNote() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: EdgeInsets.only(bottom: 8),
      color: Colors.amber[200], // ✅ Highlighted background
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.black54, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Note: Your chat will be deleted after 15 days",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  /// ✅ **Delete messages older than 1 minute**
  void _deleteOldMessages() async {
    print("✅ Inside Delete OLD Messages");
    String chatId = _getChatId(widget.currentUserId, widget.receiverId);

    // Get the current timestamp minus 1 minute
    Timestamp cutoffTimestamp = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.now().subtract(Duration(minutes: 1)).millisecondsSinceEpoch);

    QuerySnapshot oldMessages = await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .where("timestamp", isLessThan: cutoffTimestamp)
        .get();

    for (var doc in oldMessages.docs) {
      await doc.reference.delete(); // ✅ Delete each old message
    }

    print("✅ Messages older than 1 min deleted from chat: $chatId");
  }
  /// ✅ Message Input Field
  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Form(
              key: _textKey,
              child: TextFormField(
                controller: _messageController,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black54, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black54, width: 2),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '';
                  }
                  return null;
                },
              ),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
                _sendMessage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Different color for distinction
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17), // Adjust padding
            ),
            child: const Icon(
              Icons.send_outlined, // Message icon
              color: Colors.white,
              size: 24, // Adjust size if needed
            ),
          ),
        ],
      ),
    );
  }
}
