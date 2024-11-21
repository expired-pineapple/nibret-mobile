import 'package:nibret/models/auction.dart';
import 'package:nibret/models/property.dart';

class WishlistItem {
  final List<Auction> auctions;
  final List<Property> property;

  WishlistItem({
    required this.auctions,
    required this.property,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      auctions: (json['auctions'] as List)
          .map((item) => Auction.fromJson(item))
          .toList(),
      property: (json['property'] as List)
          .map((item) => Property.fromJson(item))
          .toList(),
    );
  }
}
