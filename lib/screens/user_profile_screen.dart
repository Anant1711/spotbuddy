import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;

  const OtherUserProfileScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _OtherUserProfileScreenState createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  bool isLoading = false;
  bool isSendingRequest = false;
  bool isFriend = false;
  bool hasSentRequest = false;

  // Dummy user data
  final Map<String, dynamic> userData = {
    'name': 'Alex Johnson',
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
  };

  @override
  void initState() {
    super.initState();
    // No need to fetch data, we're using dummy data
  }

  void _sendFriendRequest() {
    setState(() {
      isSendingRequest = true;
    });

    // Simulate network delay
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
        title: Text('User Profile'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Show options menu
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
            _buildInfoSection('About'),
            _buildWorkoutPreferences(),
            _buildGymStats(),
            _buildRecentActivity(),
          ],
        ),
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
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: NetworkImage(
              userData['profilePicture'],
            ),
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
              onPressed: isFriend || hasSentRequest || isSendingRequest
                  ? null
                  : _sendFriendRequest,
              icon: Icon(
                isFriend
                    ? Icons.check
                    : (hasSentRequest
                    ? Icons.hourglass_empty
                    : Icons.person_add),
                color: Colors.white,
              ),
              label: Text(
                isFriend
                    ? 'Connected'
                    : (hasSentRequest ? 'Request Sent' : 'Connect'),
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey,
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
              onPressed: isFriend
                  ? () {
                // Navigate to chat screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat feature coming soon')),
                );
              }
                  : null,
              icon: Icon(Icons.message, color: Colors.black),
              label: Text('Message', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                disabledBackgroundColor: Colors.grey[100],
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
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            userData['bio'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
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
          Text(
            'Workout Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
          Text(
            'Gym Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
              Text(
                'Personal Records',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              ...List<Map<String, dynamic>>.from(userData['machine_weights'])
                  .map((weight) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(weight['exercise_name']),
                    Text(
                      '${weight['weight']} kg',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
        'description': 'Completed a leg day workout',
        'time': DateTime.now().subtract(Duration(days: 2)),
      },
      {
        'type': 'achievement',
        'description': 'Earned "Consistent Athlete" badge',
        'time': DateTime.now().subtract(Duration(days: 5)),
      },
      {
        'type': 'buddy',
        'description': 'Connected with a new gym buddy',
        'time': DateTime.now().subtract(Duration(days: 7)),
      },
    ];

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.report),
                title: Text('Report User'),
                onTap: () {
                  Navigator.pop(context);
                  // Show report dialog
                  _showReportDialog(context);
                },
              ),
              if (isFriend)
                ListTile(
                  leading: Icon(Icons.person_remove),
                  title: Text('Remove Connection'),
                  onTap: () {
                    Navigator.pop(context);
                    // Show confirmation dialog
                    _showRemoveConnectionDialog(context);
                  },
                ),
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                  // Show block confirmation dialog
                  _showBlockUserDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Report User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please select a reason for reporting this user:'),
              SizedBox(height: 16),
              ListTile(
                title: Text('Inappropriate behavior'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Report submitted')),
                  );
                },
              ),
              ListTile(
                title: Text('Fake profile'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Report submitted')),
                  );
                },
              ),
              ListTile(
                title: Text('Other'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Report submitted')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove Connection'),
          content: Text('Are you sure you want to remove this connection?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isFriend = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Connection removed')),
                );
              },
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showBlockUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Block User'),
          content: Text(
              'Are you sure you want to block this user? You won\'t see their content anymore.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User blocked')),
                );
                Navigator.pop(context); // Return to previous screen
              },
              child: Text('Block'),
            ),
          ],
        );
      },
    );
  }
}
