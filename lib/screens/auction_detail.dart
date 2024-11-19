import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nibret/models/auction.dart';
import 'package:nibret/services/auction_api.dart';

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
  late final Auction _auction;
  bool _isLoading = true;
  String? _error;
  List<bool> wishlist = List.generate(10, (index) => false);

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
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CarouselSlider.builder(
            itemCount: _auction.pictures.length,
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
              final picture = _auction.pictures[index];
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
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
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
      ],
    );
  }
}
