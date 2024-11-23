import 'package:nibret/models/auction.dart';
import 'package:nibret/models/property.dart';

class WishlistItem {
  final String id;
  final List<Property> property;
  final List<Auction> auctions;
  final String createdAt;
  final String updatedAt;
  final int user;

  WishlistItem({
    required this.id,
    required this.property,
    required this.auctions,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      property: (json['property'] as List<dynamic>)
          .map((p) => Property.fromJson(p))
          .toList(),
      auctions: (json['auctions'] as List<dynamic>)
          .map((a) => Auction.fromJson(a))
          .toList(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'],
    );
  }
}
