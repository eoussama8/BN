class BadgeItem {
  final String icon;
  final String title;
  final String description;
  final int associatedRecipes;

  BadgeItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.associatedRecipes,
  });
}

final List<BadgeItem> badges = [
  BadgeItem(
    icon: 'assets/icons/badge.svg',
    title: 'Beginner Badge',
    description: 'Complete your first natural beauty recipe.',
    associatedRecipes: 13,
  ),
  BadgeItem(
    icon: 'assets/icons/badge2.svg',
    title: 'Regular Badge',
    description: 'Complete 5 different natural beauty recipes.',
    associatedRecipes: 5,
  ),
  BadgeItem(
    icon: 'assets/icons/dimond.svg',
    title: 'Quick Badge',
    description: 'Finish a recipe in less than 10 minutes.',
    associatedRecipes: 10,
  ),
  BadgeItem(
    icon: 'assets/icons/defis.svg',
    title: 'Loyalty Badge',
    description: 'Use the app for 30 consecutive days.',
    associatedRecipes: 0,
  ),
  BadgeItem(
    icon: 'assets/icons/police.svg',
    title: 'Glow Badge',
    description: 'Share 3 favorite recipes with your friends.',
    associatedRecipes: 0,
  ),
];
