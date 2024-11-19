import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nibret/models/property.dart';
import 'package:nibret/screens/request_tour.dart';
import 'package:nibret/services/property_api.dart';
import 'package:nibret/widgets/expandable_text.dart';

class PropertyDetails extends StatefulWidget {
  final String propertyId;
  const PropertyDetails(String id, {super.key, required this.propertyId});

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();

  void onWishlistToggle(bool isWishListed) {}
}

class _PropertyDetailsState extends State<PropertyDetails>
    with TickerProviderStateMixin {
  int _currentImageIndex = 0;
  final ApiService _apiService = ApiService();
  Property? _property; // Changed to nullable
  bool _isLoading = true;
  String? _error;
  List<bool> wishlist = List.generate(10, (index) => false);

  @override
  void initState() {
    super.initState();
    _initializeData(); // Initialize data when widget is created
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
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    return _loadProperties();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
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
                // Indicators
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _property!.pictures.asMap().entries.map((entry) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == entry.key
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Wishlist button
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      _property!.isWishListed
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          _property!.isWishListed ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      widget.onWishlistToggle(_property!.isWishListed);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                children: [
                  Text(
                    _property!.name,
                    style: const TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 26,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.pin_drop_outlined,
                        size: 20,
                      ),
                      Text(
                        _property!.location.name,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 131, 131, 131),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                                builder: (_) => const RequestTour(
                                  property: false,
                                  auctionId: '1',
                                ),
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A3B81),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 14),
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
                            height: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 9,
                    padding: const EdgeInsets.only(
                        top: 8, left: 24, right: 24, bottom: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 1,
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 107, 107, 107)),
                        ),
                      ],
                    ),
                  ),
                  ExpandableText(
                    text: _property!.description,
                    maxLines: 4,
                  ),
                  const Text(
                    "What this place offers",
                    style: TextStyle(
                      color: Color.fromARGB(255, 131, 131, 131),
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Column(children: [
                    Row(
                      children: [
                        Icon(Icons.bathroom, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${_property!.amenities.bathroom} Bathrooms'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.square_foot,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${_property!.amenities.area} m²')
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.bed, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${_property!.amenities.bedroom} Beds')
                      ],
                    )
                  ]),
                  const Text(
                    "Where you'll be",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
