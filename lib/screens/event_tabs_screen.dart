// event_tabs_screen.dart (modified main file)
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'material_tab.dart';
import 'design_tab.dart';
import 'cost_tab.dart';

class EventTabsScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isAdmin;

  const EventTabsScreen({Key? key, required this.event, required this.isAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${event['name']} (${event['year']})'),
          bottom: const TabBar(
            labelColor: AppColors.background,
            unselectedLabelColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            indicatorColor: AppColors.secondary,
            indicatorWeight: 4,
            tabs: [
              Tab(text: 'Material'),
              Tab(text: 'Design'),
              Tab(text: 'Cost'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MaterialTab(event: event, isAdmin: isAdmin),
            DesignTab(event: event, isAdmin: isAdmin),
            CostTab(event: event, isAdmin: isAdmin),
          ],
        ),
      ),
    );
  }
}
