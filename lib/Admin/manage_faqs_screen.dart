import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageFaqsScreen extends StatefulWidget {
  const ManageFaqsScreen({super.key});

  @override
  State<ManageFaqsScreen> createState() => _ManageFaqsScreenState();
}

class _ManageFaqsScreenState extends State<ManageFaqsScreen> {
  // ✅ correct collection name
  final _collection = FirebaseFirestore.instance.collection('discover');

  void _showFaqDialog({DocumentSnapshot? doc}) {
    final titleController =
    TextEditingController(text: doc != null ? doc['title'] ?? '' : '');
    final contentController =
    TextEditingController(text: doc != null ? doc['content'] ?? '' : '');
    final imageUrlController =
    TextEditingController(text: doc != null ? doc['imageUrl'] ?? '' : '');
    final timeController =
    TextEditingController(text: doc != null ? doc['time'] ?? '' : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          doc == null ? "Add FAQ" : "Edit FAQ",
          style: GoogleFonts.montserrat(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Content"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: "Image URL"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: "Read Time (e.g. 7 min)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              final imageUrl = imageUrlController.text.trim();
              final time = timeController.text.trim();

              if (title.isEmpty || content.isEmpty || time.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please fill in all required fields"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              final data = {
                "title": title,
                "content": content,
                "imageUrl": imageUrl,
                "time": time,
                "category": "FAQs", // ✅ correct category value
              };

              try {
                if (doc == null) {
                  await _collection.add(data);
                } else {
                  await _collection.doc(doc.id).update(data);
                }
                if (mounted) Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: Text(doc == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  void _deleteFaq(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting FAQ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Manage FAQs"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => _showFaqDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _collection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No FAQs found."));
          }

          // ✅ filter properly
          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['category'] == "FAQs";
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text("No FAQs found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      data['imageUrl'] ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  title: Text(
                    data['title'] ?? 'Untitled',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['content'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "⏱ ${data['time'] ?? ''}",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                        const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _showFaqDialog(doc: doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFaq(doc.id),
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
