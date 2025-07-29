import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final designImagesProvider = StateNotifierProvider<DesignImagesNotifier, List<Map<String, dynamic>>>((ref) => DesignImagesNotifier());
final finalDecorationImagesProvider = StateNotifierProvider<FinalDecorationImagesNotifier, List<Map<String, dynamic>>>((ref) => FinalDecorationImagesNotifier());

class DesignImagesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  DesignImagesNotifier() : super([]);
  void addImage(Map<String, dynamic> image) => state = [image, ...state];
  void clear() => state = [];
  void removeAt(int index) {
    final newList = [...state]..removeAt(index);
    state = newList;
  }
}
class FinalDecorationImagesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FinalDecorationImagesNotifier() : super([]);
  void addImage(Map<String, dynamic> image) => state = [image, ...state];
  void clear() => state = [];
  void removeAt(int index) {
    final newList = [...state]..removeAt(index);
    state = newList;
  }
}

class DesignTab extends ConsumerStatefulWidget {
  final Map<String, dynamic> event;
  final bool isAdmin;

  const DesignTab({Key? key, required this.event, required this.isAdmin}) : super(key: key);

  @override
  ConsumerState<DesignTab> createState() => _DesignTabState();
}

class _DesignTabState extends ConsumerState<DesignTab> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final designImages = ref.watch(designImagesProvider);
    final finalDecorationImages = ref.watch(finalDecorationImagesProvider);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Design Images'),
              Tab(text: 'Final Decoration'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildImageGrid(context, widget.isAdmin, 'Add Design Image', true, designImages),
                _buildImageGrid(context, widget.isAdmin, 'Add Final Decoration', false, finalDecorationImages),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, bool isAdmin, String label, bool isDesignTab, List<Map<String, dynamic>> images) {
    return Stack(
      children: [
        GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: List.generate(
            images.length,
            (index) => GestureDetector(
              onLongPress: () {
                final imagePath = images[index]['image_path'] ?? '';
                if (imagePath.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                        ),
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
                        child: images[index]['image_path'] != null && images[index]['image_path'].toString().isNotEmpty
                            ? Image.file(
                                File(images[index]['image_path']),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48),
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 48),
                              ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                isDesignTab
                                    ? (images[index]['notes'] ?? '')
                                    : (images[index]['description'] ?? ''),
                                style: const TextStyle(fontSize: 13, color: Colors.white),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white70),
                            tooltip: 'Delete',
                            onPressed: () {
                              if (isDesignTab) {
                                ref.read(designImagesProvider.notifier).removeAt(index);
                              } else {
                                ref.read(finalDecorationImagesProvider.notifier).removeAt(index);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isAdmin)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () => _showAddDialog(context, label, isDesignTab),
              icon: const Icon(Icons.add_a_photo),
              label: Text(label),
              backgroundColor: AppColors.primary,
            ),
          ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, String label, bool isDesignTab) {
    final _formKey = GlobalKey<FormState>();
    XFile? pickedImage;
    String notesOrDesc = '';
    setStateDialog() => setState;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(label),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (pickedImage != null)
                        Image.file(
                          File(pickedImage!.path),
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.browse_gallery),
                        label: const Text('Browse'),
                        onPressed: () async {
                          final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setStateDialog(() {
                              pickedImage = image;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: isDesignTab ? 'Notes' : 'Description',
                        ),
                        onSaved: (value) => notesOrDesc = value?.trim() ?? '',
                      ),
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
                    if (pickedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image.')));
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (isDesignTab) {
                        ref.read(designImagesProvider.notifier).addImage({
                          'image_path': pickedImage!.path,
                          'notes': notesOrDesc,
                        });
                      } else {
                        ref.read(finalDecorationImagesProvider.notifier).addImage({
                          'image_path': pickedImage!.path,
                          'description': notesOrDesc,
                        });
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
