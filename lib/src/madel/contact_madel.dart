class ContactMadel {
  final int? id;
  final String name;
  final String phone;

  ContactMadel({this.id, required this.name, required this.phone});

  // Map → Contact
  factory ContactMadel.fromMap(Map<String, dynamic> json) => ContactMadel(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
  );

  // Contact → Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }
}
