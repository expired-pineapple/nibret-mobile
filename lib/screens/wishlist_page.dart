import 'package:flutter/material.dart';
import 'package:nibret/models/auction.dart';
import 'package:nibret/models/property.dart';
import 'package:nibret/provider/auth_provider.dart';
import 'package:nibret/screens/login_screen.dart';
import 'package:nibret/screens/signup_screen.dart';
import 'package:nibret/services/auth_service.dart';
import 'package:nibret/widgets/auction_card.dart';
import 'package:nibret/services/wishlists_api.dart';
import 'package:nibret/widgets/property_card.dart';
import 'package:provider/provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage>
    with TickerProviderStateMixin {
  final WishListsApiService _apiService = WishListsApiService();
  late TabController _tabController;
  bool _isAuthenticated = false;
  List<Auction> _auctions = [];
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _error;
  List<bool> wishlist = List.generate(10, (index) => false);
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _isAuthenticated = auth.isAuthenticated;
    _checkAuthentication();

    _initializeData();
  }

  Future<void> _checkAuthentication() async {
    bool isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn && mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ));
    }
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
        _auctions = properties.auctions;
        _properties = properties.property;
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

    if (!_isAuthenticated) {
      return Scaffold(
          backgroundColor: const Color(0xFF0668FE),
          body: Center(
            child: Column(
              children: [
                Image.asset('assets/Logo.png', height: 99, width: 120),
                const Text(
                  "Sign in to save your favorite homes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0668FE),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SignUpScreen(),
                    ));
                  },
                  child: const Text(
                    'Create an account',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ));
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
