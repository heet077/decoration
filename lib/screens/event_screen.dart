import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'event_details_screen.dart';
import 'login_screen.dart';
import 'add_event_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventListProvider = StateNotifierProvider<EventListNotifier, List<Map<String, dynamic>>>((ref) => EventListNotifier());
final filteredEventNamesProvider = StateProvider<List<String>>((ref) => []);

class EventListNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  EventListNotifier() : super([]);
  void addEvent(Map<String, dynamic> event) => state = [...state, event];
  void clear() => state = [];
}

class EventScreen extends ConsumerStatefulWidget {
  final bool isAdmin;
  const EventScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchBarVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    // Initialize filtered events with all event names
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final allEvents = ref.read(eventListProvider).map((e) => e['name'] as String).toList();
      ref.read(filteredEventNamesProvider.notifier).state = allEvents;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && _isSearchBarVisible) {
      setState(() => _isSearchBarVisible = false);
    } else if (_scrollController.offset <= 50 && !_isSearchBarVisible) {
      setState(() => _isSearchBarVisible = true);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final allEvents = ref.read(eventListProvider).map((e) => e['name'] as String).toList();
    ref.read(filteredEventNamesProvider.notifier).state = query.isEmpty
        ? List.from(allEvents)
        : allEvents.where((event) => event.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allEventsData = ref.watch(eventListProvider);
    final filteredEvents = ref.watch(filteredEventNamesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchBarVisible ? 60 : 0,
            child: _isSearchBarVisible
                ? Padding(
                    padding: const EdgeInsets.only(top: 8,left: 8,right: 8,bottom: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          Expanded(
            child: filteredEvents.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.search_off, size: 80, color: AppColors.secondary),
                  SizedBox(height: 16),
                  Text(
                    'No events found',
                    style: TextStyle(fontSize: 20, color: AppColors.primary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try searching with different keywords',
                    style: TextStyle(fontSize: 16, color: AppColors.secondary),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final eventName = filteredEvents[index];
                final eventData = allEventsData.firstWhere((e) => e['name'] == eventName, orElse: () => {});
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        if (eventData.isNotEmpty) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EventDetailsScreen(eventData: eventData, isAdmin: widget.isAdmin),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.event, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                eventName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
        onPressed: () async {
          // 👇 Await the result from AddEventScreen
          final newEvent = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEventScreen()),
          );

          // 👇 If a valid event is returned, add it to the lists and update UI
          if (newEvent != null && newEvent is Map<String, dynamic>) {
            ref.read(eventListProvider.notifier).addEvent(newEvent);
            final allEvents = ref.read(eventListProvider).map((e) => e['name'] as String).toList();
            ref.read(filteredEventNamesProvider.notifier).state = allEvents;
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
        backgroundColor: AppColors.primary,
      )
          : null,

    );
  }
}
