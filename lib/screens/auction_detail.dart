import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nibret/models/auction.dart';
import 'package:nibret/services/auction_api.dart';
import 'package:nibret/widgets/expandable_text.dart';

class AuctionDetail extends StatefulWidget {
  final String auctionId;
  const AuctionDetail(String id, {super.key, required this.auctionId});

  @override
  State<AuctionDetail> createState() => _AuctionDetailState();
}

class _AuctionDetailState extends State<AuctionDetail>
    with TickerProviderStateMixin {
  int _currentImageIndex = 0;
  final ApiService _apiService = ApiService();
  Auction? _auction;
  // ignore: unused_field
  GoogleMapController? _mapController;
  bool _isLoading = true;
  String? _error;
  List<bool> wishlist = List.generate(10, (index) => false);

  @override
  void initState() {
    super.initState();
    _initializeData();
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
      final auction = await _apiService.getAuction(widget.auctionId);

      if (!mounted) return;

      setState(() {
        _auction = auction;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_auction == null) {
      return const Center(child: Text('No auction data available'));
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
                  itemCount: _auction?.pictures.length,
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
                    final picture = _auction?.pictures[index];
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
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _auction!.pictures.asMap().entries.map((entry) {
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
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: Icon(
                              _auction!.isWishListed
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _auction!.isWishListed
                                  ? Colors.red
                                  : Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ]),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _auction!.name,
                    style: const TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 26,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.pin_drop_outlined, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        _auction!.location.name,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 131, 131, 131),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color.fromARGB(255, 107, 107, 107)),
                  const SizedBox(height: 16),
                  ExpandableText(
                    text: _auction!.description,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Auction Information",
                    style: TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 26,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.attach_money,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Starting Bid:',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_auction!.startingBid}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Starting Date:',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _auction!.startDate,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'End Date:',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _auction!.endDate,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _auction!.location.latitude,
                            _auction!.location.longitude,
                          ),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('property'),
                            position: LatLng(
                              _auction!.location.latitude,
                              _auction!.location.longitude,
                            ),
                            infoWindow: InfoWindow(title: _auction!.name),
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
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
