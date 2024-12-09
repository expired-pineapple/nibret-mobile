import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nibret/widgets/map_with_custom_info.dart';
import 'package:nibret/widgets/property_skeleton.dart';
import '../services/property_api.dart';
import '../models/property.dart';
import '../widgets/property_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  RangeValues _priceRange = const RangeValues(0, 1000);
  int? _selectedBedrooms;
  int? _selectedBathrooms;
  String? _selectedPropertyType;
  bool _isLoading = false;
  bool _hasMoreData = true;
  String _searchQuery = '';
  String? _error;
  String? _next;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final List<Property> _properties = [];
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
    if (mounted) {
      _loadProperties();
      _scrollController.addListener(_scrollListener);
      _tabController = TabController(
        length: _categories.length,
        vsync: this,
        animationDuration: const Duration(milliseconds: 300),
      );
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
      _next = null; // Reset next URL on refresh
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
    if (!mounted || _isLoading || (!_hasMoreData && _next != null)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _apiService.getProperties(
        next: _next,
        searchQuery: _searchQuery,
      );

      final List<dynamic> jsonList = data['results'];
      final newItems = jsonList.map((json) => Property.fromJson(json)).toList();

      setState(() {
        if (newItems.isEmpty) {
          _hasMoreData = false;
        } else {
          _properties.addAll(newItems);
          _next = data['next'];
          _hasMoreData = data['next'] != null;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000);
      _selectedBedrooms = null;
      _selectedBathrooms = null;
      _selectedPropertyType = null;
      _searchQuery = '';
      _searchController.clear();
    });
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
                        child: Text(
                            selectionColor: Colors.blue[900], 'Reset Filters'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: _selectedPropertyType ==
                                      "Luxury Apartments"
                                  ? Colors.blue[900]!
                                  : const Color.fromARGB(255, 153, 152, 152),
                              width: 2.0,
                            ),
                          ),
                          elevation: 0,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPropertyType = "Luxury Apartments";
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(18.0),
                              child: Column(
                                children: [
                                  Icon(Icons.apartment_outlined),
                                  SizedBox(height: 10),
                                  Text(
                                    "Luxury Apartments",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: _selectedPropertyType == "Villa"
                                  ? Colors.blue[900]!
                                  : const Color.fromARGB(255, 153, 152, 152),
                              width: 2.0,
                            ),
                          ),
                          elevation: 0,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPropertyType = "Villa";
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(18.0),
                              child: Column(
                                children: [
                                  Icon(Icons.home_work_outlined),
                                  SizedBox(height: 10),
                                  Text(
                                    "Villa",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
                        setState(() {});
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
                      style: const TextStyle(color: Colors.white),
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
                        fillColor:
                            const Color.fromRGBO(0, 0, 0, 1).withOpacity(0.3),
                        filled: true,
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
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: _categories.map((category) {
                        return _error != null
                            ? _buildErrorView()
                            : RefreshIndicator(
                                onRefresh: _refresh,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _properties.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == _properties.length) {
                                      if (_isLoading) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      if (!_hasMoreData) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child:
                                                Text('No Properties available'),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }

                                    final item = _properties[index];
                                    if (category == "All" ||
                                        item.type == category) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: PropertyCard(
                                          property: item,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              );
                      }).toList(),
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
                builder: (_) => const MapScreen(),
              ));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
