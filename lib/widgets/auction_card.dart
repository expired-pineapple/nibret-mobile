import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:nibret/models/auction.dart';

class AuctionCard extends StatefulWidget {
  final Auction auction;
  final Function(bool) onWishlistToggle;

  const AuctionCard({
    super.key,
    required this.auction,
    required this.onWishlistToggle,
  });

  @override
  State<AuctionCard> createState() => _AuctionCardState();
}

class _AuctionCardState extends State<AuctionCard> {
  int _currentImageIndex = 0;

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
                  itemCount: widget.auction.pictures.length,
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
                    final picture = widget.auction.pictures[index];
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
                      widget.auction.pictures.asMap().entries.map((entry) {
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
                    widget.auction.isWishListed
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        widget.auction.isWishListed ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    widget.onWishlistToggle(!widget.auction.isWishListed);
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.auction.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.auction.location.name,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('Start Date: ${widget.auction.startDate}'),
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money_sharp,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${widget.auction.startingBid} Starting bid'),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
