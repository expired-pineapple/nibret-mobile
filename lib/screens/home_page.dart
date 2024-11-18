import 'package:flutter/material.dart';
import '../services/property_api.dart';
import '../models/property.dart';
import '../widgets/property_card.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nibret/screens/map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _error;
  List<bool> wishlist = List.generate(10, (index) => false);
  RangeValues _priceRange = const RangeValues(0, 1000);
  bool _entirePlace = false;
  bool _privateRoom = false;
  bool _sharedRoom = false;
  Position? _currentPosition;

  late TabController _tabController;
  final List<String> _categories = [
    "All",
    "Luxury Apartments",
    "Villa",
    "Rentals"
  ];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _initializeData();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Show a message that the permission is denied forever
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission is permanently denied')),
      );
    } else {
      // Permission granted, get the current location
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      // Use the current position (e.g., update the map)
      print("Current Location: $_currentPosition");
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _initializeData() async {
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final properties = await _apiService.getProperties();

      if (!mounted) return;

      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadProperties,
          ),
        ),
      );
    }
  }

  Future<void> _handleWishlistToggle(
      Property property, bool isWishlisted) async {
    try {
      await _apiService.toggleWishlist(property.id, isWishlisted);

      if (!mounted) return;

      setState(() {
        property.isWishListed = isWishlisted;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update wishlist: ${e.toString()}'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _handleWishlistToggle(property, isWishlisted),
          ),
        ),
      );
    }
  }

  Future<void> _handleRefresh() async {
    return _loadProperties();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Price Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 100,
                    labels: RangeLabels(
                      '\$${_priceRange.start.round()}',
                      '\$${_priceRange.end.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Property Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Column(),
                  CheckboxListTile(
                    title: const Text('Entire Place'),
                    value: _entirePlace,
                    onChanged: (bool? value) {
                      setState(() {
                        _entirePlace = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Private Room'),
                    value: _privateRoom,
                    onChanged: (bool? value) {
                      setState(() {
                        _privateRoom = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Shared Room'),
                    value: _sharedRoom,
                    onChanged: (bool? value) {
                      setState(() {
                        _sharedRoom = value!;
                      });
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A3B81),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // Apply filters logic here
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadProperties,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A3B81),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A3B81),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 18, 20),
            color: const Color(0xFF0A3B81),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.33),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search destinations',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      suffixIcon: IconButton.outlined(
                        icon: const Icon(
                          Icons.tune,
                          color: Colors.white,
                        ),
                        color: Colors.white.withOpacity(0.38),
                        onPressed: _showFilterBottomSheet,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF0A3B81),
                    indicatorColor: Colors.blue[900],
                    unselectedLabelColor:
                        const Color.fromARGB(255, 118, 121, 126),
                    isScrollable: true,
                    tabs: const [
                      Tab(text: "All", icon: Icon(Icons.house_outlined)),
                      Tab(
                        text: "Luxury Apartments",
                        icon: Icon(Icons.apartment),
                      ),
                      Tab(
                        text: "Villa",
                        icon: Icon(Icons.villa_outlined),
                      ),
                      Tab(
                        text: "Rentals",
                        icon: Icon(Icons.cottage_outlined),
                      )
                    ],
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? _buildErrorView()
                            : RefreshIndicator(
                                onRefresh: _handleRefresh,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: _categories.map((category) {
                                    return ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _properties.length,
                                      itemBuilder: (context, index) {
                                        final property = _properties[index];
                                        return PropertyCard(
                                          property: property,
                                          onWishlistToggle: (isWishlisted) =>
                                              _handleWishlistToggle(
                                                  property, isWishlisted),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey[800],
        label: const Text(
          "Map",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.map,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PropertyMapScreen(
                  properties: _properties,
                  // Optional: specify initial coordinates
                  latitude: 9.0,
                  longitude: 45.0,
                ),
              ));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
