import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageContentScreen extends StatefulWidget {
  final String title;
  final String category;
  final Color color;

  const ManageContentScreen({
    super.key,
    required this.title,
    required this.category,
    required this.color,
  });

  @override
  State<ManageContentScreen> createState() => _ManageContentScreenState();
}

class _ManageContentScreenState extends State<ManageContentScreen> {
  final _collection = FirebaseFirestore.instance.collection('discover');

  void _showContentDialog({DocumentSnapshot? doc}) {
    final titleController = TextEditingController(text: doc?['title']);
    final contentController = TextEditingController(text: doc?['content']);
    final imageUrlController = TextEditingController(text: doc?['imageUrl']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          doc == null ? "Add ${widget.title}" : "Edit ${widget.title}",
          style: TextStyle(color: widget.color, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Content"),
                maxLines: 5,
              ),
              if (widget.category != "FAQ") ...[
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: "Image URL"),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
            ),
            onPressed: () async {
              final data = {
                "title": titleController.text.trim(),
                "content": contentController.text.trim(),
                "imageUrl": imageUrlController.text.trim(),
                "category": widget.category,
              };
              if (doc == null) {
                await _collection.add(data);
              } else {
                await _collection.doc(doc.id).update(data);
              }
              if (mounted) Navigator.pop(context);
            },
            child: Text(doc == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  void _deleteItem(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: widget.color,
        title: Text("Manage ${widget.title}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showContentDialog(),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _collection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['category'] == widget.category;
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text("No items found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  leading: widget.category != "FAQ"
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      data['imageUrl'] ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[300], width: 60, height: 60),
                    ),
                  )
                      : Icon(Icons.help_outline, color: widget.color, size: 40),
                  title: Text(
                    data['title'] ?? 'Untitled',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    data['content']?.toString().substring(0, 80) ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showContentDialog(doc: doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteItem(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
