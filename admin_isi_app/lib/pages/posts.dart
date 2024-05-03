import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _PostStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _PostStream = FirebaseFirestore.instance.collection("posts").snapshots();
  }
  void _showPostDetailsDialog(BuildContext context, String title, String description, String imageUrl, List<dynamic> categories) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title, style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Center(child: Text('No image available', style: TextStyle(color: Colors.grey))),
                SizedBox(height: 10),
                Text('Description: $description', style: TextStyle(color: Colors.black)),
                SizedBox(height: 10),
                Text('Categories: ${categories.join(', ')}', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: Color(0xFF0101FE))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                stream: _PostStream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<DocumentSnapshot> Post = snapshot.data!.docs;

                  if (Post.isEmpty) {
                    return Center(child: Text('No posts available.', style: TextStyle(color: Colors.black)));
                  }

                  return ListView.builder(
                    itemCount: Post.length,
                    itemBuilder: (BuildContext context, int index) {
                      var post = Post[index];
                      Map<String, dynamic>? postData = post.data() as Map<String, dynamic>?;
                      String title = postData != null && postData.containsKey('title') ? postData['title'] : 'No Title';
                      String description = postData != null && postData.containsKey('description') ? postData['description'] : 'No Description';
                      List<dynamic> categories = postData != null && postData.containsKey('categories') ? postData['categories'] : [];
                      String imageUrl = postData != null && postData.containsKey('image') ? postData['image'] : '';

                      return GestureDetector(
                        onTap: () => _showPostDetailsDialog(context, title, description, imageUrl, categories),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Card(
                            color: Colors.white,
                            shadowColor: Color(0xFF0101FE),
                            elevation: 5.0,
                            child: ListTile(
                              leading: Icon(Icons.campaign, color:Color(0xFF0101FE)),
                              title: Text(title, style: TextStyle(color: Colors.black)),
                              subtitle: Text(description, style: TextStyle(color: Colors.grey)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteConfirmationDialog(context, post),
                              ),
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
          _showAddPostDialog(context);
        },
        child: Icon(Icons.add),
        elevation: Theme.of(context).floatingActionButtonTheme.elevation,
        tooltip: 'Add Post',
        shape: Theme.of(context).floatingActionButtonTheme.shape,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(),
    );
  }


  void _onSearchTextChanged(String text) {
    setState(() {
      _PostStream = FirebaseFirestore.instance
          .collection("posts")
          .where('title', isGreaterThanOrEqualTo: text)
          .where('title', isLessThan: text + 'z')
          .snapshots();
    });
  }


  void _showAddPostDialog(BuildContext context) {
    TextEditingController _titleController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();
    List<String> _selectedCategories = [];
    List<String> _categories = [];
    File? _image;
    final ImagePicker _picker = ImagePicker();

    Future pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        setState(() {});
      }
    }

    Future<String?> uploadImage(File image) async {
      String fileName = basename(image.path);
      firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref().child('post_images/$fileName');
      firebase_storage.UploadTask task = ref.putFile(image);
      return await (await task).ref.getDownloadURL();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: 'Post Title',
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: 'Post Description',
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 5,
                    ),
                    SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("categories").snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Text('Error loading categories');
                        }

                        _categories.clear();
                        for (DocumentSnapshot doc in snapshot.data!.docs) {
                          _categories.add(doc['name']);
                        }

                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                          ),
                          value: null,
                          hint: Text(
                            'Select category',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal
                            ),
                          ),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              _selectedCategories.add(value);
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: pickImage,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Attach Image'),
                          SizedBox(width: 8),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage: _image != null ? FileImage(_image!) : null,
                            child: _image == null ? Icon(Icons.add_a_photo, size: 20, color: Color(0xFF048304)) : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
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
                OutlinedButton.icon(
                  icon: Icon(Icons.add, color: Color(0xFF048304)),
                  label: Text('Add', style: TextStyle(color: Color(0xFF048304))),
                  onPressed: () async {
                    if (_image != null) {
                      String? imageUrl = await uploadImage(_image!);
                      if (imageUrl != null) {
                        String title = _titleController.text.trim();
                        String description = _descriptionController.text.trim();
                        FirebaseFirestore.instance.collection('posts').add({
                          'title': title,
                          'description': description,
                          'categories': _selectedCategories,
                          'image': imageUrl,
                        }).then((value) => Navigator.of(context).pop());
                      }
                    } else {
                      print('No image selected');
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
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, DocumentSnapshot post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${post['title']}?'),
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
                    _deletepost(context, post);
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

  void _deletepost(BuildContext context, DocumentSnapshot post) {
    FirebaseFirestore.instance
        .collection("posts")
        .doc(post.id)
        .delete()
        .then((value) {
      Navigator.of(context).pop();
    }).catchError((error) {
      print("Error deleting post: $error");
    });
  }
}
