import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class AugmentedRealityView extends StatefulWidget {
  final Uint8List imageBytes;

  const AugmentedRealityView({super.key, required this.imageBytes});

  @override
  State<AugmentedRealityView> createState() => _AugmentedRealityViewState();
}

class _AugmentedRealityViewState extends State<AugmentedRealityView> {
  CameraController? cameraController;
  Future<void>? _initializeControllerFuture;
  List<Map<String, dynamic>> images = [];
  String? selectedImage;
  List<CameraDescription> allCameras = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _addImage(widget.imageBytes);
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      allCameras = await availableCameras();
      if (allCameras.isNotEmpty) {
        cameraController = CameraController(
          allCameras[0],
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        _initializeControllerFuture = cameraController!.initialize().then((_) {
          if (mounted) setState(() {});
        });
      } else {
        debugPrint('No cameras available');
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _addImage(Uint8List imageBytes) {
    setState(() {
      images.add({
        'imageBytes': imageBytes,
        'xPosition': 100.0,
        'yPosition': 100.0,
        'size': 150.0,
      });
      selectedImage = imageBytes.toString();
    });
  }

  void _updateImageProperties(int index, double x, double y, double size) {
    setState(() {
      images[index]['xPosition'] = x;
      images[index]['yPosition'] = y;
      images[index]['size'] = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR View')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    cameraController != null &&
                    cameraController!.value.isInitialized) {
                  final Size previewSize = cameraController!.value.previewSize!;
                  final Size screenSize = MediaQuery.of(context).size;

                  final bool isScreenPortrait =
                      screenSize.height > screenSize.width;
                  final bool isPreviewPortrait =
                      previewSize.height > previewSize.width;

                  return Stack(
                    children: [
                      SizedBox(
                        width: screenSize.width,
                        height: screenSize.height,
                        child: isScreenPortrait != isPreviewPortrait
                            ? RotatedBox(
                                quarterTurns: 1,
                                child: CameraPreview(cameraController!),
                              )
                            : CameraPreview(cameraController!),
                      ),
                      ...images.asMap().entries.map((entry) {
                        int index = entry.key;
                        var image = entry.value;
                        return Positioned(
                          top: image['yPosition'],
                          left: image['xPosition'],
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              if (selectedImage ==
                                  image['imageBytes'].toString()) {
                                _updateImageProperties(
                                  index,
                                  image['xPosition'] + details.delta.dx,
                                  image['yPosition'] + details.delta.dy,
                                  image['size'],
                                );
                              }
                            },
                            onTap: () {
                              _selectImage(image['imageBytes'].toString());
                            },
                            child: Container(
                              width: image['size'],
                              height: image['size'],
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedImage ==
                                          image['imageBytes'].toString()
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 3.0,
                                ),
                              ),
                              child: Image.memory(image['imageBytes']),
                            ),
                          ),
                        );
                      }),
                      if (selectedImage != null)
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Slider(
                            value: images.firstWhere((image) =>
                                image['imageBytes'].toString() ==
                                selectedImage)['size'],
                            min: 50,
                            max: 300,
                            onChanged: (value) {
                              int index = images.indexWhere((image) =>
                                  image['imageBytes'].toString() ==
                                  selectedImage);
                              _updateImageProperties(
                                index,
                                images[index]['xPosition'],
                                images[index]['yPosition'],
                                value,
                              );
                            },
                          ),
                        ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectImage(String imageBytesString) {
    setState(() {
      selectedImage = imageBytesString;
    });
  }
}
