

class ProfileModel {
  final String? id;
  final String skinType;
  final int age;
  final String allergyType;
  final String? avatarUrl;

  ProfileModel({
    this.id,
    required this.skinType,
    required this.age,
    required this.allergyType,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json["_id"],
      skinType: json["skinType"],
      age: json["age"],
      allergyType: json["allergyType"],
      avatarUrl: json["avatarUrl"],
    );
  }
}
