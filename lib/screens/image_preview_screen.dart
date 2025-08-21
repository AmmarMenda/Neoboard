// lib/screens/image_preview_screen.dart
import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a black background for a better viewing experience
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        // Ensure the back button is visible on a black background
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // InteractiveViewer allows users to zoom and pan the image
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
