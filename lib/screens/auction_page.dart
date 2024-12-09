import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nibret/models/auction.dart';
import 'package:nibret/widgets/auction_card.dart';
import 'package:nibret/widgets/property_skeleton.dart';
import '../services/auction_api.dart';

class AuctionPage extends StatefulWidget {
  const AuctionPage({super.key});

  @override
  State<AuctionPage> createState() => _AuctionPageState();
}

class _AuctionPageState extends State<AuctionPage>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Auction> _properties = [];
  bool _hasMoreData = true;
  bool _isLoading = true;
  String? _error;
  String? _next;
  List<bool> wishlist = List.generate(10, (index) => false);

  void _searchListener() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _properties.clear();
        _next = null;
        _hasMoreData = true;
      });
      _loadProperties();
      return;
    }

    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _properties.clear();
        _next = null;
        _hasMoreData = true;
      });
      _loadProperties(search: _searchController.text);
    });
  }

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _loadProperties();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_searchListener);
  }

  @override
  void dispose() {
    _apiService.dispose();
    _searchDebounce?.cancel();
    _searchController.removeListener(_searchListener);
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  late TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        _loadProperties(search: _searchController.text, scroll: true);
      }
    }
  }

  Future<void> _loadProperties(
      {String? search, String? category, bool scroll = false}) async {
    if (!mounted) return;
    if (!scroll) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final data = await _apiService.getAuctions(
        next: _next,
        searchQuery: search,
      );

      final List<dynamic> jsonList = data['results'];
      final newItems = jsonList.map((json) => Auction.fromJson(json)).toList();
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

  Future<void> _handleWishlistToggle(
      Auction property, bool isWishlisted) async {
    try {
      await _apiService.toggleWishlist(
        itemId: property.id,
        isWishlisted: isWishlisted,
        isProperty: false,
      );

      if (!mounted) return;

      setState(() {
        property.isWishListed = isWishlisted;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Network Failed. Please try again.'),
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

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Something went wrong",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadProperties,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
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
                        hintText: 'Search Auctions',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
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
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _properties.length,
                                    itemBuilder: (context, index) {
                                      final property = _properties[index];
                                      return AuctionCard(
                                        auction: property,
                                        onWishlistToggle: (isWishlisted) =>
                                            _handleWishlistToggle(
                                                property, isWishlisted),
                                      );
                                    },
                                  )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
