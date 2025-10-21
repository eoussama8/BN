import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBar extends StatefulWidget {
  final String selectedNav;
  final Function(String) onNavChange;

  const BottomNavBar({
    Key? key,
    required this.selectedNav,
    required this.onNavChange,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  String hoveredNav = "";

  Widget _buildNavItem({required String label, required String iconPath}) {
    final bool isHovered = hoveredNav == label;
    final bool isActive = widget.selectedNav == label;
    final bool isSvg = iconPath.toLowerCase().endsWith('.svg');

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredNav = label),
      onExit: (_) => setState(() => hoveredNav = ""),
      child: GestureDetector(
        onTap: () => widget.onNavChange(label),
        child: SizedBox(
          width: 75,
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 26,
                width: 26,
                child: isSvg
                    ? SvgPicture.asset(
                  iconPath,
                  colorFilter: ColorFilter.mode(
                    isActive || isHovered ? Colors.white : Colors.white70,
                    BlendMode.srcIn,
                  ),
                )
                    : ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isActive || isHovered ? Colors.white : Colors.white70,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(iconPath, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedOpacity(
                opacity: (isActive || isHovered) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: const Color(0xFF8CA87D),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                label: "Home",
                iconPath: 'assets/images/icone-home.png',
              ),
              _buildNavItem(
                label: "Recipes",
                iconPath: 'assets/images/icone-recette.svg',
              ),
              _buildNavItem(
                label: "Passport",
                iconPath: 'assets/images/icone-passport.png',
              ),
              _buildNavItem(
                label: "Profile",
                iconPath: 'assets/images/icone-profil.png',
              ),
            ],
          ),
        ),
      ),
    );
  }
}