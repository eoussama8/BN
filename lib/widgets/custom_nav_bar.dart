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
      height: 60,
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

          Widget iconWidget;
          if (index == 2) {
            iconWidget = SvgPicture.asset(
              "assets/icons/defis.svg",
              height: active ? 22 : 18,
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
              size: active ? 22 : 20, // smaller icon sizes
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
                  height: active ? 32 : 32,
                  width: active ? 48 : 32,
                  decoration: active
                      ? BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  )
                      : null,
                  alignment: Alignment.center,
                  child: iconWidget,
                ),
                const SizedBox(height: 3),
                AnimatedOpacity(
                  opacity: active ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    labels[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
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