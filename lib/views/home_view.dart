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
          _buildBackgroundDecorations(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const CustomTopBar(), // uses topBar style
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),

                        // 🟩 Titre 1
                        Text(
                          "HOW IT WORKS",
                          style: AppTextStyles.title1,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 50),

                        // 🟩 Étapes
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
                          description:
                          "Receive personalized\nskincare advice",
                          icon: Icons.check_circle_outline,
                        ),

                        const SizedBox(height: 60),

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

  // === Background ===
  Widget _buildBackgroundDecorations() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        return Stack(
          children: [
            Positioned(
              top: 60,
              right: -40,
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
            Positioned(
              bottom: 80,
              left: 20,
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

  // === Bouton ===
  Widget _buildCTAButton(BuildContext context) {
    final ImagePicker _picker = ImagePicker();

    Future<void> _pickImage(ImageSource source) async {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) print('Selected image path: ${image.path}');
    }

    void _showImageSourceSheet() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: SizedBox(
        height: 45,
        child: ElevatedButton(
          onPressed: _showImageSourceSheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding:
            const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
          ),
          child: Text(
            "Take a photo",
            style: AppTextStyles.topBar.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// === Étape ===
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
        Text(title, style: AppTextStyles.title2, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(description, style: AppTextStyles.body, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Icon(icon, color: AppColors.black, size: 48),

      ],
    );
  }
}
