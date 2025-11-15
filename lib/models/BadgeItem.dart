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
    title: 'Badge Débutante',
    description: 'Terminer votre première recette de beauté naturelle.',
    associatedRecipes: 13,
  ),
  BadgeItem(
    icon: 'assets/icons/badge2.svg',
    title: 'Badge Régulière',
    description: 'Réaliser 5 recettes de beauté naturelle différentes.',
    associatedRecipes: 5,
  ),
  BadgeItem(
    icon: 'assets/icons/dimond.svg',
    title: 'Badge Rapide',
    description: 'Compléter une recette en moins de 10 minutes.',
    associatedRecipes: 10,
  ),
  BadgeItem(
    icon: 'assets/icons/Group.svg',
    title: 'Badge Fidèle',
    description: 'Utiliser l’application pendant 30 jours consécutifs.',
    associatedRecipes: 0,
  ),
  BadgeItem(
    icon: 'assets/icons/police.svg',
    title: 'Badge Éclat',
    description: 'Partager 3 recettes préférées avec vos amis.',
    associatedRecipes: 0,
  ),
];
