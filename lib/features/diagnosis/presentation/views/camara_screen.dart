import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path/path.dart' show join;

import 'diagnosis_screen.dart';
class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  double _diagnosisProgress = 0.42;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndProcess() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await _initializeControllerFuture;

      // Simulate diagnosis progress
      for (int i = 0; i < 10; i++) {
        await Future.delayed(Duration(milliseconds: 200));
        setState(() {
          _diagnosisProgress = 0.42 + (i * 0.058);
        });
      }

      final image = await _controller.takePicture();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DiagnosisScreen(
            imagePath: image.path,
          ),
        ),
      );

      setState(() {
        _isProcessing = false;
        _diagnosisProgress = 0.42; // Reset progress
      });

    } catch (e) {
      print(e);
      setState(() {
        _isProcessing = false;
      });
    }
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
                // Camera preview
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: CameraPreview(_controller),
                ),

                // Status bar area
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '9:41',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Icon(Icons.wifi, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Icon(Icons.battery_full, color: Colors.white, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Close button
                Positioned(
                  top: 60,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      // Handle close action
                    },
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

                // Green rectangle overlays for plant detection
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
                          'Diagnosing plants...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),

                        SizedBox(height: 20),

                        // Bottom action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Gallery button
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.photo_library_outlined,
                                color: Colors.white,
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
                                  border: Border.all(color: Colors.green, width: 4),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Switch camera button
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.flip_camera_ios,
                                color: Colors.white,
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
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
