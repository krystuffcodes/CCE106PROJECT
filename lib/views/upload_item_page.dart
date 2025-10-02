// lib/views/upload_item_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/item_service.dart';

class UploadItemPage extends StatefulWidget {
  const UploadItemPage({super.key});
  @override
  State<UploadItemPage> createState() => _UploadItemPageState();
}

class _UploadItemPageState extends State<UploadItemPage> {
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _category = TextEditingController();
  final _description = TextEditingController();

  DateTime _dt = DateTime.now();
  bool _isFound = true;
  File? _pickedImage;

  Future<void> _pickImage() async {
    final p = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (p != null) setState(() => _pickedImage = File(p.path));
  }

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (d == null) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dt),
    );

    if (t != null) {
      setState(() {
        _dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
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
    _category.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (_title.text.isEmpty) return;
    final imagePath = _pickedImage?.path ?? 'assets/.jpg';
    Provider.of<ItemService>(context, listen: false).addItem(
      title: _title.text,
      imagePath: imagePath,
      locationFound: _location.text,
      dateTime: _dt,
      category: _category.text.isEmpty ? 'Other' : _category.text,
      isFound: _isFound,
      reporterId: 'user1',
      description: _description.text,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // 📸 Image Picker
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

          // 📝 Input Fields
          TextField(
            controller: _title,
            decoration: const InputDecoration(hintText: 'Item Name'),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _location,
            decoration: const InputDecoration(hintText: 'Location Found'),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _category,
            decoration: const InputDecoration(hintText: 'Category'),
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

          // 🔘 Found toggle + date
          Row(
            children: [
              const Text('Found?'),
              Switch(
                value: _isFound,
                onChanged: (v) => setState(() => _isFound = v),
              ),
              const Spacer(),
              TextButton(
                child: const Text('Pick Date & Time'),
                onPressed: _pickDateTime,
              ),
            ],
          ),

          // 📅 Show selected date/time
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Selected: ${_formatDateTime(_dt)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 16),

          // ⬆️ Upload button
          ElevatedButton(
            onPressed: _save,
            child: const Text('Upload'),
          ),
        ]),
      ),
    );
  }
}
