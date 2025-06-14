import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/diagnosis_provider.dart';
import 'diagnosis_error_screen.dart';
import 'diagnosis_healthy_screen.dart';
import 'diagnosis_result_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _selectedCameraIndex = 0;
  double _diagnosisProgress = 0.0;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  File? _selectedGalleryImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    _controller = CameraController(
      widget.cameras[_selectedCameraIndex],
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2) return;

    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
      _selectedGalleryImage = null;
    });

    await _controller.dispose();
    _initializeCamera();
    setState(() {});
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedGalleryImage = File(image.path);
        });

        await _processImage(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting image: $e');
    }
  }

  Future<void> _takePictureAndProcess() async {
    if (_isProcessing) return;

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      await _processImage(image.path);
    } catch (e) {
      print('Error taking picture: $e');
      _showErrorSnackBar('Error taking picture: $e');
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() {
      _isProcessing = true;
      _diagnosisProgress = 0.0;
    });

    try {
      // Start progress animation
      _startProgressAnimation();

      // Use the diagnosis provider to process the image
      final diagnosisProvider = Provider.of<DiagnosisProvider>(
        context,
        listen: false,
      );

      await diagnosisProvider.processImage(imagePath);

      // Complete the progress
      setState(() {
        _diagnosisProgress = 1.0;
      });

      // Wait a bit to show 100%
      await Future.delayed(Duration(milliseconds: 500));

      // Navigate based on result
      _navigateBasedOnResult(diagnosisProvider);

    } catch (e) {
      _showErrorSnackBar('Error processing image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
        _diagnosisProgress = 0.0;
      });
    }
  }

  // Separate method for progress animation
  Future<void> _startProgressAnimation() async {
    // Animate progress from 0 to 80% while processing
    for (int i = 0; i <= 8; i++) {
      if (!_isProcessing) break; // Stop if processing is cancelled

      await Future.delayed(Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _diagnosisProgress = (i * 0.1); // 0% to 80%
        });
      }
    }
  }

  void _navigateBasedOnResult(DiagnosisProvider provider) {
    switch (provider.status) {
      case DiagnosisStatus.noPlant:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DiagnosisErrorScreen(),
          ),
        );
        break;
      case DiagnosisStatus.healthy:
        if (provider.diagnosisResponse != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DiagnosisHealthyScreen(
                imagePath: provider.imagePath,
                response: provider.diagnosisResponse!,
              ),
            ),
          );
        }
        break;
      case DiagnosisStatus.diseased:
        if (provider.diagnosisResponse != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DiagnosisResultScreen(
                imagePath: provider.imagePath,
                response: provider.diagnosisResponse!,
              ),
            ),
          );
        }
        break;
      case DiagnosisStatus.error:
        _showErrorSnackBar(provider.errorMessage);
        break;
      default:
        break;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // Show gallery image if selected, otherwise show camera preview
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: _selectedGalleryImage != null
                      ? Image.file(
                    _selectedGalleryImage!,
                    fit: BoxFit.cover,
                  )
                      : CameraPreview(_controller),
                ),
                // Close button
                Positioned(
                  top: 60,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Diagnose text
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Diagnose',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Green rectangle overlays for plant detection (only show when using camera)
                if (!_isProcessing && _selectedGalleryImage == null) ...[
                  Positioned(
                    top: 150,
                    left: 30,
                    child: Container(
                      width: 120,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 180,
                    right: 30,
                    child: Container(
                      width: 100,
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],

                // Processing overlay when analyzing gallery image
                if (_isProcessing && _selectedGalleryImage != null) ...[
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.green,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Analyzing image...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Bottom progress section
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isProcessing) ...[
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _diagnosisProgress,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                              minHeight: 8,
                            ),
                          ),
                          SizedBox(height: 12),

                          // Progress percentage
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(_diagnosisProgress * 100).toInt()}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          // Diagnosing text
                          Text(
                            _selectedGalleryImage != null
                                ? 'Analyzing selected image...'
                                : 'Diagnosing plants...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),

                          SizedBox(height: 20),
                        ],

                        // Bottom action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Gallery button
                            GestureDetector(
                              onTap: _isProcessing ? null : _pickImageFromGallery,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(_isProcessing ? 0.1 : 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.photo_library_outlined,
                                  color: Colors.white.withOpacity(_isProcessing ? 0.5 : 1.0),
                                ),
                              ),
                            ),

                            // Capture button
                            GestureDetector(
                              onTap: _isProcessing ? null : _takePictureAndProcess,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _isProcessing ? Colors.grey : Colors.green,
                                      width: 4
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _isProcessing ? Colors.grey : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: _isProcessing
                                        ? CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                    )
                                        : null,
                                  ),
                                ),
                              ),
                            ),

                            // Switch camera button (only enabled when using camera)
                            GestureDetector(
                              onTap: (_isProcessing || _selectedGalleryImage != null) ? null : _switchCamera,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(
                                      (_isProcessing || _selectedGalleryImage != null) ? 0.1 : 0.2
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.flip_camera_ios,
                                  color: Colors.white.withOpacity(
                                      (_isProcessing || _selectedGalleryImage != null) ? 0.5 : 1.0
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Initializing camera...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
