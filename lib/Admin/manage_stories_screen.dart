import 'package:flutter/material.dart';
import 'manage_section_screen.dart';

class ManageStoriesScreen extends StatelessWidget {
  const ManageStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ManageSectionScreen(
      category: 'Stories',
      color: Colors.teal,
      fields: [
        {'name': 'title', 'label': 'Title'},
        {'name': 'content', 'label': 'Content', 'maxLines': 6},
        {'name': 'imageUrl', 'label': 'Image URL'},
        {'name': 'time', 'label': 'Read Time (e.g. 7 min)'},
      ],
    );
  }
}
