import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  bool isUploading = false;

  final ImagePicker picker = ImagePicker();

  //  PICK IMAGE (Camera + Gallery option)
  void pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(15),
          height: 150,
          child: Column(
            children: [
              Text("Choose Image", style: TextStyle(fontSize: 18)),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final picked = await picker.pickImage(
                          source: ImageSource.camera);
                      if (picked != null) {
                        setState(() => _image = File(picked.path));
                      }
                    },
                    icon: Icon(Icons.camera),
                    label: Text("Camera"),
                  ),

                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final picked = await picker.pickImage(
                          source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() => _image = File(picked.path));
                      }
                    },
                    icon: Icon(Icons.photo),
                    label: Text("Gallery"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  //  UPLOAD IMAGE
  Future uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image first")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final fileName =
          DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance
          .ref()
          .child("uploads/$fileName.jpg");

      await ref.putFile(_image!);

      final downloadUrl = await ref.getDownloadURL();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload Successful")),
      );

      print("Download URL: $downloadUrl");

      setState(() => _image = null); // reset after upload
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 15,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              margin: EdgeInsets.all(20),

              child: Padding(
                padding: EdgeInsets.all(20),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Upload Your Image",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 20),

                    // IMAGE PREVIEW
                    _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              _image!,
                              height: 180,
                              width: 180,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            children: [
                              Icon(Icons.image,
                                  size: 100, color: Colors.grey),
                              Text("No image selected"),
                            ],
                          ),

                    SizedBox(height: 20),

                    // PICK BUTTON
                    ElevatedButton.icon(
                      onPressed: pickImage,
                      icon: Icon(Icons.add_a_photo),
                      label: Text("Select Image"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),

                    SizedBox(height: 15),

                    // UPLOAD BUTTON
                    ElevatedButton.icon(
                      onPressed: isUploading ? null : uploadImage,
                      icon: isUploading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : Icon(Icons.cloud_upload),

                      label: Text(
                          isUploading ? "Uploading..." : "Upload Image"),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}