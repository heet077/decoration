import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'event_details_screen.dart';
import 'login_screen.dart';

class EventScreen extends StatefulWidget {
  final bool isAdmin;
  const EventScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchBarVisible = true;
  List<String> _filteredEvents = [];
  List<Map<String, dynamic>> _allEventsData = [
    {
      'name': 'Annual Gathering',
      'years': [
        {'year': '2024', 'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb'},
        {'year': '2023', 'image': 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622'},
        {'year': '2022', 'image': 'https://images.unsplash.com/photo-1515187029135-18ee286d815b'},
      ]
    },
    {
      'name': 'Music Night',
      'years': [
        {'year': '2023', 'image': 'https://images.unsplash.com/photo-1464983953574-0892a716854'},
        {'year': '2022', 'image': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f'},
        {'year': '2021', 'image': 'https://images.unsplash.com/photo-1516280440614-37939bbacd81'},
      ]
    },
    {
      'name': 'Tech Conference',
      'years': [
        {'year': '2024', 'image': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308'},
        {'year': '2023', 'image': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87'},
        {'year': '2022', 'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d'},
      ]
    },
    {
      'name': 'Art Exhibition',
      'years': [
        {'year': '2022', 'image': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca'},
        {'year': '2021', 'image': 'https://images.unsplash.com/photo-1541961017774-22349e4a1262'},
        {'year': '2020', 'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96'},
      ]
    },
    {
      'name': 'Charity Run',
      'years': [
        {'year': '2023', 'image': 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429'},
        {'year': '2022', 'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b'},
        {'year': '2021', 'image': 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5'},
      ]
    },
    {
      'name': 'Food Festival',
      'years': [
        {'year': '2024', 'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836'},
        {'year': '2023', 'image': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1'},
        {'year': '2022', 'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'},
      ]
    },
    {
      'name': 'Book Fair',
      'years': [
        {'year': '2022', 'image': 'https://images.unsplash.com/photo-1516979187457-637abb4f9353'},
        {'year': '2021', 'image': 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570'},
        {'year': '2020', 'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d'},
      ]
    },
    {
      'name': 'Startup Meetup',
      'years': [
        {'year': '2023', 'image': 'https://images.unsplash.com/photo-1461344577544-4e5dc9487184'},
        {'year': '2022', 'image': 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f'},
        {'year': '2021', 'image': 'https://images.unsplash.com/photo-1552664730-d307ca884978'},
      ]
    },
    {
      'name': 'Yoga Workshop',
      'years': [
        {'year': '2024', 'image': 'https://images.unsplash.com/photo-1502082553048-f009c37129b9'},
        {'year': '2023', 'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b'},
        {'year': '2022', 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4'},
      ]
    },
    {
      'name': 'Science Expo',
      'years': [
        {'year': '2022', 'image': 'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99'},
        {'year': '2021', 'image': 'https://images.unsplash.com/photo-1532094349884-543bc11b234d'},
        {'year': '2020', 'image': 'https://images.unsplash.com/photo-1581094794329-c8112a89af12'},
      ]
    },
  ];
  List<String> _allEvents = [
    'Annual Gathering',
    'Music Night',
    'Tech Conference',
    'Art Exhibition',
    'Charity Run',
    'Food Festival',
    'Book Fair',
    'Startup Meetup',
    'Yoga Workshop',
    'Science Expo',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _filteredEvents = List.from(_allEvents);
    print('Default events loaded: ${_filteredEvents.length}'); // Debug print
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && _isSearchBarVisible) {
      setState(() {
        _isSearchBarVisible = false;
      });
    } else if (_scrollController.offset <= 50 && !_isSearchBarVisible) {
      setState(() {
        _isSearchBarVisible = true;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredEvents = List.from(_allEvents);
      } else {
        _filteredEvents = _allEvents
            .where((event) => event.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
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
      backgroundColor: AppColors.veryLightBackground,
      body: Column(
        children: [
          // Header section with search
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchBarVisible ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isSearchBarVisible ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discover Amazing Events',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_filteredEvents.length} events available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(  
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search events...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Events list
          Expanded(
            child: _filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      final eventName = _filteredEvents[index];
                      final eventData = _allEventsData.firstWhere((e) => e['name'] == eventName);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EventDetailsScreen(eventData: eventData, isAdmin: widget.isAdmin),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  // Event icon container
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primary, AppColors.secondary],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.event,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // Event details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          eventName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Arrow icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
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
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Event'),
                    content: const Text('This is where you add a new event.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Event'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
} 