// lib/views/upload_item_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/item_service.dart';

class UploadItemPage extends StatefulWidget {
  const UploadItemPage({super.key});
  @override
  State<UploadItemPage> createState() => _UploadItemPageState();
}

class _UploadItemPageState extends State<UploadItemPage> {
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();

  DateTime _dt = DateTime.now();
  bool _isFound = true;
  File? _pickedImage;

  final List<String> _categories = [
    'Phone',
    'Wallet',
    'ID',
    'Keys',
    'Bottle',
    'Bag',
    'Others'
  ];
  String? _selectedCategory;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dt),
    );

    if (time != null) {
      setState(() {
        _dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      });
    }
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "$hour:$minute $ampm";
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item name.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to report an item.')),
      );
      return;
    }

    final imagePath = _pickedImage?.path ?? 'assets/default.jpg';

    await Provider.of<ItemService>(context, listen: false).addItem(
      title: _title.text.trim(),
      imagePath: imagePath,
      locationFound: _location.text.trim(),
      dateTime: _dt,
      category: _selectedCategory ?? 'Others',
      isFound: _isFound,
      reporterId: user.uid,
      description: _description.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item reported successfully!')),
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Item', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFb71c1c),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _pickedImage == null
                  ? Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.add_a_photo, size: 48),
                    )
                  : Image.file(
                      _pickedImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _title,
              decoration: const InputDecoration(
                hintText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _location,
              decoration: const InputDecoration(
                hintText: 'Location Found',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: 'Select Category',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Text('Found?'),
                Switch(
                  value: _isFound,
                  onChanged: (v) => setState(() => _isFound = v),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _pickDateTime,
                  child: const Text('Pick Date & Time'),
                ),
              ],
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selected: ${_formatDateTime(_dt)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFb71c1c),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
