import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nibret/screens/login_screen.dart';
import 'package:nibret/services/auth_service.dart';
import 'package:nibret/widgets/MapWithCustomInfo.dart';
import 'package:nibret/widgets/property_skeleton.dart';
import '../services/property_api.dart';
import '../models/property.dart';
import '../widgets/property_card.dart';
import 'package:nibret/services/wishlists_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nibret/screens/map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Filter states
  RangeValues _priceRange = const RangeValues(0, 1000);
  int? _selectedBedrooms;
  int? _selectedBathrooms;
  String? _selectedPropertyType;
  String _searchQuery = '';

  // Filtered properties getter
  List<Property> get filteredProperties {
    return _properties.where((property) {
      // Price filter
      final price = property.price / 1000; // Convert to thousands
      if (price < _priceRange.start || price > _priceRange.end) {
        return false;
      }

      // Bedrooms filter
      if (_selectedBedrooms != null &&
          property.amenities.bedroom != _selectedBedrooms) {
        return false;
      }

      // Bathrooms filter
      if (_selectedBathrooms != null &&
          property.amenities.bathroom != _selectedBathrooms) {
        return false;
      }

      // Property type filter
      if (_selectedPropertyType != null &&
          property.type.toLowerCase() != _selectedPropertyType!.toLowerCase()) {
        return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty &&
          !property.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !property.location.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();
  }

  final ApiService _apiService = ApiService();
  final WishListsApiService _wishlistservice = WishListsApiService();
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _error;
  List<bool> wishlist = List.generate(10, (index) => false);

  late TabController _tabController;
  final List<String> _categories = [
    "All",
    "Luxury Apartments",
    "Villa",
    "Plot Land",
    "Single Family",
    "Apartment",
    "Penthouse",
    "Townhouse",
    "Commercial",
    "Condominium",
    "Office Space",
    "Warehouse",
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
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
    }
  }

  Future<void> _handleWishlistToggle(
      Property property, bool isWishlisted) async {
    try {
      await _wishlistservice.toggleWishlist(property.id, isWishlisted);

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
              height:
                  MediaQuery.of(context).size.height * 0.9, // Increased height
              child: SingleChildScrollView(
                // Added ScrollView to handle overflow
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                      activeColor: Colors.blue[900],
                      min: 5,
                      max: 1000,
                      divisions: 100,
                      labels: RangeLabels(
                        '\$${_priceRange.start.round()}k',
                        '\$${_priceRange.end.round()}k',
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _priceRange = values;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bedroom',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              print("pressed");
                            },
                            child: const Text(
                              "Any",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () {
                              print("pressed");
                            },
                            child: const Text(
                              "1",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () {
                              print("pressed");
                            },
                            child: const Text("2",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () {
                              print("pressed");
                            },
                            child: const Text("3",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () {
                              print("pressed");
                            },
                            child: const Text("4",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bathroom',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              print("pressed");
                            },
                            child: const Text("Any",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () {
                              print("pressed");
                            },
                            child: const Text("1",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () {
                              print("pressed");
                            },
                            child: const Text("2",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () {
                              print("pressed");
                            },
                            child: const Text("3",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () {
                              print("pressed");
                            },
                            child: const Text("4",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Property Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 153, 152, 152),
                                    width: 2.0,
                                  ),
                                ),
                                elevation: 0,
                                child: const Padding(
                                  padding: EdgeInsets.all(18.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.apartment_outlined),
                                      SizedBox(height: 10),
                                      Text("Luxury Apartments",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 153, 152, 152),
                                    width: 2.0,
                                  ),
                                ),
                                elevation: 0,
                                child: const Padding(
                                  padding: EdgeInsets.all(18.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.villa_outlined),
                                      SizedBox(height: 10),
                                      Text('Villa',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 153, 152, 152),
                                    width: 2.0,
                                  ),
                                ),
                                elevation: 0,
                                child: const Padding(
                                  padding: EdgeInsets.all(18.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.near_me_sharp),
                                      SizedBox(height: 10),
                                      Text("Plot Land",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 153, 152, 152),
                                    width: 2.0,
                                  ),
                                ),
                                elevation: 0,
                                child: const Padding(
                                  padding: EdgeInsets.all(18.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.villa_outlined),
                                      SizedBox(height: 10),
                                      Text('Villa',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0668FE),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
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
            _error ?? "Please connect to the internet",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadProperties,
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Retry',
              selectionColor: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0668FE),
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
      backgroundColor: const Color(0xFF0668FE),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 18, 20),
            color: const Color(0xFF0668FE),
            child: Column(
              children: [
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.33),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white),
                    ),
                    child: TextField(
                      style: const TextStyle(
                          color: Colors.white), // Add this for white text
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                      },
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
                          style: OutlinedButton.styleFrom(
                            side:
                                BorderSide(color: Colors.white.withOpacity(0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _showFilterBottomSheet,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: const Color.fromRGBO(0, 0, 0, 1)
                            .withOpacity(0.3), // Add slight background
                        filled: true, // Enable background fill
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ))
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
                    labelColor: const Color(0xFF0668FE),
                    indicatorColor: Colors.blue[900],
                    unselectedLabelColor:
                        const Color.fromARGB(255, 118, 121, 126),
                    isScrollable: true,
                    tabs: _categories.map((category) {
                      IconData iconData;
                      switch (category.toLowerCase()) {
                        case 'all':
                          iconData = Icons.dashboard_rounded;
                          break;
                        case 'luxury apartments':
                          iconData = Icons.apartment_rounded;
                          break;
                        case 'villa':
                          iconData = Icons.villa_rounded;
                          break;
                        case 'plot land':
                          iconData = Icons.landscape_rounded;
                          break;
                        case 'single family':
                          iconData = Icons.home_rounded;
                          break;
                        case 'apartment':
                          iconData = Icons.apartment_rounded;
                          break;
                        case 'penthouse':
                          iconData = Icons.business_rounded;
                          break;
                        case 'townhouse':
                          iconData = Icons.home_work_rounded;
                          break;
                        case 'commercial':
                          iconData = Icons.store_rounded;
                          break;
                        case 'condominium':
                          iconData = Icons.location_city_rounded;
                          break;
                        case 'office space':
                          iconData = Icons.corporate_fare_rounded;
                          break;
                        case 'warehouse':
                          iconData = Icons.warehouse_rounded;
                          break;
                        default:
                          iconData = Icons.house_rounded;
                      }

                      return Tab(
                        text: category,
                        icon: Icon(iconData),
                      );
                    }).toList(),
                  ),
                  Expanded(
                    child: _isLoading
                        ? ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return const PropertyCardSkeleton();
                            },
                          )
                        : _error != null
                            ? _buildErrorView()
                            : RefreshIndicator(
                                onRefresh: _handleRefresh,
                                child: TabBarView(
                                  physics: const PageScrollPhysics(),
                                  controller: _tabController,
                                  children: _categories.map((category) {
                                    // Filter properties based on category
                                    List<Property> filteredProperties =
                                        category == "All"
                                            ? _properties
                                            : _properties.where((property) {
                                                return property.type
                                                        .toLowerCase() ==
                                                    category.toLowerCase();
                                              }).toList();

                                    return filteredProperties.isEmpty
                                        ? const Center(
                                            child: Text(
                                                'No properties found in this category'),
                                          )
                                        : ListView.builder(
                                            padding: const EdgeInsets.all(16),
                                            itemCount:
                                                filteredProperties.length,
                                            itemBuilder: (context, index) {
                                              final property =
                                                  filteredProperties[index];
                                              return PropertyCard(
                                                property: property,
                                              );
                                            },
                                          );
                                  }).toList(),
                                ),
                              ),
                  )
                ],
              ),
            ),
          )
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
                builder: (_) => const MapScreen(),
              ));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
