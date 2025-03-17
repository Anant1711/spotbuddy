import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../utils/globalVariables.dart' as globalVariable;

class PhotoUploadScreen extends StatefulWidget {
  @override
  _PhotoUploadScreenState createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];
  Map<String, double> uploadProgress = {};
  bool isUploading = false;
  int uploadedCount = 0;
  bool showSuccessAnimation = false; // Track completion animation

  @override
  void initState() {
    super.initState();
    _loadUserPhotos();
  }

  /// ✅ **Load user's existing photos**
  Future<void> _loadUserPhotos() async {
    String userId = globalVariable.g_currentUserId;
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        List<dynamic> storedUrls = userDoc.get('photos') ?? [];
        setState(() {
          selectedImages = storedUrls.map((url) => XFile(url)).toList();
        });
      }
    } catch (e) {
      print("🚨 Error loading user photos: $e");
    }
  }

  /// ✅ **Pick multiple images at once**
  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles == null) return;

    setState(() {
      selectedImages.addAll(pickedFiles);
      if (selectedImages.length > 5) {
        selectedImages = selectedImages.sublist(0, 5);
      }
    });
  }

  /// ✅ **Upload all selected images concurrently**
  Future<void> _uploadImages() async {
    setState(() {
      isUploading = true;
      uploadProgress.clear();
      uploadedCount = 0;
      showSuccessAnimation = false;
    });

    // ✅ Create all upload tasks simultaneously
    List<Future<void>> uploadTasks = selectedImages.map((image) => _uploadSingleImage(image)).toList();

    // ✅ Ensure all tasks run in parallel
    await Future.wait(uploadTasks);

    print("✅ Uploaded all images successfully!");

    setState(() {
      showSuccessAnimation = true;
      isUploading = false;
    });

    // ✅ Hide animation after 3 seconds
    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        showSuccessAnimation = false;
        selectedImages.clear();
        Navigator.popAndPushNamed(context, '/home');
      });
    });
  }


  Future<void> _uploadSingleImage(XFile image) async {
    Uint8List bytes = await image.readAsBytes(); // ✅ Convert image to bytes

    String fileName = "${globalVariable.g_currentUserId}/${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference storageRef = FirebaseStorage.instance.ref('user_photos/$fileName');
    UploadTask uploadTask = storageRef.putData(bytes); // ✅ Use putData() for speed

    // ✅ Use the file path as the key for tracking progress
    String imageKey = image.path;

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      setState(() {
        uploadProgress[imageKey] = progress; // ✅ Correctly track progress
      });
    });

    try {
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(globalVariable.g_currentUserId)
          .update({
        'photos': FieldValue.arrayUnion([downloadUrl])
      });

      setState(() {
        uploadedCount++;
      });

    } catch (e) {
      print("🚨 Error uploading image: $e");
    }
  }/// ✅ **Remove an image from selection**

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Upload Photos"),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.popAndPushNamed(context, '/home'),
            child: Text(
              "Skip",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text("Select up to 5 photos.", style: TextStyle(fontSize: 16)),
          ),

          /// ✅ **Display selected images**
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: selectedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == selectedImages.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      color: Colors.grey[300],
                      child: Center(child: Icon(Icons.add, size: 50, color: Colors.grey[600])),
                    ),
                  );
                }

                String imageKey = selectedImages[index].path; // ✅ Use path as key

                return Stack(
                  children: [
                    Image.file(File(selectedImages[index].path), fit: BoxFit.cover),

                    /// ✅ **Show upload progress per image**
                    if (uploadProgress.containsKey(imageKey))
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: uploadProgress[imageKey], // ✅ Show progress
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _removeImage(index),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          /// ✅ **Upload progress indicator & Success Animation**
          if (isUploading)
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Uploaded $uploadedCount / ${selectedImages.length} images",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          if (showSuccessAnimation)
            Center(
              child: Lottie.asset(
                'assets/success.json', // ✅ Lottie animation
                repeat: true, // ✅ Play only once
                width: 250,
                height: 250,
              ),
            ),

          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: isUploading ? null : _uploadImages,
              child: Text("Upload Selected Photos"),
            ),
          ),
        ],
      ),
    );
  }
}