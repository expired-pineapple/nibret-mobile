import 'package:flutter/material.dart';

class Location {
  final String id;
  final String name;
  final double longitude;
  final double latitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Location({
    required this.id,
    required this.name,
    required this.longitude,
    required this.latitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Pictures {
  final String id;
  final bool isCover;
  final String imageUrl;
  final String blurHash;

  Pictures({
    required this.id,
    required this.isCover,
    required this.imageUrl,
    required this.blurHash,
  });

  factory Pictures.fromJson(Map<String, dynamic> json) {
    return Pictures(
      id: json['id'],
      isCover: json['is_cover'],
      imageUrl: json['image_url'],
      blurHash: json['blur_hash'],
    );
  }
}

class Auction {
  final String id;
  final Location location;
  final List<Pictures> pictures;
  final double startingBid;
  final String name;
  final String description;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  bool isWishListed;

  Auction(
      {required this.id,
      required this.location,
      required this.pictures,
      required this.name,
      required this.description,
      required this.startingBid,
      required this.status,
      required this.startDate,
      required this.endDate,
      this.isWishListed = false});

  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      id: json['id'],
      location: Location.fromJson(json['location']),
      pictures: (json['pictures'] as List<dynamic>)
          .map((pictureJson) => Pictures.fromJson(pictureJson))
          .toList(),
      name: json['name'],
      description: json['description'],
      startingBid: json['starting_bid'],
      status: json['status'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  Auction? copyWith({required bool isWishListed}) {
    return null;
  }
}
