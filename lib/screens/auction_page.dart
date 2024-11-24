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
  bool _isLoading = true;
  String? _error;
  List<bool> wishlist = List.generate(10, (index) => false);
  RangeValues _priceRange = const RangeValues(0, 1000);
  bool _entirePlace = false;
  bool _privateRoom = false;
  bool _sharedRoom = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
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
          content: Text('Network Failed. Please try again.'),
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
