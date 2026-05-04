import 'package:flutter/material.dart';
import 'manage_section_screen.dart';

class ManageTipsScreen extends StatelessWidget {
  const ManageTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ManageSectionScreen(
      category: 'Tips',
      color: Colors.purple,
      fields: [
        {'name': 'title', 'label': 'Title'},
        {'name': 'content', 'label': 'Tip / Content', 'maxLines': 4},
        {'name': 'imageUrl', 'label': 'Image URL (optional)'},
        {'name': 'time', 'label': 'Read Time (e.g. 2 min)'},
      ],
    );
  }
}
