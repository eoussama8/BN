
// ==================== BadgeItem Model ====================
class BadgeItem {
  final String icon;
  final String title;
  final String description;
  final int associatedRecipes;
  final String requirement;
  final int currentProgress;
  final int requiredCount;
  final bool isCompleted;

  BadgeItem({
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
}


// ==================== Sample Data ====================
final List<BadgeItem> badges = [
  BadgeItem(
    icon: 'assets/icons/badge.svg',
    title: 'Badge Débutante',
    description: 'tu débutes ton aventure beauté !',
    requirement: 'Réaliser 1 recette',
    associatedRecipes: 13,
    currentProgress: 0,
    requiredCount: 1,
    isCompleted: false,
  ),
  BadgeItem(
    icon: 'assets/icons/badge2.svg',
    title: 'Badge Régulière',
    description: 'Complete 5 different natural beauty recipes.',
    requirement: 'Réaliser 5 recettes',
    associatedRecipes: 5,
    currentProgress: 2,
    requiredCount: 5,
    isCompleted: false,
  ),
  BadgeItem(
    icon: 'assets/icons/dimond.svg',
    title: 'Badge Rapide',
    description: 'Finish a recipe in less than 10 minutes.',
    requirement: 'Finir une recette en -10 min',
    associatedRecipes: 10,
    currentProgress: 0,
    requiredCount: 1,
    isCompleted: false,
  ),
  BadgeItem(
    icon: 'assets/icons/defis.svg',
    title: 'Badge Fidélité',
    description: 'Use the app for 30 consecutive days.',
    requirement: 'Utiliser l\'app 30 jours',
    associatedRecipes: 0,
    currentProgress: 15,
    requiredCount: 30,
    isCompleted: false,
  ),
  BadgeItem(
    icon: 'assets/icons/police.svg',
    title: 'Badge Éclat',
    description: 'Share 3 favorite recipes with your friends.',
    requirement: 'Partager 3 recettes',
    associatedRecipes: 0,
    currentProgress: 3,
    requiredCount: 3,
    isCompleted: true,
  ),
];