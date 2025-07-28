import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class EventTabsScreen extends StatefulWidget {
  final Map<String, String> event;
  final bool isAdmin;
  const EventTabsScreen({Key? key, required this.event, required this.isAdmin}) : super(key: key);

  @override
  State<EventTabsScreen> createState() => _EventTabsScreenState();
}

class _EventTabsScreenState extends State<EventTabsScreen> with SingleTickerProviderStateMixin {
  late List<Map<String, dynamic>> materials;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late AnimationController _addBtnController;

  @override
  void initState() {
    super.initState();
    materials = [
      {
        'name': 'Stage Backdrop Fabric',
        'quantity': '50 yards',
        'cost': ' 250',
        'description': 'Red and gold fabric for main stage backdrop',
        'image': widget.event['image'],
      },
      {
        'name': 'LED Lights',
        'quantity': '20 units',
        'cost': ' 100',
        'description': 'Bright LED lights for stage illumination',
        'image': widget.event['image'],
      },
    ];
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

  void _addMaterial() async {
    await _addBtnController.forward();
    await _addBtnController.reverse();
    final newMaterial = {
      'name': 'New Material',
      'quantity': '10 units',
      'cost': ' 50',
      'description': 'Description for new material',
      'image': widget.event['image'],
    };
    setState(() {
      materials.insert(0, newMaterial);
      _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 400));
    });
  }

  Widget _buildMaterialCard(BuildContext context, int index, Animation<double> animation) {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              child: material['image'] != null
                                  ? Image.network(material['image'], fit: BoxFit.cover)
                                  : const Icon(Icons.image, color: AppColors.primary, size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            material['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.list, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      const Text('Quantity', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(material['quantity'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 24),
                      Icon(Icons.attach_money, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      const Text('Cost', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(material['cost'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          material['description'],
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

  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Event Cost Summary', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Total Event Cost:   3750.50', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Material Costs:   1005.00', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Budget:   5000.00', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Remaining:   1249.50', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 24),
            pw.Text('Cost History', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Title', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Initial material purchase')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('2025-07-15')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('250.00')),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Additional decorations')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('2025-07-16')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('150.00')),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Setup labor')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('2025-07-17')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('300.00')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.event['name']} (${widget.event['year']})'),
          bottom: TabBar(
            labelColor: AppColors.veryLightBackground,
            unselectedLabelColor: Colors.white,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            indicatorColor: AppColors.secondary,
            indicatorWeight: 4,
            tabs: const [
              Tab(text: 'Material'),
              Tab(text: 'Design'),
              Tab(text: 'Cost'),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return Stack(
              children: [
                TabBarView(
                  children: [
                    // Material Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 24),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Total Materials', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${materials.length} items',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (widget.isAdmin)
                                  ScaleTransition(
                                    scale: _addBtnController,
                                    child: ElevatedButton.icon(
                                      onPressed: _addMaterial,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnimatedList(
                            key: _listKey,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            initialItemCount: materials.length,
                            itemBuilder: (context, index, animation) => _buildMaterialCard(context, index, animation),
                          ),
                        ],
                      ),
                    ),
                    // Design Tab
                    DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: AppColors.primary,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: AppColors.primary,
                            indicatorWeight: 3,
                            tabs: const [
                              Tab(text: 'Design Images'),
                              Tab(text: 'Final Decoration'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Design Images Tab
                                Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: GridView.count(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 18,
                                        mainAxisSpacing: 18,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        children: [
                                          _designImageCard(
                                            'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                                            'Stage backdrop design with floral arrangements',
                                            'Uploaded 2 days ago',
                                          ),
                                          _designImageCard(
                                            'https://images.unsplash.com/photo-1464983953574-0892a716854',
                                            'Entrance arch with balloon arrangements',
                                            'Uploaded 5 days ago',
                                          ),
                                          _designImageCard(
                                            'https://images.unsplash.com/photo-1516979187457-637abb4f9353',
                                            'Table centerpiece with candles and flowers',
                                            'Uploaded 1 week ago',
                                          ),
                                          _designImageCard(
                                            'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
                                            'Photo booth backdrop with colorful streamers',
                                            'Uploaded 2 weeks ago',
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (widget.isAdmin)
                                      Positioned(
                                        bottom: 16,
                                        right: 16,
                                        child: FloatingActionButton.extended(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Add Image'),
                                                content: const Text('This is where you add a new design image.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: const Text('Close'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.add_a_photo),
                                          label: const Text('Add Image'),
                                          backgroundColor: AppColors.primary,
                                        ),
                                      ),
                                  ],
                                ),
                                // Final Decoration Tab
                                Center(
                                  child: Text(
                                    'Final Decoration Images Coming Soon',
                                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Cost Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Event Cost Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total Event Cost', style: TextStyle(fontSize: 15, color: Colors.black87)),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.credit_card, color: Colors.green, size: 24),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: const [
                                            Text(' 3750.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.green)),
                                            Text('50', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.green)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.calculate, color: Colors.white, size: 18),
                                  label: const Text('Calculate'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Cost Breakdown
                          const Text('Cost Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.veryLightBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 24),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Material Costs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        SizedBox(height: 2),
                                        SizedBox(
                                          width: 120,
                                          child: Text(
                                            'Decorations, supplies, and materials',
                                            style: TextStyle(fontSize: 13, color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Flexible(
                                  child: Text(' 1005.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Budget Analysis
                          const Text('Budget Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('Remaining', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(' 5000.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                                    Text(' 1249.50', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Stack(
                                  children: [
                                    Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: 0.75,
                                      child: Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text('75.0% of budget used', style: TextStyle(fontSize: 13, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Cost History
                          const Text('Cost History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _costHistoryItem('Initial material purchase', '2025-07-15', ' 250.00', Colors.blue),
                                _costHistoryItem('Additional decorations', '2025-07-16', ' 150.00', Colors.blue),
                                _costHistoryItem('Setup labor', '2025-07-17', ' 300.00', Colors.orange),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 24),
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _exportPdf,
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                              label: const Text('Export PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Only show the FAB if admin and Design tab is selected
                if (widget.isAdmin)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: AnimatedBuilder(
                      animation: DefaultTabController.of(context),
                      builder: (context, child) {
                        final tabIndex = DefaultTabController.of(context)?.index ?? 0;
                        if (tabIndex == 1) {
                          // Design Images tab
                          return FloatingActionButton.extended(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Add Image'),
                                  content: const Text('This is where you add a new design image.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Add Image'),
                            backgroundColor: AppColors.primary,
                          );
                        } else if (tabIndex == 2) {
                          // Final Decoration tab
                          return FloatingActionButton.extended(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Add Final Decoration'),
                                  content: const Text('This is where you add a new final decoration image.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Add Final Decoration'),
                            backgroundColor: AppColors.secondary,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _costHistoryItem(String title, String date, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 2),
                  Text(date, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ],
          ),
          Flexible(
            child: Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _designImageCard(String imageUrl, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return Center(
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.95),
                                    child: Center(
                                      child: InteractiveViewer(
                                        minScale: 1.0,
                                        maxScale: 4.0,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(0),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
        color: const Color(0xFFF3F5E8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.network(
            imageUrl,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
} 