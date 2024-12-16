import 'package:flutter/material.dart';
import 'package:nibret/models/auction.dart';
import 'package:nibret/models/property.dart';
import 'package:nibret/widgets/auction_card.dart';
import 'package:nibret/services/wishlists_api.dart';
import 'package:nibret/widgets/property_card.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage>
    with TickerProviderStateMixin {
  final WishListsApiService _apiService = WishListsApiService();
  late TabController _tabController;
  List<Auction> _auctions = [];
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _error;
  List<bool> wishlist = List.generate(10, (index) => false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      final properties = await _apiService.getWishlistedItems();

      if (!mounted) return;

      setState(() {
        if (properties.auctions!.isNotEmpty) {
          _auctions = properties.auctions!;
        }
        if (properties.property!.isNotEmpty) {
          _properties = properties.property!;
        }
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

  Future<void> _handleWishlistToggle(dynamic item, bool isWishlisted) async {
    try {
      if (!mounted) return;

      setState(() {
        item.isWishListed = isWishlisted;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Network Failed. Please try again.'),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _handleWishlistToggle(item, isWishlisted),
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
              backgroundColor: const Color(0xFF0668FE),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildErrorView();
    }
    return TabBarView(
      controller: _tabController,
      children: [
        // Auctions Tab
        RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _auctions.length,
            itemBuilder: (context, index) {
              final property = _auctions[index];
              return AuctionCard(
                auction: property,
                onWishlistToggle: (isWishlisted) =>
                    _handleWishlistToggle(property, isWishlisted),
              );
            },
          ),
        ),

        // Properties Tab
        RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _properties.length,
            itemBuilder: (context, index) {
              final property = _properties[index];
              return PropertyCard(property: property);
            },
          ),
        ),
      ],
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
                    decoration: InputDecoration(
                      hintText: 'Search destinations',
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
          TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Auctions'),
              Tab(text: 'Properties'),
            ],
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
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }
}
