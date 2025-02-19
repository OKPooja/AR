import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class AugmentedRealityView extends StatefulWidget {
  const AugmentedRealityView({super.key});

  @override
  State<AugmentedRealityView> createState() => _AugmentedRealityViewState();
}

class _AugmentedRealityViewState extends State<AugmentedRealityView> {
  CameraController? cameraController;
  Future<void>? _initializeControllerFuture;
  List<Map<String, dynamic>> images = [];
  String? selectedImageUrl;
  List<CameraDescription> allCameras = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
          //sensor orientation - force portrait mode
          if (mounted) setState(() {});
        });
      } else {
        debugPrint('No cameras available');
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _addImage(String url, String name) {
    setState(() {
      images.add({
        'url': url,
        'name': name,
        'xPosition': 100.0,
        'yPosition': 100.0,
        'size': 150.0,
      });
      selectedImageUrl = url;
    });
  }

  void _showAddImageDialog() {
    final imageUrlController = TextEditingController();
    final imageNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(hintText: "Image URL"),
              ),
              TextField(
                controller: imageNameController,
                decoration: const InputDecoration(hintText: "Image Name"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final imageUrl = imageUrlController.text;
                final imageName = imageNameController.text;
                if (imageUrl.isNotEmpty && imageName.isNotEmpty) {
                  _addImage(imageUrl, imageName);
                }
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
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

                  //Headache part :( Orientation
                  final bool isScreenPortrait = screenSize.height > screenSize.width;
                  final bool isPreviewPortrait = previewSize.height > previewSize.width;

                  // Fix orientation mismatch by rotating if needed
                  // The key change: we rotate the entire preview 90 degrees if orientations don't match
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
                              if (selectedImageUrl == image['url']) {
                                _updateImageProperties(
                                  index,
                                  image['xPosition'] + details.delta.dx,
                                  image['yPosition'] + details.delta.dy,
                                  image['size'],
                                );
                              }
                            },
                            onTap: () {
                              _selectImage(image['url']);
                            },
                            child: Container(
                              width: image['size'],
                              height: image['size'],
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedImageUrl == image['url']
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 3.0,
                                ),
                              ),
                              child: Image.network(image['url']),
                            ),
                          ),
                        );
                      }),
                      if (selectedImageUrl != null)
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Slider(
                            value: images.firstWhere((image) =>
                                image['url'] == selectedImageUrl)['size'],
                            min: 50,
                            max: 300,
                            onChanged: (value) {
                              int index = images.indexWhere(
                                  (image) => image['url'] == selectedImageUrl);
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
          BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.camera),
                label: 'AR View',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Add Image',
              ),
            ],
            onTap: (index) {
              if (index == 1) {
                _showAddImageDialog();
              }
            },
          ),
        ],
      ),
    );
  }

  void _selectImage(String url) {
    setState(() {
      selectedImageUrl = url;
    });
  }
}
