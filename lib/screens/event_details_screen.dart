import 'dart:io';

import 'package:flutter/material.dart';
import 'add_year_screen.dart';
import 'app_colors.dart';
import 'event_tabs_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final yearsProvider = StateNotifierProvider.family<YearsNotifier, List<Map<String, dynamic>>, String>((ref, eventName) => YearsNotifier());

class YearsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  YearsNotifier() : super([]);
  void addYear(Map<String, dynamic> year) => state = [...state, year];
  void clear() => state = [];
  void updateYear(int index, Map<String, dynamic> updatedYear) {
    final newList = [...state];
    newList[index] = updatedYear;
    state = newList;
  }
  void deleteYear(int index) {
    final newList = [...state]..removeAt(index);
    state = newList;
  }
}

class EventDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> eventData;
  final bool isAdmin;

  const EventDetailsScreen({
    Key? key,
    required this.eventData,
    required this.isAdmin,
  }) : super(key: key);

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _addNewYear(Map<String, dynamic> newYear) {
    if (!mounted) return;
    ref.read(yearsProvider(widget.eventData['name']).notifier).addYear(newYear);
  }

  void _showEditYearDialog(BuildContext context, Map<String, dynamic> yearData, int index) {
    final _formKey = GlobalKey<FormState>();
    String year = yearData['year'] ?? '';
    String location = yearData['location'] ?? '';
    String description = yearData['description'] ?? '';
    String date = yearData['date'] ?? '';
    String image = yearData['image'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Year'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: year,
                    decoration: const InputDecoration(labelText: 'Year'),
                    onSaved: (value) => year = value ?? '',
                  ),
                  TextFormField(
                    initialValue: location,
                    decoration: const InputDecoration(labelText: 'Location'),
                    onSaved: (value) => location = value ?? '',
                  ),
                  TextFormField(
                    initialValue: date,
                    decoration: const InputDecoration(labelText: 'Date'),
                    onSaved: (value) => date = value ?? '',
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) => description = value ?? '',
                  ),
                  // Optionally add image picker here
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _formKey.currentState?.save();
                final updatedYear = {
                  ...yearData,
                  'year': year,
                  'location': location,
                  'description': description,
                  'date': date,
                  'image': image,
                };
                ref.read(yearsProvider(widget.eventData['name']).notifier).updateYear(index, updatedYear);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteYear(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Year'),
        content: const Text('Are you sure you want to delete this year?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(yearsProvider(widget.eventData['name']).notifier).deleteYear(index);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final years = ref.watch(yearsProvider(widget.eventData['name']));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventData['name']),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.eventData['name'],
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Event History',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: years.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8, // Slightly more vertical space
              ),
              itemBuilder: (context, index) {
                final yearData = years[index];
                final year = yearData['year']?.toString() ?? 'Unknown';
                final image = yearData['image']?.toString() ?? '';
                final location = yearData['location']?.toString() ?? '';
                final description = yearData['description']?.toString() ?? '';
                final date = yearData['date']?.toString() ?? '';
                final isNetworkImage = image.startsWith('http') || image.startsWith('https');

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventTabsScreen(
                          event: {
                            'name': widget.eventData['name'],
                            'year': year,
                            'image': image,
                            'location': location,
                            'description': description,
                            'date': date,
                          },
                          isAdmin: widget.isAdmin,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    if (image.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: image.startsWith('http')
                                ? Image.network(image, fit: BoxFit.contain)
                                : Image.file(File(image), fit: BoxFit.contain),
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: image.isNotEmpty
                                ? (isNetworkImage
                                    ? Image.network(image, fit: BoxFit.cover)
                                    : Image.file(File(image), fit: BoxFit.cover))
                                : Container(
                                    color: AppColors.primary,
                                    child: const Icon(Icons.image, size: 56, color: Colors.white),
                                  ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      year,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditYearDialog(context, yearData, index);
                                      } else if (value == 'delete') {
                                        _confirmDeleteYear(context, index);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (location.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    'Location: $location',
                                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (date.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 1.0),
                                  child: Text(
                                    'Date: $date',
                                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
        onPressed: () async {
          final newYear = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddYearScreen(eventName: widget.eventData['name'])),
          );
          // Do NOT call _addNewYear here, since AddYearScreen already updates the provider.
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Year'),
        backgroundColor: AppColors.primary,
      )
          : null,
    );
  }
}
