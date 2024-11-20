class ApiService {
  String? id;
  List<Property>? property;
  List<Auctions>? auctions;
  String? createdAt;
  String? updatedAt;
  int? user;

  ApiService({id, property, auctions, createdAt, updatedAt, user});

  ApiService.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['property'] != null) {
      property = <Property>[];
      json['property'].forEach((v) {
        property!.add(Property.fromJson(v));
      });
    }
    if (json['auctions'] != null) {
      auctions = <Auctions>[];
      json['auctions'].forEach((v) {
        auctions!.add(Auctions.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (property != null) {
      data['property'] = property!.map((v) => v.toJson()).toList();
    }
    if (auctions != null) {
      data['auctions'] = auctions!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['user'] = user;
    return data;
  }
}

class Property {
  String? id;
  Location? location;
  List<Pictures>? pictures;
  Amenties? amenties;
  bool? isWishlisted;
  List<Null>? loaners;
  String? name;
  String? description;
  int? price;
  int? discount;
  bool? soldOut;
  bool? isStore;
  String? type;
  String? moveInDate;
  bool? isAuction;
  String? createdAt;
  String? updatedAt;
  int? createdBy;

  Property(
      {id,
      location,
      pictures,
      amenties,
      isWishlisted,
      loaners,
      name,
      description,
      price,
      discount,
      soldOut,
      isStore,
      type,
      moveInDate,
      isAuction,
      createdAt,
      updatedAt,
      createdBy});

  Property.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    if (json['pictures'] != null) {
      pictures = <Pictures>[];
      json['pictures'].forEach((v) {
        pictures!.add(Pictures.fromJson(v));
      });
    }
    amenties =
        json['amenties'] != null ? Amenties.fromJson(json['amenties']) : null;
    isWishlisted = json['is_wishlisted'];
    if (json['loaners'] != null) {
      loaners = <Null>[];
      json['loaners'].forEach((v) {
        loaners!.add(v);
      });
    }
    name = json['name'];
    description = json['description'];
    price = json['price'];
    discount = json['discount'];
    soldOut = json['sold_out'];
    isStore = json['is_store'];
    type = json['type'];
    moveInDate = json['move_in_date'];
    isAuction = json['is_auction'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (pictures != null) {
      data['pictures'] = pictures!.map((v) => v.toJson()).toList();
    }
    if (amenties != null) {
      data['amenties'] = amenties!.toJson();
    }
    data['is_wishlisted'] = isWishlisted;
    if (loaners != null) {
      data['loaners'] = loaners!.map((v) => v).toList();
    }
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    data['discount'] = discount;
    data['sold_out'] = soldOut;
    data['is_store'] = isStore;
    data['type'] = type;
    data['move_in_date'] = moveInDate;
    data['is_auction'] = isAuction;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    return data;
  }
}

class Location {
  String? id;
  String? name;
  double? longitude;
  double? latitude;
  String? createdAt;
  String? updatedAt;

  Location({id, name, longitude, latitude, createdAt, updatedAt});

  Location.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Pictures {
  String? id;
  String? property;
  bool? isCover;
  String? imageUrl;
  String? blurHash;

  Pictures({id, property, isCover, imageUrl, blurHash});

  Pictures.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    property = json['property'];
    isCover = json['is_cover'];
    imageUrl = json['image_url'];
    blurHash = json['blur_hash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['property'] = property;
    data['is_cover'] = isCover;
    data['image_url'] = imageUrl;
    data['blur_hash'] = blurHash;
    return data;
  }
}

class Amenties {
  String? id;
  String? property;
  int? bedroom;
  int? bathroom;
  int? area;
  String? createdAt;
  String? updatedAt;

  Amenties({id, property, bedroom, bathroom, area, createdAt, updatedAt});

  Amenties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    property = json['property'];
    bedroom = json['bedroom'];
    bathroom = json['bathroom'];
    area = json['area'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['property'] = property;
    data['bedroom'] = bedroom;
    data['bathroom'] = bathroom;
    data['area'] = area;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Auctions {
  String? id;
  String? startDate;
  Location? location;
  List<Pictures>? pictures;
  bool? isWishlisted;
  int? startingBid;
  String? endDate;
  String? name;
  String? description;
  String? status;
  String? createdAt;
  String? updatedAt;

  Auctions(
      {id,
      startDate,
      location,
      pictures,
      isWishlisted,
      startingBid,
      endDate,
      name,
      description,
      status,
      createdAt,
      updatedAt});

  Auctions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startDate = json['start_date'];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    if (json['pictures'] != null) {
      pictures = <Pictures>[];
      json['pictures'].forEach((v) {
        pictures!.add(Pictures.fromJson(v));
      });
    }
    isWishlisted = json['is_wishlisted'];
    startingBid = json['starting_bid'];
    endDate = json['end_date'];
    name = json['name'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['start_date'] = startDate;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (pictures != null) {
      data['pictures'] = pictures!.map((v) => v.toJson()).toList();
    }
    data['is_wishlisted'] = isWishlisted;
    data['starting_bid'] = startingBid;
    data['end_date'] = endDate;
    data['name'] = name;
    data['description'] = description;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
