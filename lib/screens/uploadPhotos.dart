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

//TODO: NEW UI
/*

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import '../components/custom_app_bar.dart';

class ImageUploadScreen extends StatefulWidget {
  final String uploadType;
  final Function(List<String> imageUrls)? onImagesUploaded;

  const ImageUploadScreen({
    Key? key,
    this.uploadType = 'profile', // Options: 'profile', 'workout', 'progress'
    this.onImagesUploaded,
  }) : super(key: key);

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  List<File> _selectedImages = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  final ImagePicker _picker = ImagePicker();
  String? _errorMessage;
  final int _maxImages = 5;

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (_selectedImages.length >= _maxImages) {
        setState(() {
          _errorMessage = "You can only select up to $_maxImages images";
        });
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error selecting image: $e";
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        // Only add up to the maximum allowed
        final int remainingSlots = _maxImages - _selectedImages.length;
        final List<XFile> filesToAdd =
            pickedFiles.take(remainingSlots).toList();

        setState(() {
          _selectedImages.addAll(filesToAdd.map((xFile) => File(xFile.path)));

          if (pickedFiles.length > remainingSlots) {
            _errorMessage =
                "Only added $remainingSlots images. Maximum of $_maxImages images allowed.";
          } else {
            _errorMessage = null;
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error selecting images: $e";
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Dummy upload function that simulates an upload process
  Future<void> _simulateUpload() async {
    if (_selectedImages.isEmpty) {
      setState(() {
        _errorMessage = "Please select at least one image";
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
    });

    // Simulate upload progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(Duration(milliseconds: 300));
      setState(() {
        _uploadProgress = i / 10;
      });
    }

    // Simulate completion
    await Future.delayed(Duration(milliseconds: 500));

    // Generate dummy image URLs that would normally come from a server
    List<String> dummyImageUrls = _selectedImages
        .map((file) =>
            'https://example.com/uploaded_image_${_selectedImages.indexOf(file)}.jpg')
        .toList();

    // Call the callback if provided
    if (widget.onImagesUploaded != null) {
      widget.onImagesUploaded!(dummyImageUrls);
    }

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${_selectedImages.length} image${_selectedImages.length > 1 ? 's' : ''} uploaded successfully')),
      );

      // Navigate back after successful upload
      Navigator.pop(context, dummyImageUrls);
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(
      //   title: 'Upload Images',
      //   onMenuTap: () {
      //     // Not needed for this screen
      //   },
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Upload ${widget.uploadType.capitalize()} Images',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Select up to $_maxImages images',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                '${_selectedImages.length}/$_maxImages images selected',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _selectedImages.length == _maxImages
                      ? Colors.green
                      : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 30),

              // Image preview
              _buildImagePreviews(),

              const SizedBox(height: 30),

              // Image source buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // _buildSourceButton(
                  //   icon: Icons.photo_library,
                  //   label: 'Gallery',
                  //   // onPressed: _pickImage,
                  //   source: ImageSource.gallery,
                  // ),
                  // const SizedBox(width: 20),
                  // _buildSourceButton(
                  //   icon: Icons.camera_alt,
                  //   label: 'Camera',
                  //   // onPressed: _pickImage,
                  //   source: ImageSource.camera,
                  // ),
                  const SizedBox(width: 20),
                  _buildSourceButton(
                    icon: Icons.photo_album,
                    label: 'Multiple',
                    onPressed: (_) => _pickMultipleImages(),
                    source: null,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Upload progress
              if (_isUploading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Upload button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _simulateUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isUploading
                      ? const Text(
                          'Uploading...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          'Upload ${_selectedImages.length > 0 ? _selectedImages.length : ""} Image${_selectedImages.length != 1 ? "s" : ""}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviews() {
    if (_selectedImages.isEmpty) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 10),
            Text(
              'No images selected',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      Container(
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImages[index],
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required Function(ImageSource? source) onPressed,
    required ImageSource? source,
  }) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(icon, size: 30),
            onPressed: () => onPressed(source),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

 */