import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSectionScreen extends StatefulWidget {
  final String category;
  final Color color;
  final List<Map<String, dynamic>> fields;

  const ManageSectionScreen({
    super.key,
    required this.category,
    required this.color,
    required this.fields,
  });

  @override
  State<ManageSectionScreen> createState() => _ManageSectionScreenState();
}

class _ManageSectionScreenState extends State<ManageSectionScreen> {
  final _collection = FirebaseFirestore.instance.collection('discover');

  void _showContentDialog({DocumentSnapshot? doc}) {
    // Create controllers for each dynamic field
    final controllers = {
      for (var field in widget.fields)
        field['name']: TextEditingController(
          text: doc != null ? (doc[field['name']] ?? '') : '',
        ),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          doc == null
              ? "Add ${widget.category}"
              : "Edit ${widget.category}",
          style: TextStyle(color: widget.color, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.fields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: controllers[field['name']],
                  decoration: InputDecoration(
                    labelText: field['label'],
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: field['maxLines'] ?? 1,
                ),
              );
            }).toList(),
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
              final Map<String, dynamic> data = {};

              // Collect all field values
              for (var field in widget.fields) {
                final key = field['name'];
                final value = controllers[key]?.text.trim();

                if (value != null && value.isNotEmpty) {
                  data[key] = value;
                }
              }

              data['category'] = widget.category;

              try {
                if (doc == null) {
                  // Add new item
                  await _collection.add(data);
                } else {
                  // Update existing item
                  await _collection.doc(doc.id).update(data);
                }

                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(doc == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  void _deleteItem(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: widget.color,
        title: Text("Manage ${widget.category}"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.color,
        onPressed: () => _showContentDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _collection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data found."));
          }

          final docs = snapshot.data!.docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['category'] == widget.category;
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text("No items found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: data['imageUrl'] != null &&
                      data['imageUrl'].toString().isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      data['imageUrl'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child:
                        const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  )
                      : const Icon(Icons.article_outlined, size: 40),
                  title: Text(
                    data['title'] ?? 'Untitled',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    data['content'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                        const Icon(Icons.edit, color: Colors.blueAccent),
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
