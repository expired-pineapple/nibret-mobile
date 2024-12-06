import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:nibret/screens/detail.dart';
import 'package:nibret/screens/login_screen.dart';
import 'package:nibret/services/auth_service.dart';
import 'package:nibret/services/wishlists_api.dart';
import '../models/property.dart';

class PropertyCard extends StatefulWidget {
  final Property property;

  const PropertyCard({
    super.key,
    required this.property,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

final AuthService _authService = AuthService();
Future<void> _checkAuthentication(context) async {
  bool isLoggedIn = await _authService.isLoggedIn();
  if (!isLoggedIn) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ));
  }
}

class _PropertyCardState extends State<PropertyCard> {
  int _currentImageIndex = 0;
  bool _isLoading = false;
  final WishListsApiService _wishListsApiService = WishListsApiService();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CarouselSlider.builder(
                  itemCount: widget.property.pictures.length,
                  options: CarouselOptions(
                    height: 170,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final picture = widget.property.pictures[index];
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          BlurHash(
                            hash: picture.blurHash,
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
              ),
              // Indicators
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      widget.property.pictures.asMap().entries.map((entry) {
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
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: widget.property.isWishListed
                        ? Colors.red
                        : Colors.white,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          _checkAuthentication(context);
                          await _wishListsApiService.toggleWishlist(
                              widget.property.id,
                              !widget.property.isWishListed);
                          setState(() {
                            _isLoading = false;
                          });
                        },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyDetails(
                      widget.property.id,
                      propertyId: widget.property.id,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.property.location.name,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.bed, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${widget.property.amenities.bedroom} Beds'),
                      const SizedBox(width: 16),
                      Icon(Icons.bathroom, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${widget.property.amenities.bathroom} Bathrooms'),
                      const SizedBox(width: 16),
                      Icon(Icons.square_foot,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${widget.property.amenities.area} m²'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${widget.property.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.property.discount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.property.discount}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
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
