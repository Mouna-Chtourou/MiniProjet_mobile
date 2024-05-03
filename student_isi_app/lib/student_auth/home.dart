import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_isi_app/Announcements.dart';
import 'package:student_isi_app/Forms.dart';
import 'package:student_isi_app/global/toast.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  int _selectedIndex = 0;
  late String _displayName= '';
  late String _email='';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  late String _profileImageUrl = '';

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _displayName = prefs.getString('username') ?? 'User Name';
      _email = prefs.getString('email') ?? 'user@example.com';
      _profileImageUrl = prefs.getString('profileImage') ?? '';
    });
    print("Loaded profile image URL: $_profileImageUrl");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student"),
      ),
      drawer: Drawer(

        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF048304),
              ),
              accountName: Text(_displayName),
              accountEmail: Text(_email),
              currentAccountPicture: _profileImageUrl.isNotEmpty
                  ? CircleAvatar(
                backgroundImage: NetworkImage(_profileImageUrl),
              )
                  : const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              title: const Text('Posts'),
              leading: const Icon(Icons.campaign),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              title: const Text('Forms'),
              leading: const Icon(Icons.description),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              title: const Text('Request Access'),
              leading: const Icon(Icons.vpn_key),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            ListTile(
              title: const Text('Sign Out'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () {
                _signOut();
              },
            ),
          ],
        ),
      ),
      body: _buildPage(),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return AnnouncementsPage();
      case 1:
        return Forms();
      case 2:
        return RequestAccessPage();
      default:
        throw UnimplementedError('no widget for $_selectedIndex');
    }
  }

  void _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamed(context, "/login");
    showToast(message: "Successfully signed out");
  }
}


class FormsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text('Forms Page'),
      ),
    );
  }
}

class RequestAccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implement your request access page UI here
    return Container(
      child: const Center(
        child: Text('Request Access Page'),
      ),
    );
  }
}
