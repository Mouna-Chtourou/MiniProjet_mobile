import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/pages/DynamicForm.dart';
import 'package:namer_app/pages/Forms.dart';

class FormListPage extends StatefulWidget {
  @override
  _FormListPageState createState() => _FormListPageState();
}

class _FormListPageState extends State<FormListPage> {
  TextEditingController searchController = TextEditingController();
  late Stream<QuerySnapshot> formStream;

  @override
  void initState() {
    super.initState();
    formStream = FirebaseFirestore.instance.collection('formFields').snapshots();
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      if (text.isEmpty) {
        formStream = FirebaseFirestore.instance.collection('formFields').snapshots();
      } else {
        formStream = FirebaseFirestore.instance
            .collection("formFields")
            .where('titleForm', isGreaterThanOrEqualTo: text)
            .where('titleForm', isLessThanOrEqualTo: text + '\uf8ff')
            .snapshots();
      }
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
                onChanged: _onSearchTextChanged,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: formStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> formData = documents[index].data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Card(
                          color: Colors.white,
                          shadowColor: Color(0xFF0101FE),
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.description, color: Color(0xFF0101FE)),
                            title: Text(
                              formData['titleForm'] ?? '',
                              style: TextStyle(color: Colors.black),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DynamicForm(formDefinition: documents[index]),
                                ),
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteConfirmationDialog(context, documents[index]),  // Pass the current document snapshot
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormBuilder(),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Form',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(),

    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, DocumentSnapshot formField) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${formField['titleForm']}?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: Icon(Icons.cancel, color: Colors.grey[700]),
                  label: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(color: Colors.grey[700]!, width: 2),
                  ),
                ),
                SizedBox(width: 10),
                OutlinedButton.icon(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  label: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                  onPressed: () {
                    _deleteform(context, formField);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(color: Colors.redAccent, width: 2),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: EdgeInsets.only(right: 10, bottom: 10),
        );
      },
    );
  }

  void _deleteform(BuildContext context, DocumentSnapshot formField) {
    FirebaseFirestore.instance
        .collection("formFields")
        .doc(formField.id)
        .delete()
        .then((value) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Form deleted successfully')));
    }).catchError((error) {
      print("Error deleting form: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting form')));
    });
  }

}
