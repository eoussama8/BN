class Profile {
  String userId;
  String name;
  String skinType;
  String allergyType;
  int age;

  Profile({
    required this.userId,
    required this.name,
    required this.skinType,
    required this.allergyType,
    required this.age,
  });

  // From JSON (for loading)
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['userId'] ?? 'default_user',
      name: json['name'] ?? '',
      skinType: json['skinType'] ?? 'Choose your skin type',
      allergyType: json['allergyType'] ?? 'Choose your allergy type',
      age: json['age'] ?? 18,
    );
  }

  // Convert to Map<String, String> for sending in HTTP
  Map<String, String> toFields() {
    return {
      'name': name,
      'skinType': skinType,
      'allergyType': allergyType,
      'age': age.toString(),
      'userId': userId, // include userId
    };
  }
}
