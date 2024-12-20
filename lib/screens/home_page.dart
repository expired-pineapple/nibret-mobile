import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nibret/widgets/map_with_custom_info.dart';
import 'package:nibret/widgets/multiselect.dart';
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
  List<String> _selectedPropertyType = [];
  bool _isLoading = false;
  bool _scrolling = true;
  String? _error;
  String? _next;
  String? _selectedCategory;
  String? _selectedStatus;

  late TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  List<Property> _properties = [];
  List<bool> wishlist = List.generate(10, (index) => false);

  late TabController _tabController;
  late TabController _filterTabController;
  final List<String> _categories = [
    "All",
    "Luxury Apartment",
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
  final List<String> _status = ["Rental", "Sale", "Sold"];
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _next != null) {
        _loadProperties(
            search: _searchController.text,
            scrolled: true,
            category: _selectedCategory,
            status: _selectedStatus);
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _properties.clear();
      _error = null;
      _next = null;
    });
    await _loadProperties();
  }

  void _handleTabChange() {
    _properties.clear();
    setState(() {
      _isLoading = true;
      _selectedCategory = _categories[_tabController.index];
    });
    _loadProperties(
        search: _searchController.text,
        category: _selectedCategory,
        status: _categories[_tabController.index]);
  }

  void _handleStatusTabChange() {
    _properties.clear();
    setState(() {
      _isLoading = true;
      _selectedStatus = _status[_filterTabController.index];
    });
    _loadProperties(
        category: _selectedCategory,
        status: _status[_filterTabController.index]);
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadProperties();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_searchListener);
    _filterTabController = TabController(
      length: _status.length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 300),
    );
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 300),
    );
    _tabController.addListener(_handleTabChange);
    _filterTabController.addListener(_handleStatusTabChange);
  }

  void _searchListener() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _properties.clear();
        _next = null;
      });
      _loadProperties();
      return;
    }

    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _properties.clear();
        _next = null;
      });
      _loadProperties(
          search: _searchController.text, category: _selectedCategory);
    });
  }

  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_searchListener);
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _tabController.dispose();
    _tabController.removeListener(_handleTabChange);
    super.dispose();
  }

  Future<void> _loadProperties(
      {String? search,
      String? category,
      bool scrolled = false,
      String? status}) async {
    print("HERE");
    if (!mounted) return;
    if (!scrolled) {
      setState(() {
        _isLoading = true;
      });
    } else {
      setState(() {
        _scrolling = true;
      });
    }
    try {
      final data = await _apiService.getProperties(
          next: _next, searchQuery: search, category: category, status: status);

      final List<dynamic> jsonList = data['results'];
      print(jsonList);
      final newItems = jsonList.map((json) => Property.fromJson(json)).toList();
      setState(() {
        _properties.addAll(newItems);
        _next = data['next'];
        _isLoading = false;
        _scrolling = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _scrolling = false;
      });
    }
  }

  Future<void> _searchProperties() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final requestBody = {
        'type': _selectedPropertyType,
        'min_price': _priceRange.start,
        'max_price': _priceRange.end * 1000,
        'bathroom': _selectedBathrooms,
        'bedroom': _selectedBedrooms,
        "status": _selectedStatus
      };

      final data = await _apiService.searchProperties(requestBody);

      setState(() {
        _properties = data;
      });
    } catch (e) {
      setState(() {
        _error = "Something went wrong.";
        _isLoading = false;
      });
    }
  }

  void resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000);
      _selectedBedrooms = null;
      _selectedBathrooms = null;
      _selectedPropertyType = [];
      _searchController.clear();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      enableDrag: true,
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
          builder: (context, scrollController) => Column(
            children: [
              TabBar(
                controller: _filterTabController,
                labelColor: const Color(0xFF0668FE),
                indicatorColor: Colors.blue[900],
                physics: const PageScrollPhysics(),
                unselectedLabelColor: const Color.fromARGB(255, 118, 121, 126),
                tabs: _status.map((status) {
                  return Tab(
                      child: Text(
                    status,
                    style:
                        const TextStyle(fontSize: 18, fontFamily: 'Montserrat'),
                  ));
                }).toList(),
              ),
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TabBarView(
                      controller: _filterTabController,
                      children: _status.map((status) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Price Range',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      resetFilters();
                                    });
                                  },
                                  child: const Text(
                                    'Reset Filters',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Color.fromARGB(255, 13, 71, 161)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            RangeSlider(
                              activeColor: Colors.blue[900],
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
                              'Property Type',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropDownMultiSelect(
                              whenEmpty: "Select Property Type",
                              onChanged: (List<String> x) {
                                setState(() {
                                  _selectedPropertyType = x;
                                });
                              },
                              options: _categories,
                              selectedValues: _selectedPropertyType,
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
                            SizedBox(
                              height: 40, // Added fixed height
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _selectedBedrooms == null
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
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
                                              color: _selectedBedrooms ==
                                                      (index + 1)
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
                            SizedBox(
                              height: 40, // Added fixed height
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _selectedBathrooms == null
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                _selectedBathrooms ==
                                                        (index + 1)
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
                                              color: _selectedBathrooms ==
                                                      (index + 1)
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
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[900],
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  _searchProperties();
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Apply Filters',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
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
                      controller: _searchController,
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
                    physics: const PageScrollPhysics(),
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
                        case 'Luxury Apartment':
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
                            : TabBarView(
                                controller: _tabController,
                                children: _categories.map((category) {
                                  return RefreshIndicator(
                                      onRefresh: _refresh,
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.all(16),
                                        itemCount: _properties.length,
                                        itemBuilder: (context, index) {
                                          if (index == _properties.length) {
                                            if (_scrolling) {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Color.fromARGB(
                                                        255, 13, 71, 161),
                                                  ),
                                                ),
                                              );
                                            }
                                            if (_properties.isEmpty) {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Text(
                                                      'No Properties available'),
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          }

                                          final item = _properties[index];
                                          return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 16),
                                              child: PropertyCard(
                                                property: item,
                                              ));
                                        },
                                      ));
                                }).toList(),
                              ),
                  )
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
