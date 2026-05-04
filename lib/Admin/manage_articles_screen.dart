import 'package:flutter/material.dart';
import 'manage_section_screen.dart';

class ManageArticlesScreen extends StatelessWidget {
  const ManageArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ManageSectionScreen(
      category: 'Articles',
      color: Colors.indigo,
      fields: [
        {'name': 'title', 'label': 'Title'},
        {'name': 'content', 'label': 'Content', 'maxLines': 5},
        {'name': 'imageUrl', 'label': 'Image URL'},
        {'name': 'time', 'label': 'Read Time (e.g. 7 min, 8 min)'},
      ],
    );
  }
}
