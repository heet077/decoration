import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final materialsProvider = StateNotifierProvider<MaterialsNotifier, List<Map<String, dynamic>>>((ref) => MaterialsNotifier());

class MaterialsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  MaterialsNotifier() : super([
    {
      'name': 'Stage Backdrop Fabric',
      'quantity': '50 yards',
      'cost': '250',
      'description': 'Red and gold fabric for main stage backdrop',
      'image': null,
    },
    {
      'name': 'LED Lights',
      'quantity': '20 units',
      'cost': '100',
      'description': 'Bright LED lights for stage illumination',
      'image': null,
    },
  ]);
  void addMaterial(Map<String, dynamic> material) => state = [material, ...state];
  void clear() => state = [];
}

class MaterialTab extends ConsumerStatefulWidget {
  final Map<String, dynamic> event;
  final bool isAdmin;

  const MaterialTab({Key? key, required this.event, required this.isAdmin}) : super(key: key);

  @override
  ConsumerState<MaterialTab> createState() => _MaterialTabState();
}

class _MaterialTabState extends ConsumerState<MaterialTab> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late AnimationController _addBtnController;

  @override
  void initState() {
    super.initState();
    _addBtnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 1.0,
      upperBound: 1.15,
    );
  }

  @override
  void dispose() {
    _addBtnController.dispose();
    super.dispose();
  }

  void _showAddMaterialDialog() {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String unit = '';
    String imageUrl = '';
    String notes = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Material'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
                    onSaved: (value) => name = value!.trim(),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Unit'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Unit is required' : null,
                    onSaved: (value) => unit = value!.trim(),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    onSaved: (value) => imageUrl = value?.trim() ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Notes'),
                    onSaved: (value) => notes = value?.trim() ?? '',
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
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  ref.read(materialsProvider.notifier).addMaterial({
                    'name': name,
                    'unit': unit,
                    'image_url': imageUrl,
                    'notes': notes,
                  });
                  _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 400));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final materials = ref.watch(materialsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:  {materials.length} items', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (widget.isAdmin)
                ScaleTransition(
                  scale: _addBtnController,
                  child: ElevatedButton.icon(
                    onPressed: _showAddMaterialDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedList(
            key: _listKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            initialItemCount: materials.length,
            itemBuilder: (context, index, animation) => _buildMaterialCard(context, index, animation, materials),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, int index, Animation<double> animation, List<Map<String, dynamic>> materials) {
    final material = materials[index];
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0.0,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primary.withOpacity(0.12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: material['image_url'] != null && material['image_url'].toString().isNotEmpty
                              ? Image.network(material['image_url'], fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: AppColors.primary, size: 24))
                              : const Icon(Icons.image, color: AppColors.primary, size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(material['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.straighten, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      const Text('Unit', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(material['unit'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          material['notes'] ?? '',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
