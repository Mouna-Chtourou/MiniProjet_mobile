import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SubscriptionPage extends StatefulWidget {
  final Map<String, dynamic> newUser;

  const SubscriptionPage({Key? key, required this.newUser}) : super(key: key);

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Categories"),
        backgroundColor: Color(0xFF0101FE).withOpacity(0.7),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              String category = documents[index]['name'];
              bool isSelected = _selectedCategories.contains(category);

              return Card(
                color: Color(0xFFF0F0F0),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: ListTile(
                  title: Text(category, style: TextStyle(fontSize: 18)),
                  leading: Icon(Icons.category, color: Color(0xFF048304)),
                  trailing: Switch(
                    value: isSelected,
                    onChanged: (bool newValue) {
                      setState(() {
                        if (newValue) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Color(0xFF048304),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveCategories,
        label: Text('Subscribe', style: const TextStyle(color: Colors.white)),
        icon: Icon(Icons.check, color: Colors.white),
        backgroundColor: Color(0xFF0101FE),
      ),
    );
  }

  Future<void> _saveCategories() async {
    try {
      DocumentReference userRef = await FirebaseFirestore.instance.collection(
          'students').add({
        ...widget.newUser,
        'categories': _selectedCategories,
      });
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving user and categories: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}