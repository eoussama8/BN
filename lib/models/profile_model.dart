class Profile {
  String userId;
  String firstName;
  String lastName;
  String skinType;
  List<String> allergyTypes; // ✅ multiple allergies
  int age;

  Profile({
    required this.userId,
    this.firstName = '',
    this.lastName = '',
    required this.skinType,
    required this.allergyTypes,
    required this.age,
  });

  /// From JSON (loading from backend)
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['userId'] ?? 'default_user',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      skinType: json['skinType'] ?? 'Choose your skin type',
      allergyTypes: json['allergyType'] != null
          ? List<String>.from(json['allergyType'])
          : [],
      age: json['age'] ?? 18,
    );
  }

  /// Convert to Map<String, dynamic> for sending in HTTP
  Map<String, String> toFields() {
    final fields = <String, String>{
      'userId': userId,
      'skinType': skinType,
      'age': age.toString(),
      'firstName': firstName,
      'lastName': lastName,
    };

    // For multiple allergies, add as allergyType[]
    for (int i = 0; i < allergyTypes.length; i++) {
      fields['allergyType[$i]'] = allergyTypes[i];
    }

    return fields;
  }
}
