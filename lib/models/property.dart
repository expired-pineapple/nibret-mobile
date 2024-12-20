import 'package:flutter/material.dart';

class Loaner {
  final String id;
  final String name;
  final bool realStateProvided;
  final String? logo;
  final String? phone;

  Loaner({
    required this.id,
    required this.name,
    required this.realStateProvided,
    this.logo,
    this.phone,
  });

  factory Loaner.fromJson(Map<String, dynamic> json) {
    return Loaner(
      id: json['id'] as String,
      name: json['name'] as String,
      realStateProvided: json['real_state_provided'] as bool,
      logo: json['logo'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'real_state_provided': realStateProvided,
      'logo': logo,
      'phone': phone,
    };
  }
}

class LoanerResponse {
  final String id;
  final Loaner loaner;
  final String description;

  LoanerResponse({
    required this.id,
    required this.loaner,
    required this.description,
  });

  factory LoanerResponse.fromJson(Map<String, dynamic> json) {
    return LoanerResponse(
      id: json['id'] as String,
      loaner: Loaner.fromJson(json['loaner'] as Map<String, dynamic>),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loaner': loaner.toJson(),
    };
  }
}

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
  final String property;
  final bool isCover;
  final String imageUrl;
  final String blurHash;

  Pictures({
    required this.id,
    required this.property,
    required this.isCover,
    required this.imageUrl,
    required this.blurHash,
  });

  factory Pictures.fromJson(Map<String, dynamic> json) {
    return Pictures(
      id: json['id'],
      property: json['property'],
      isCover: json['is_cover'],
      imageUrl: json['image_url'],
      blurHash: json['blur_hash'],
    );
  }
}

class Category {
  final String title;
  final Icon icon;

  Category({required this.title, required this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json['title'],
      icon: Icon(json['icon']),
    );
  }
}

class Amenities {
  final String id;
  final String property;
  final int bedroom;
  final int bathroom;
  final double area;
  final DateTime createdAt;
  final DateTime updatedAt;

  Amenities({
    required this.id,
    required this.property,
    required this.bedroom,
    required this.bathroom,
    required this.area,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Amenities.fromJson(Map<String, dynamic> json) {
    return Amenities(
      id: json['id'],
      property: json['property'],
      bedroom: json['bedroom'],
      bathroom: json['bathroom'],
      area: json['area'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Property {
  final String id;
  final Location location;
  final List<Pictures> pictures;
  final Amenities amenities;
  final String name;
  final String description;
  final double price;
  final double discount;
  final bool soldOut;
  final String type;
  final List<LoanerResponse>? loaners;
  bool isWishListed;
  String currency;

  Property(
      {required this.id,
      required this.location,
      required this.pictures,
      required this.amenities,
      required this.name,
      required this.description,
      required this.price,
      required this.discount,
      required this.soldOut,
      required this.type,
      this.currency = "ETB",
      this.loaners,
      this.isWishListed = false});

  factory Property.fromJson(json) {
    return Property(
      id: json['id'],
      location: Location.fromJson(json['location']),
      pictures: (json['pictures'] as List<dynamic>)
          .map((pictureJson) => Pictures.fromJson(pictureJson))
          .toList(),
      amenities: Amenities.fromJson(json['amenties']),
      name: json['name'],
      description: json['description'],
      price: json['price'],
      currency: json['currency'],
      discount: json['discount'],
      soldOut: json['sold_out'],
      type: json['type'],
      loaners: (json['loaner_detail'] as List<dynamic>)
          .map((loaners) => LoanerResponse.fromJson(loaners))
          .toList(),
    );
  }

  Property? copyWith({required bool isWishListed}) {
    return null;
  }
}
