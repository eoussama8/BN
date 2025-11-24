import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/BadgeItem.dart';
import '../models/profile_model.dart';
import '../utils/constants.dart';
import 'profile_edit_view.dart';

class ProfileSummaryView extends StatelessWidget {
  final Profile profile;
  final String? avatarUrl;

  // Statistics variables
  final int challengesCompleted;
  final int beautyCoins;
  final int testedRecipes;

  const ProfileSummaryView({
    Key? key,
    required this.profile,
    this.avatarUrl,
    this.challengesCompleted = 0,
    this.beautyCoins = 0,
    this.testedRecipes = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.MainColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient background from top to avatar
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.MainColor,
                    AppColors.MainColor2,
                  ],
                ),
              ),
            ),
            // Original content
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Stack(
                    children: [
                      _buildMainContent(context),
                      _buildAvatar(context),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                AppAssets.logo,
                width: 30,
                height: 30,
                errorBuilder: (context, _, __) {
                  return const Icon(
                    Icons.spa,
                    color: AppColors.MainColor,
                    size: 25,
                  );
                },
              ),
            ),
          ),
          const Text(
            "Profile",
            style: TextStyle(
              fontSize: 20,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu,
                color: AppColors.white,
                size: 38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Positioned(
      top: 25,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.MainColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 68,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : const AssetImage('assets/images/placeholder.png')
            as ImageProvider,
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildEditButton(context),
            const SizedBox(height: 15),
            _buildNameSection(),
            const SizedBox(height: 20),
            _buildAllergiesCard(),
            const SizedBox(height: 20),
            _buildStatisticsCard(),
            const SizedBox(height: 20),
            _buildHistoryButton(context),
            const SizedBox(height: 15),
            _buildEditProfileButton(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileEditView(
                profile: profile,
                avatarUrl: avatarUrl,
              ),
            ),
          );
        },
        child: Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            'assets/icons/edit.svg',
            color: AppColors.MainColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    final hasAge = profile.age != null &&
        profile.age.toString().trim().isNotEmpty &&
        profile.age.toString().toLowerCase() != 'null';

    return Column(
      children: [
        Text(
          '${profile.firstName} ${profile.lastName}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 👇 Show age only if it exists
            if (hasAge) ...[
              SvgPicture.asset(
                'assets/icons/birday.svg',
                color: AppColors.MainColor,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6),
              Text(
                '${profile.age} ans',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.greyMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 20),
            ],
            SvgPicture.asset(
              // 'assets/icons/${profile.skinType.toLowerCase()}.svg',
              'assets/icons/water.svg',

              color: AppColors.MainColor,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '${profile.skinType} Skin',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.greyMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAllergiesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.greyLight.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/dimond.svg',
                color: AppColors.MainColor,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'My Allergies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          profile.allergyTypes.isEmpty
              ? Text(
            'No allergies',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.greyMedium,
            ),
          )
              : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.allergyTypes.map((allergy) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.MainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.MainColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  allergy,
                  style: const TextStyle(
                    color: AppColors.MainColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.greyLight.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/chart.svg',
                color: AppColors.MainColor,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'My Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// 🔢 Statistics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'assets/icons/defis.svg',
                'Challenge\ncompleted',
                '$challengesCompleted',
              ),
              _buildStatItem(
                'assets/icons/dimond.svg',
                'Beauty\ncoins',
                '$beautyCoins',
              ),
              _buildStatItem(
                'assets/icons/task.svg',
                'tested\nrecipes',
                '$testedRecipes',
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// 🎖️ BADGE SECTION TITLE
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/badge.svg',
                color: AppColors.MainColor,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'My Badges',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 🎖️ ENHANCED BADGES SLIDER with PageView (Swipe one-by-one)
          SizedBox(
            height: 170,
            child: PageView.builder(
              controller: PageController(
                viewportFraction: 0.88, // Shows part of next card
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildBadgeCard(badge),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String svgPath, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.MainColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              svgPath,
              color: AppColors.MainColor,
              width: 32,
              height: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.greyDark,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.MainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHistoryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to history
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: AppColors.greyLight.withOpacity(0.3),
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/history.svg',
              color: AppColors.black,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              "View my history",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileEditView(
                profile: profile,
                avatarUrl: avatarUrl,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.MainColor,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/edit.svg',
              color: AppColors.white,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              "Edit my profile",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(BadgeItem badge) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.MainColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // <-- vertical centering
        crossAxisAlignment: CrossAxisAlignment.start, // still align text to start horizontally
        children: [
          Row(
            children: [
              SvgPicture.asset(
                badge.icon,
                color: AppColors.MainColor,
                width: 25,
                height: 25,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  badge.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.MainColor2,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Text(
            badge.description,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.greyDark,
            ),
          ),

          SizedBox(height: 10),

          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/book.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6),
              Text(
                '${badge.associatedRecipes} recettes associées',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.greyMedium,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // smaller padding
                decoration: BoxDecoration(
                  color: AppColors.Hover,
                  borderRadius: BorderRadius.circular(6), // smaller radius
                  border: Border.all(
                    color: AppColors.MainColor,
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Détails',
                  style: TextStyle(
                    fontSize: 12, // optional: smaller text
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            ],
          )
        ],
      ),
    );
  }
}