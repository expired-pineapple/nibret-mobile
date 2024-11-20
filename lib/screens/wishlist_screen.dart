import 'package:flutter/material.dart';
import 'package:nibret/models/auction.dart';
import 'package:nibret/models/property.dart';
import 'package:nibret/services/wishlists_api.dart';
import 'package:nibret/widgets/auction_card.dart';
import 'package:nibret/widgets/property_card.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage>
    with TickerProviderStateMixin {
  final WishlistApiService _apiService = WishlistApiService();
  List<WishlistItem> _properties = [];
  List<AuctionItem> _auctions = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _apiService.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadProperties();
    await _loadAuctions();
  }

  Future<void> _loadProperties() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final properties = await _apiService.getWishlistedProperties();
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

  Future<void> _loadAuctions() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auctions = await _apiService.getWishlistedAuctions();
      if (!mounted) return;
      setState(() {
        _auctions = auctions;
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
            onPressed: _loadAuctions,
          ),
        ),
      );
    }
  }

  Future<void> _handleWishlistToggle({
    required String itemId,
    required bool isWishlisted,
    bool isProperty = true,
  }) async {
    try {
      await _apiService.toggleWishlist(
        itemId: itemId,
        isWishlisted: isWishlisted,
        isProperty: isProperty,
      );

      if (!mounted) return;

      // if (isProperty) {
      //   setState(() {
      //     _properties.firstWhere((p) => p.id == itemId).isWishListed =
      //         isWishlisted;
      //   });
      // } else {
      //   setState(() {
      //     _auctions.firstWhere((a) => a.id == itemId).isWishListed =
      //         isWishlisted;
      //   });
      // }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network Failed. Please try again.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _handleWishlistToggle(
              itemId: itemId,
              isWishlisted: isWishlisted,
              isProperty: isProperty,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _handleRefresh() async {
    await _loadProperties();
    await _loadAuctions();
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
            onPressed: () {
              _loadProperties();
              _loadAuctions();
            },
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

  Widget _buildWishlistView() {
    if (_selectedIndex == 0) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _properties.length,
        itemBuilder: (context, index) {
          final property = _properties[index];
          return PropertyCard(
            property: property as Property,
            onWishlistToggle: (isWishlisted) => _handleWishlistToggle(
              itemId: property.id,
              isWishlisted: isWishlisted,
              isProperty: true,
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _auctions.length,
        itemBuilder: (context, index) {
          final auction = _auctions[index];
          return AuctionCard(
            auction: auction as Auction,
            onWishlistToggle: (isWishlisted) => _handleWishlistToggle(
              itemId: auction.id,
              isWishlisted: isWishlisted,
              isProperty: false,
            ),
          );
        },
      );
    }
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                  ),
                  labelColor: const Color(0xFF0A3B81),
                  unselectedLabelColor: Colors.white,
                  tabs: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Tab(text: 'Properties'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Tab(text: 'Auctions'),
                    ),
                  ],
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
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
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? _buildErrorView()
                            : RefreshIndicator(
                                onRefresh: _handleRefresh,
                                child: _buildWishlistView(),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
