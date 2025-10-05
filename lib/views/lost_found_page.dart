import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class LostFoundPage extends StatefulWidget {
  const LostFoundPage({super.key});

  @override
  State<LostFoundPage> createState() => _LostFoundPageState();
}

class _LostFoundPageState extends State<LostFoundPage> {
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _locationC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  bool _isUploading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _uploadItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in.");

      // Upload image if selected
      String? imageUrl;
      if (_imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref =
            FirebaseStorage.instance.ref().child('items').child(user.uid).child(fileName);
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      // Save to Firestore
      await _firestore.collection('items').add({
        'title': _titleC.text.trim(),
        'description': _descC.text.trim(),
        'location': _locationC.text.trim(),
        'imageUrl': imageUrl,
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
        _titleC.clear();
        _descC.clear();
        _locationC.clear();
        setState(() => _imageFile = null);
      }
    } catch (e) {
      debugPrint("Error uploading item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lost & Found"),
        backgroundColor: const Color(0xFFb71c1c),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🧾 Add Item Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleC,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      prefixIcon: Icon(Icons.label),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter item name' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descC,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter description' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _locationC,
                    decoration: const InputDecoration(
                      labelText: 'Location Found / Lost',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter location' : null,
                  ),
                  const SizedBox(height: 10),

                  // 📸 Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: _imageFile == null
                          ? const Center(child: Text("Tap to add image"))
                          : Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔘 Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: Text(_isUploading ? 'Uploading...' : 'Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFb71c1c),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isUploading ? null : _uploadItem,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 🧩 Item List
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('items')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No items found yet.");
                }

                final items = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: items.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final data = items[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: data['imageUrl'] != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(data['imageUrl']),
                                radius: 25,
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.image_not_supported),
                              ),
                        title: Text(data['title'] ?? 'Unnamed item'),
                        subtitle: Text(
                          "${data['location'] ?? 'Unknown location'}\nBy: ${data['userName'] ?? 'Unknown'}",
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
