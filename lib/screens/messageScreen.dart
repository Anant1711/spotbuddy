import 'package:flutter/material.dart';
import 'package:spotbuddy/screens/findbuddy.dart';
import 'package:spotbuddy/screens/profileScreen.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({Key? key}) : super(key: key);

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  GlobalKey<ScaffoldState> _messagingScaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, String>> conversations = [
    {
      'name': 'Alex Johnson',
      'lastMessage': 'See you at the gym!',
      'time': '10:30 AM',
      'avatar': 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/image-QPO2xJvrscRL3kyQNn5zG50lODp82k.png',
    },
    {
      'name': 'Sarah Williams',
      'lastMessage': 'Great workout today!',
      'time': 'Yesterday',
      'avatar': 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/image-QPO2xJvrscRL3kyQNn5zG50lODp82k.png',
    },
    {
      'name': 'Mike Brown',
      'lastMessage': 'Are you up for a run tomorrow?',
      'time': 'Yesterday',
      'avatar': 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/image-QPO2xJvrscRL3kyQNn5zG50lODp82k.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _messagingScaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            _messagingScaffoldKey.currentState?.openDrawer();
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
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // TODO: Implement search functionality
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

      body: ListView.separated(
        itemCount: conversations.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(conversation['avatar']!),
            ),
            title: Text(
              conversation['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              conversation['lastMessage']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              conversation['time']!,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            onTap: () {
              // TODO: Navigate to individual chat screen
            },
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
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
            Navigator.popAndPushNamed(
                context,
                '/home');
          } else if (index == 1) {
            Navigator.popAndPushNamed(
                context,
                '/findbuddy');
          } else if (index == 3) {
            Navigator.popAndPushNamed(
                context,
                '/profile');
          }
        },
      ),
    );
  }
}

