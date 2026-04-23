import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'widgets/profile_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _imageFile;
  bool isProcessing = false;
  bool isLocating = false;
  
  final ImagePicker picker = ImagePicker();
  late final TextRecognizer textRecognizer;

  final TextEditingController needController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  String urgency = 'High';

  final List<String> urgencies = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      textRecognizer.close();
    }
    needController.dispose();
    locationController.dispose();
    super.dispose();
  }

  //  PICK IMAGE from Gallery
  Future<void> _pickFromGallery() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (!mounted) return;
      if (picked != null) {
        setState(() => _imageFile = picked);
        _processImageWithOCR(picked.path);
      }
    } catch (e) {
      debugPrint("Gallery Error: $e");
    }
  }

  //  PICK IMAGE from Camera
  Future<void> _pickFromCamera({CameraDevice device = CameraDevice.rear}) async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: device,
      );
      if (!mounted) return;
      if (picked != null) {
        setState(() => _imageFile = picked);
        _processImageWithOCR(picked.path);
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  // OCR PROCESSING
  Future<void> _processImageWithOCR(String path) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OCR is not supported on web.")));
      return;
    }
    setState(() => isProcessing = true);
    try {
      final inputImage = InputImage.fromFilePath(path);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      setState(() {
        needController.text = recognizedText.text;
      });
      
      if (mounted && recognizedText.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No text recognized from the image.")),
        );
      }
    } catch (e) {
      debugPrint("OCR Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error processing image: $e")),
        );
      }
    }
    setState(() => isProcessing = false);
  }

  // GET CURRENT LOCATION
  Future<void> _getCurrentLocation() async {
    setState(() => isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location permissions are denied')));
          setState(() => isLocating = false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location permissions are permanently denied')));
        setState(() => isLocating = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          locationController.text = "${place.street}, ${place.locality}, ${place.country}";
        });
      }
    } catch (e) {
      debugPrint("Location Error: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location')));
    }
    setState(() => isLocating = false);
  }

  //  SHOW PICKER BOTTOM SHEET
  void pickImage() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Scan Survey Document", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickFromGallery();
                      },
                      icon: Icon(Icons.photo_library),
                      label: Text("Gallery"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickFromCamera(device: CameraDevice.rear);
                      },
                      icon: Icon(Icons.camera_rear),
                      label: Text("Rear Camera"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickFromCamera(device: CameraDevice.front);
                      },
                      icon: Icon(Icons.camera_front),
                      label: Text("Front Camera"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // SAVE TO FIRESTORE
  Future<void> saveSurveyData() async {
    if (needController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Survey text is empty. Please scan a document or type the need.")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please login first")));
      return;
    }

    setState(() => isProcessing = true);

    try {
      await FirebaseFirestore.instance.collection('surveys').add({
        'uid': user.uid,
        'need': needController.text.trim(),
        'location': locationController.text.trim(),
        'urgency': urgency,
        'status': 'open',
        'progress': 0,
        'assigneeId': null,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Survey Data saved to Volunteer Board!"), backgroundColor: Colors.green),
      );
      
      // Clear form
      setState(() {
        _imageFile = null;
        needController.clear();
        locationController.clear();
      });
      
    } catch (e) {
      debugPrint("Firestore Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving data: $e"), backgroundColor: Colors.red));
      }
    }

    if (mounted) setState(() => isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfileDrawer(),
      appBar: AppBar(
        title: Text("Scan Paper Survey"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Card(
            elevation: 15,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Digitize Survey Data",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // IMAGE PREVIEW
                  if (_imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: kIsWeb
                          ? Image.network(_imageFile!.path, height: 150, fit: BoxFit.cover)
                          : Image.file(File(_imageFile!.path), height: 150, fit: BoxFit.cover),
                    )
                  else
                    Container(
                      height: 100,
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
                      child: Center(child: Text("No document scanned", style: TextStyle(color: Colors.grey[600]))),
                    ),

                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: isProcessing ? null : pickImage,
                    icon: Icon(Icons.document_scanner),
                    label: Text("Scan Document"),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14)),
                  ),

                  SizedBox(height: 25),
                  Divider(),
                  SizedBox(height: 15),

                  // DATA FORM
                  Text("Extracted Data", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 10),
                  
                  TextField(
                    controller: needController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Extracted text will appear here. You can manually edit it.",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 15),

                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: "Survey Location",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: isLocating ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.my_location),
                        onPressed: isLocating ? null : _getCurrentLocation,
                        tooltip: "Auto-detect Location",
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    initialValue: urgency,
                    decoration: InputDecoration(
                      labelText: "Urgency Level",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: urgencies.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => urgency = val);
                    },
                  ),

                  SizedBox(height: 25),

                  // SUBMIT BUTTON
                  ElevatedButton.icon(
                    onPressed: isProcessing ? null : saveSurveyData,
                    icon: isProcessing
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Icon(Icons.send),
                    label: Text(isProcessing ? "Processing..." : "Save to Volunteer Board"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}