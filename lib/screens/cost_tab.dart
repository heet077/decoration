import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final costProvider = StateNotifierProvider.family<CostNotifier, List<Map<String, dynamic>>, String>((ref, eventName) => CostNotifier());

class CostNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CostNotifier() : super([]);
  void addCost(Map<String, dynamic> cost) => state = [...state, cost];
  void clear() => state = [];
  void updateCost(int index, Map<String, dynamic> updatedCost) {
    final newList = [...state];
    newList[index] = updatedCost;
    state = newList;
  }
  void deleteCost(int index) {
    final newList = [...state]..removeAt(index);
    state = newList;
  }
}

class CostTab extends ConsumerWidget {
  final Map<String, dynamic> event;
  final bool isAdmin;

  const CostTab({Key? key, required this.event, required this.isAdmin}) : super(key: key);

  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text('Event Cost Summary', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Total Cost: ₹3750.50'),
            pw.Text('Material: ₹1005.00'),
            pw.Text('Budget: ₹5000.00'),
            pw.Text('Remaining: ₹1249.50'),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final costs = ref.watch(costProvider(event['name']));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Event Costs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              if (isAdmin)
                ElevatedButton.icon(
                  onPressed: () => _showAddCostDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Cost'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (costs.isEmpty)
            const Text('No costs added yet.'),
          ...costs.asMap().entries.map((entry) {
            final index = entry.key;
            final cost = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(cost['description'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Date: ${cost['date'] ?? ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('₹${cost['amount'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (isAdmin) ...[
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueGrey),
                        tooltip: 'Edit',
                        onPressed: () => _showEditCostDialog(context, ref, cost, index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDeleteCost(context, ref, index),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAddCostDialog(BuildContext context, WidgetRef ref) {
    final _formKey = GlobalKey<FormState>();
    String description = '';
    String amount = '';
    DateTime date = DateTime.now();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Cost'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Description is required' : null,
                    onSaved: (value) => description = value!.trim(),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Amount is required' : null,
                    onSaved: (value) => amount = value!.trim(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Date:'),
                      const SizedBox(width: 8),
                      Text(DateFormat('yyyy-MM-dd').format(date)),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            date = picked;
                            (context as Element).markNeedsBuild();
                          }
                        },
                      ),
                    ],
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
                  ref.read(costProvider(event['name']).notifier).addCost({
                    'description': description,
                    'amount': double.tryParse(amount) ?? 0.0,
                    'date': DateFormat('yyyy-MM-dd').format(date),
                  });
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

  void _showEditCostDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> cost, int index) {
    final _formKey = GlobalKey<FormState>();
    String description = cost['description'] ?? '';
    String amount = (cost['amount'] ?? '').toString();
    DateTime date = DateTime.tryParse(cost['date'] ?? '') ?? DateTime.now();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Cost'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Description is required' : null,
                    onSaved: (value) => description = value!.trim(),
                  ),
                  TextFormField(
                    initialValue: amount,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Amount is required' : null,
                    onSaved: (value) => amount = value!.trim(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Date:'),
                      const SizedBox(width: 8),
                      Text(DateFormat('yyyy-MM-dd').format(date)),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            date = picked;
                            (context as Element).markNeedsBuild();
                          }
                        },
                      ),
                    ],
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
                  ref.read(costProvider(event['name']).notifier).updateCost(index, {
                    'description': description,
                    'amount': double.tryParse(amount) ?? 0.0,
                    'date': DateFormat('yyyy-MM-dd').format(date),
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteCost(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cost'),
        content: const Text('Are you sure you want to delete this cost?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(costProvider(event['name']).notifier).deleteCost(index);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
