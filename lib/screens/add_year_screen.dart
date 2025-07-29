import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // for formatting date
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'event_details_screen.dart';

class AddYearScreen extends ConsumerStatefulWidget {
  final String eventName;
  const AddYearScreen({Key? key, required this.eventName}) : super(key: key);

  @override
  ConsumerState<AddYearScreen> createState() => _AddYearScreenState();
}

class _AddYearScreenState extends ConsumerState<AddYearScreen> {
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  File? _coverImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _coverImage = File(picked.path);
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveYear() {
    final year = _yearController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (year.isEmpty || _selectedDate == null || location.isEmpty || _coverImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    final yearData = {
      'year': year,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'location': location,
      'description': description,
      'image': _coverImage!.path,
    };

    ref.read(yearsProvider(widget.eventName).notifier).addYear(yearData);
    Navigator.pop(context, yearData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Year")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Year (e.g. 2025) *"),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? "Select Date *"
                    : "Date:  {DateFormat('yyyy-MM-dd').format(_selectedDate!)}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: "Location *"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _coverImage == null
                ? const Text("No image selected")
                : Image.file(_coverImage!, height: 150),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Pick Cover Image"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveYear,
              child: const Text("Save Year"),
            ),
          ],
        ),
      ),
    );
  }
}
