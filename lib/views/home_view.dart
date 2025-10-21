import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/constants.dart';
import '../widgets/top_bar.dart';
import '../utils/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Background decorations
          _buildBackgroundDecorations(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const CustomTopBar(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),

                        // Title
                        Text(
                          "HOW IT WORKS",
                          style: AppTextStyles.title.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                            color: AppColors.black,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 50),

                        // Steps
                        const _StepSection(
                          title: "TAKE A PICTURE",
                          description: "Snap a photo of\nyour skin",
                          icon: Icons.photo_camera_outlined,
                        ),
                        const SizedBox(height: 50),

                        const _StepSection(
                          title: "ANALYSE",
                          description: "Get an analysis of\nyour skin",
                          icon: Icons.sync_outlined,
                        ),
                        const SizedBox(height: 50),

                        const _StepSection(
                          title: "RECOMMENDATIONS",
                          description: "Receive personalized\nskincare advice",
                          icon: Icons.check_circle_outline,
                        ),

                        const SizedBox(height: 60),

                        // CTA Button
                        _buildCTAButton(context),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Stack(
          children: [
            // Main background SVG - 70% height, 60% width - aligned to right with padding
            Positioned(
              top: 25, // padding from top
              right: -50, // padding from right
              child: Opacity(
                opacity: 0.4,
                child: SvgPicture.asset(
                  AppAssets.background,
                  width: screenWidth * 0.6,
                  height: screenHeight * 0.7,
                  fit: BoxFit.fill,
                  alignment: Alignment.topRight,
                ),
              ),
            ),

            // Bottom left background SVG with padding
            Positioned(
              bottom: 80, // padding from bottom
              left: 20, // padding from left
              child: Opacity(
                opacity: 0.4,
                child: SvgPicture.asset(
                  AppAssets.background2,
                  width: screenWidth * 0.07,
                  height: screenHeight * 0.07,
                  fit: BoxFit.fill,
                  alignment: Alignment.bottomLeft,
                ),
              ),
            ),


          ],
        );
      },
    );
  }


  Widget _buildCTAButton(BuildContext context) {
    final ImagePicker _picker = ImagePicker();

    Future<void> _pickImage(ImageSource source) async {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        // Handle the picked image
        print('Selected image path: ${image.path}');
      }
    }

    void _showImageSourceSheet() {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Center(
      child: SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: _showImageSourceSheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green2,
            foregroundColor: AppColors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
          ),
          child: Text(
            "Take a photo",
            style: AppTextStyles.button.copyWith(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// Steps widget
class _StepSection extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _StepSection({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Text(
          title,
          style: AppTextStyles.subtitle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.black,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        // Description
        Text(
          description,
          style: AppTextStyles.subtitle.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: AppColors.greyMedium,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Icon (plain, no background or border)
        Icon(
          icon,
          color: AppColors.greyDark,
          size: 28,
        ),
      ],
    );
  }
}
