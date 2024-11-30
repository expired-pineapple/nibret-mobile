class LoanResponse {
  final String id;
  final Loaner loaner;
  final Criteria criteria;
  final String name;
  final String description;

  LoanResponse({
    required this.id,
    required this.loaner,
    required this.criteria,
    required this.name,
    required this.description,
  });

  factory LoanResponse.fromJson(Map<String, dynamic> json) {
    return LoanResponse(
      id: json['id'],
      loaner: Loaner.fromJson(json['loaner']),
      criteria: Criteria.fromJson(json['criterias']),
      name: json['name'],
      description: json['description'],
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
