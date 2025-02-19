import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ar_screen.dart';

class ItemsUploadScreen extends StatefulWidget {
  const ItemsUploadScreen({super.key});

  @override
  State<ItemsUploadScreen> createState() => _ItemsUploadScreenState();
}

class _ItemsUploadScreenState extends State<ItemsUploadScreen> {
  Uint8List? image;
  bool isUploading = false;
  TextEditingController nameController = TextEditingController();

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        image = imageBytes;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ARScreen(),
        ),
      );
    }
  }


  Widget uploadFormScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Upload New Item",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          isUploading
              ? const LinearProgressIndicator(
            color: Colors.purpleAccent,
          )
              : Container(),
          SizedBox(
              height: 230,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                  child: image != null
                      ? Image.memory(image!)
                      : const Icon(Icons.image_not_supported, color: Colors.grey))),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),
          ListTile(
            leading: const Icon(
              Icons.person_pin_rounded,
              color: Colors.white70,
            ),
            title: SizedBox(
                width: 250,
                child: TextField(
                  style: const TextStyle(color: Colors.grey),
                  controller: nameController,
                )),
          )
        ],
      ),
    );
  }

  Widget defaultScreen() {
    return Scaffold(
      backgroundColor: Colors.cyanAccent,
      appBar: AppBar(
        backgroundColor: Colors.cyanAccent,
        title: const Text(
          "Upload new item",
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              color: Colors.black87,
              size: 100,
            ),
            ElevatedButton(
              onPressed: () {
                showDialogBox();
              },
              child: const Text(
                "Add New Item",
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showDialogBox() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            "Item Image",
            style: TextStyle(color: Colors.white70),
          ),
          children: [
            SimpleDialogOption(
                onPressed: () {
                  pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Capture Image with Camera",
                  style: TextStyle(color: Colors.grey),
                )),
            SimpleDialogOption(
                onPressed: () {
                  pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Choose Image from Gallery",
                  style: TextStyle(color: Colors.grey),
                )),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                )),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return defaultScreen();
  }
}