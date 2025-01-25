import 'package:flutter/cupertino.dart';

class HomeScreen extends StatefulWidget {
  late var lat,long;
  late String mUid;
  @override
  _HomeScreenState createState() => _HomeScreenState();
  HomeScreen();
  HomeScreen.withOptions(var this.lat, var this.long, String this.mUid);
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
