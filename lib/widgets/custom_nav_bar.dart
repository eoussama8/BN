import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> labels = const [
    "Home",
    "Recipes",
    "Challenges",
    "Favorites",
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCF3085), Color(0xFFF4639B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (index) {
          final bool active = index == selectedIndex;

          // --- ICÔNES (SVG sur index 2)
          Widget iconWidget;
          if (index == 2) {
            iconWidget = SvgPicture.asset(
              "lib/assets/icons/defis.svg",
              height: active ? 26 : 22,
              colorFilter: ColorFilter.mode(
                active ? const Color(0xFFCF3085) : Colors.white,
                BlendMode.srcIn,
              ),
            );
          } else {
            final List<IconData> icons = [
              UniconsLine.estate,
              UniconsLine.book_open,
              UniconsLine.heart,
              UniconsLine.user,
            ];

            iconWidget = Icon(
              index == 3
                  ? UniconsLine.heart
                  : index == 4
                      ? UniconsLine.user
                      : icons[index],
              size: active ? 26 : 24,
              color: active ? const Color(0xFFCF3085) : Colors.white,
            );
          }

          return GestureDetector(
            onTap: () => onTap(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  height: active ? 38 : 38,
                  width: active ? 60 : 38,
                  decoration: active
                      ? BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        )
                      : null,
                  alignment: Alignment.center,
                  child: iconWidget,
                ),
                const SizedBox(height: 4),
                AnimatedOpacity(
                  opacity: active ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    labels[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
