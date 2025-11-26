class BadgeItem {
  final int id; // <-- add this
  final String icon;
  final String title;
  final String description;
  final int associatedRecipes;
  final String requirement;
  final int currentProgress;
  final int requiredCount;
  final bool isCompleted;

  BadgeItem({
    required this.id, // <-- add required id
    required this.icon,
    required this.title,
    required this.description,
    required this.associatedRecipes,
    required this.requirement,
    this.currentProgress = 0,
    required this.requiredCount,
    this.isCompleted = false,
  });

  String get statusText => isCompleted ? 'Complété' : 'En cours';
  String get progressText => '$currentProgress/$requiredCount';

  factory BadgeItem.fromJson(Map<String, dynamic> json) {
    return BadgeItem(
      id: json['id'], // <-- parse id
      icon: json['icon'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requirement: json['requirement'] ?? '',
      associatedRecipes: json['associatedRecipes'] ?? 0,
      currentProgress: json['currentProgress'] ?? 0,
      requiredCount: json['requiredCount'] ?? 1,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
