import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementsPage extends StatefulWidget {
  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  late List<Map<String, dynamic>> _announcements = [];
  late List<Map<String, dynamic>> _filteredAnnouncements = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchUserCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userEmail = prefs.getString('email') ?? '';
    QuerySnapshot userSnapshot = await _firestore
        .collection('students')
        .where('email', isEqualTo: userEmail)
        .get();
    if (userSnapshot.docs.isNotEmpty) {
      List<dynamic> userCategories = userSnapshot.docs.first['categories'];
      await _fetchAnnouncements(userCategories);
    }
  }

  Future<void> _fetchAnnouncements(List<dynamic> userCategories) async {
    QuerySnapshot announcementsSnapshot = await _firestore
        .collection('posts')
        .where('categories', arrayContainsAny: userCategories)
        .get();
    _announcements = announcementsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    _filteredAnnouncements = List.from(_announcements);
    setState(() {});
  }

  void _filterAnnouncements(String query) {
    setState(() {
      _filteredAnnouncements = query.isEmpty
          ? List.from(_announcements)
          : _announcements.where((announcement) =>
      announcement['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
          announcement['description'].toString().toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF0F0F0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.search, color: Color(0xFF0101FE)),
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _filterAnnouncements,
              ),
            ),
            Expanded(
              child: _buildAnnouncementsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    if (_filteredAnnouncements.isEmpty) {
      return Center(child: Text('No announcements available.', style: TextStyle(color: Colors.black)));
    } else {
      return ListView.builder(
        itemCount: _filteredAnnouncements.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> announcement = _filteredAnnouncements[index];
          return GestureDetector(
            onTap: () => _showAnnouncementDetailsDialog(context, announcement),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Card(
                color: Colors.white,
                shadowColor: Color(0xFF0101FE),
                elevation: 5.0,
                child: ListTile(
                  title: Text(announcement['title'], style: TextStyle(color: Colors.black)),
                  subtitle: Text(announcement['description'], style: TextStyle(color: Colors.grey)),
                  leading: Icon(Icons.campaign, color:Color(0xFF0101FE)),

                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _showAnnouncementDetailsDialog(BuildContext context, Map<String, dynamic> announcement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(announcement['title'], style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                (announcement['image'] as String?)?.isNotEmpty ?? false
                    ? Image.network(announcement['image'], fit: BoxFit.cover)
                    : Text('No image available', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 10),
                Text('Description: ${announcement['description']}', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: Color(0xFF0101FE))),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
