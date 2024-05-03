import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _categoriesStream =
        FirebaseFirestore.instance.collection("categories").snapshots();
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
                onChanged: _onSearchTextChanged,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _categoriesStream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var categories = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      var category = categories[index];
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
                            leading: Icon(Icons.category, color:Color(0xFF0101FE)),
                            title: Text(category['name'], style: TextStyle(color: Colors.black)),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmationDialog(context, category),
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
        onPressed: () => _showAddCategoryDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Add Category',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(),
    );
  }


  void _onSearchTextChanged(String text) {
    setState(() {
      _categoriesStream = FirebaseFirestore.instance
          .collection("categories")
          .where('name', isGreaterThanOrEqualTo: text)
          .where('name', isLessThan: text + 'z')
          .snapshots();
    });
  }

  void _showAddCategoryDialog(BuildContext context) {
    TextEditingController _categoryNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            controller: _categoryNameController,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: Icon(Icons.cancel, color:Colors.grey[700]),
                  label: Text('Cancel', style: TextStyle(color:Colors.grey[700])),
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(color:Colors.grey[700]! , width: 2),
                  ),
                ),
                SizedBox(width: 10),
                OutlinedButton.icon(
                  icon: Icon(Icons.check, color: Color(0xFF048304)),
                  label: Text('Add', style: TextStyle(color: Color(0xFF048304))),
                  onPressed: () {
                    String categoryName = _categoryNameController.text;
                    if (categoryName.isNotEmpty) {
                      FirebaseFirestore.instance.collection('categories').add({
                        'name': categoryName,
                      }).then((value) {
                        Navigator.of(context).pop();
                      }).catchError((error) {
                        print("Error adding category: $error");
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(color: Color(0xFF048304), width: 2),
                  ),
                ),
              ],
            )
          ],
          actionsPadding: EdgeInsets.only(right: 10, bottom: 10),
        );
      },
    );
  }


  void _showDeleteConfirmationDialog(
      BuildContext context, DocumentSnapshot category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${category['name']}?'),
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
                SizedBox(width: 10), // Spacing between the buttons
                OutlinedButton.icon(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  label: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                  onPressed: () {
                    _deleteCategory(context, category);
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

  void _deleteCategory(BuildContext context, DocumentSnapshot category) {
    FirebaseFirestore.instance
        .collection("categories")
        .doc(category.id)
        .delete()
        .then((value) {
      Navigator.of(context).pop();
    }).catchError((error) {
      print("Error deleting category: $error");
    });
  }
}
