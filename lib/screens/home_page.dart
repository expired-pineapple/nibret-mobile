import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nibret/widgets/map_with_custom_info.dart';
import 'package:nibret/widgets/property_skeleton.dart';
import '../services/property_api.dart';
import '../models/property.dart';
import '../widgets/property_card.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  RangeValues _priceRange = const RangeValues(0, 1000);
  int? _selectedBedrooms;
  int? _selectedBathrooms;
  bool _isLoading = false;
  bool _hasMoreData = true;
  String _searchQuery = '';
  String _type = '';
  String? _error;
  String? _next;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  List<Property> _properties = [];
  List<bool> wishlist = List.generate(10, (index) => false);

  late TabController _tabController;
  List<String> _selectedCategories = [];
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
    _loadProperties(); // Initial load
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 300),
    );

    // Listen for tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });
  }

  void _onTabChanged(int index) {
    if (_categories[index] != "All") {
      _type = _categories[index];
    } else {
      // Load all properties if "All" is selected
      _refresh();
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading) {
        _loadProperties();
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _properties.clear();
      _hasMoreData = true;
      _error = null;
      _next = null;
    });
    await _loadProperties();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _apiService.getProperties(
        next: _next,
        searchQuery: _searchQuery,
        type: _type,
      );

      final List<dynamic> jsonList = data['results'];
      final newItems = jsonList.map((json) => Property.fromJson(json)).toList();

      setState(() {
        if (data['next']) {
          _hasMoreData = false;
        } else {
          _properties.addAll(newItems);
          _next = data['next'];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Oops, Something went wrong.";
        _isLoading = false;
      });
    }
  }

  void resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000);
      _selectedBedrooms = null;
      _selectedBathrooms = null;
      _searchQuery = '';
      _type = '';
      _searchController.clear();
      _selectedCategories = [];
    });
  }

  void _toggleSelection(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _showMultiSelectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Categories"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _categories.map((category) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return CheckboxListTile(
                      title: Text(category),
                      value: _selectedCategories.contains(category),
                      onChanged: (bool? isChecked) {
                        if (isChecked != null) {
                          _toggleSelection(category);
                          setState(
                              () {}); // Update the checkbox state immediately
                        }
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Done"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendFilterRequest() async {
    // Construct the JSON body
    Map<String, dynamic> requestBody = {
      'type': _selectedCategories.map((category) => category.trim()).toList(),
      'min_price': _priceRange.start,
      'max_price': _priceRange.end * 1000,
      'bathroom': _selectedBathrooms,
      'bedroom': _selectedBedrooms,
    };

    // Set headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'User-Agent': 'insomnia/10.1.1',
    };

    // Send the request
    final response = await http.post(
      Uri.parse('https://nibret-vercel-django.vercel.app/properties/search/'),
      headers: headers,
      body: json.encode(requestBody),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _properties = (data as List)
            .map((property) => Property.fromJson(property))
            .toList();
      });
    } else {
      // Handle error response
      setState(() {
        _error = 'Failed to load properties: ${response.statusCode}';
        _properties = [];
        _loadProperties();
      });
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            resetFilters();
                          });
                        },
                        child: const Text('Reset Filters'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Property Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showMultiSelectDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedCategories.isNotEmpty
                            ? _selectedCategories.join(', ')
                            : 'Select categories',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Price Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${_priceRange.start.round()}k'),
                      Text('\$${_priceRange.end.round()}k'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bedrooms',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedBedrooms == null
                                ? Colors.blue[900]
                                : Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedBedrooms = null;
                            });
                          },
                          child: Text(
                            "Any",
                            style: TextStyle(
                              color: _selectedBedrooms == null
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        ...List.generate(4, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _selectedBedrooms == (index + 1)
                                        ? Colors.blue[900]
                                        : Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedBedrooms = index + 1;
                                });
                              },
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color: _selectedBedrooms == (index + 1)
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bathrooms',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedBathrooms == null
                                ? Colors.blue[900]
                                : Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedBathrooms = null;
                            });
                          },
                          child: Text(
                            "Any",
                            style: TextStyle(
                              color: _selectedBathrooms == null
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        ...List.generate(4, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _selectedBathrooms == (index + 1)
                                        ? Colors.blue[900]
                                        : Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedBathrooms = index + 1;
                                });
                              },
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color: _selectedBathrooms == (index + 1)
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
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
                        _sendFilterRequest();
                        setState(() {
                          // Filters are already applied through state
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

  Future<void> _fetchProperties(String query) async {
    if (query.isEmpty) {
      _properties = [];
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url =
        'https://nibret-vercel-django.vercel.app/properties?search=${Uri.encodeComponent(query)}';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        // Parse the response body
        final data = json.decode(response.body);
        setState(() {
          _properties = (data['results'] as List)
              .map((property) => Property.fromJson(property))
              .toList();
        });
      } else {
        setState(() {
          _error = 'Failed to load properties';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                        _fetchProperties(_searchQuery);
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
                          side: BorderSide(color: Colors.white.withOpacity(0)),
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
                  ),
                )
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
                                onRefresh: _loadProperties,
                                child: TabBarView(
                                  physics: const PageScrollPhysics(),
                                  controller: _tabController,
                                  children: _categories.map((category) {
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
                                                'No properties found in this category'))
                                        : ListView.builder(
                                            padding: const EdgeInsets.all(16),
                                            itemCount:
                                                filteredProperties.length,
                                            itemBuilder: (context, index) {
                                              final property =
                                                  filteredProperties[index];
                                              return PropertyCard(
                                                  property: property);
                                            },
                                          );
                                  }).toList(),
                                ),
                              ),
                  ),
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
