import 'package:flutter/material.dart';
import 'manage_section_screen.dart';

class ManageVideosScreen extends StatelessWidget {
  const ManageVideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ManageSectionScreen(
      category: 'Videos',
      color: Colors.deepOrange,
      fields: [
        {'name': 'title', 'label': 'Title'},
        {'name': 'content', 'label': 'Description', 'maxLines': 3},
        {'name': 'videoUrl', 'label': 'Video URL'},
        {'name': 'imageUrl', 'label': 'Thumbnail URL'},
        {'name': 'time', 'label': 'Duration (e.g. 8 min)'},
      ],
    );
  }
}
