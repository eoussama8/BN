import '../utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../models/BadgeItem.dart';

class BadgeDetailView extends StatelessWidget {
  final BadgeItem badge;

  const BadgeDetailView({
    Key? key,
    required this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Progress value 0 -> 1

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.MainColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          badge.title,
          style: const TextStyle(
            color: AppColors.MainColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(height: 1, color: AppColors.greyMedium.withOpacity(0.15)),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    // MAIN CARD — BORDER ONLY
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.greyMedium.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,   // 👈 TEXT START LEFT
                        children: [
                          // Circle Icon Smaller
                          Center(
                            child: Container(
                              width: 130,   // 👈 smaller
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.Hover2.withOpacity(0.4),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  badge.icon,
                                  width: 60,   // 👈 smaller
                                  height: 60,
                                  color: AppColors.MainColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Title left
                          Text(
                            badge.title,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Description left
                          Text(
                            badge.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.greyMedium,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Divider(
                            color: AppColors.greyMedium.withOpacity(0.18),
                            thickness: 1,
                            indent: 40,
                            endIndent: 40,
                          ),

                          const SizedBox(height: 20),

                          // Requirement left
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.emoji_events_outlined,
                                  color: AppColors.MainColor, size: 25),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  badge.requirement,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.greyMedium,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Progress section left
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Progression : ${badge.progressText}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.greyMedium,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.Hover2,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  badge.statusText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: badge.isCompleted
                                        ? AppColors.greenBright
                                        : AppColors.MainColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // PROGRESS FIXED
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: (badge.currentProgress / badge.requiredCount).clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: AppColors.greyMedium.withOpacity(0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.MainColor),
                            ),
                          ),

                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Associated recipes button (with border only)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.greyMedium.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {},
                        leading: const Icon(Icons.menu_book,
                            color: AppColors.MainColor, size: 28),
                        title: const Text(
                          "Toutes les recettes Associées",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.greyTitle,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: AppColors.greyMedium.withOpacity(0.7), size: 18),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.MainColor,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Explorer des recettes",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
