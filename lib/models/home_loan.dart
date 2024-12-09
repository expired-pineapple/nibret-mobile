class LoanResponse {
  final String id;
  final Loaner loaner;
  final List<Criteria>? criteria;
  final String name;
  final String description;

  LoanResponse(
      {required this.id,
      required this.loaner,
      required this.name,
      required this.description,
      this.criteria});

  factory LoanResponse.fromJson(json) {
    return LoanResponse(
      id: json['id'],
      loaner: Loaner.fromJson(json['loaner']),
      name: json['name'],
      description: json['description'],
      criteria: (json['criteria'] as List<dynamic>)
          .map((crieteria) => Criteria.fromJson(crieteria))
          .toList(),
    );
  }
}

class Loaner {
  final String id;
  final String name;
  final bool realStateProvided;
  final String logo;
  final String phone;

  Loaner({
    required this.id,
    required this.name,
    required this.realStateProvided,
    required this.logo,
    required this.phone,
  });

  factory Loaner.fromJson(Map<String, dynamic> json) {
    return Loaner(
      id: json['id'],
      name: json['name'],
      realStateProvided: json['real_state_provided'],
      logo: json['logo'],
      phone: json['phone'],
    );
  }
}

class Criteria {
  final String id;
  final String description;

  Criteria({
    required this.id,
    required this.description,
  });

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
      id: json['id'],
      description: json['description'],
    );
  }
}
