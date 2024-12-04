import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nibret/models/property.dart';
import 'package:nibret/screens/request_tour.dart';
import 'package:nibret/services/property_api.dart';
import 'package:nibret/services/wishlists_api.dart';
import 'package:nibret/widgets/expandable_text.dart';
import 'package:nibret/widgets/loaners_card.dart';

class PropertyDetails extends StatefulWidget {
  final String propertyId;
  const PropertyDetails(String id, {super.key, required this.propertyId});

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails>
    with TickerProviderStateMixin {
  int _currentImageIndex = 0;
  GoogleMapController? _mapController;
  final ApiService _apiService = ApiService();
  Property? _property;
  bool _isLoading = true;
  String? _error;
  List<bool> wishlist = List.generate(10, (index) => false);
  final WishListsApiService _wishListsApiService = WishListsApiService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadProperties();
  }

  Future<void> _loadProperties() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final property = await _apiService.getProperty(widget.propertyId);

      if (!mounted) return;

      setState(() {
        _property = property;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = "Opps, Something went wrong.";
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    return _loadProperties();
  }

  Widget _buildAmenityRow({required IconData icon, required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            fontFamily: 'Poppins',
            color: Color(0xFF4A4A4A),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CarouselSlider.builder(
                  itemCount: _property?.pictures.length,
                  options: CarouselOptions(
                    height: 323,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final picture = _property?.pictures[index];
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          BlurHash(
                            hash: picture!.blurHash,
                            imageFit: BoxFit.cover,
                          ),
                          Image.network(
                            picture.imageUrl,
                            fit: BoxFit.cover,
                            frameBuilder: (context, child, frame,
                                wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded) return child;
                              return AnimatedOpacity(
                                opacity: frame == null ? 0 : 1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                child: child,
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white,
                                child: const Center(
                                  child: Icon(Icons.error_outline, size: 50),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: _property?.isWishListed ?? false
                                ? Colors.red
                                : Colors.white,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    await _wishListsApiService.toggleWishlist(
                                        _property!.id,
                                        _property?.isWishListed ?? false);
                                  } catch (e) {
                                    // Handle error (optional)
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _property!.name,
                    style: const TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.pin_drop_outlined,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _property!.location.name,
                        style: const TextStyle(
                          color: Color(0xFF838383),
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_property!.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RequestTour(
                                property: true,
                                propertyId: widget.propertyId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0668FE),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Request Tour',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFF6B6B6B)),
                  const SizedBox(height: 16),
                  ExpandableText(
                    text: _property!.description,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "What this place offers",
                    style: TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAmenityRow(
                          icon: Icons.bathroom,
                          text: '${_property!.amenities.bathroom} Bathrooms',
                        ),
                        const SizedBox(height: 12),
                        _buildAmenityRow(
                          icon: Icons.square_foot,
                          text: '${_property!.amenities.area} m²',
                        ),
                        const SizedBox(height: 12),
                        _buildAmenityRow(
                          icon: Icons.bed,
                          text: '${_property!.amenities.bedroom} Beds',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Where you'll be",
                    style: TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _property!.location.latitude,
                            _property!.location.longitude,
                          ),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('property'),
                            position: LatLng(
                              _property!.location.latitude,
                              _property!.location.longitude,
                            ),
                            infoWindow: InfoWindow(title: _property!.name),
                          ),
                        },
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        myLocationEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                    ),
                  ),
                  const Text(
                    "Available Loaners",
                    style: TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: _property!.loaners.isEmpty
                        ? 0
                        : 400, // Adjust height as needed
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _property!.loaners.length,
                      itemBuilder: (context, index) {
                        final property = _property!.loaners[index];
                        return LoanerCard(
                          loaner: property,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 24)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
