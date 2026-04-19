import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  //  Pick from Gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // compress image (0-100)
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print("Gallery Error: $e");
    }
    return null;
  }

  //  Pick from Camera
  Future<File?> pickFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print("Camera Error: $e");
    }
    return null;
  }

  //  Generic method (optional)
  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print("Image Pick Error: $e");
    }
    return null;
  }
}