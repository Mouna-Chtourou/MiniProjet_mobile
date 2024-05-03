import 'package:flutter/material.dart';
import 'dart:io';  // For File
import 'package:image_picker/image_picker.dart';

class ImageAvatar extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;

  const ImageAvatar({
    Key? key,
    this.imageFile,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xFF0101FE), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          image: imageFile != null
              ? DecorationImage(
            image: FileImage(imageFile!),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: imageFile == null
            ? Icon(Icons.add_a_photo, color: Color(0xFF0101FE), size: 40)
            : null,
      ),
    );
  }
}
