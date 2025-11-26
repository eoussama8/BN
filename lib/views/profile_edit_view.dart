import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import '../presenters/profile_presenter.dart';
import '../utils/constants.dart';

class ProfileEditView extends StatefulWidget {
  final Profile profile;
  final String? avatarUrl;

  const ProfileEditView({Key? key, required this.profile, this.avatarUrl}) : super(key: key);

  @override
  _ProfileEditViewState createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> implements ProfileViewContract {
  late ProfilePresenter _presenter;

  File? _avatarImageFile;
  XFile? _avatarImageXFile;
  String _firstName = "";
  String _lastName = "";
  String? _avatarUrl;

  String _skinType = "";
  int? _age;

  List<String> selectedAllergies = [];
  final List<String> allergyOptions = [
    // Food allergies
    "Milk",
    "Eggs",
    "Peanuts",
    "Tree Nuts",
    "Soy",
    "Wheat (Gluten)",
    "Fish",
    "Shellfish",
    "Sesame",
    "Celery",
    "Mustard",
    "Lupin",
    "Sulfites",

    // Environmental allergies
    "Pollen",
    "Dust Mites",
    "Mold",
    "Pet Dander",
    "Insect Stings",
    "Chemical Products",

    // Contact skin allergies
    "Nickel",
    "Latex",
    "Fragrances",
    "Preservatives",
    "Colorants",
    "Metals",
    "Resins",

    // Other allergies
    "Medications",
    "Feathers",
  ];
  String _allergySearchQuery = "";
  bool _isSearchFocused = false;

  bool _isSaving = false;
  bool _isAvatarHovered = false;

  @override
  void initState() {
    super.initState();
    _presenter = ProfilePresenter(this);

    final profile = widget.profile;
    _firstName = profile.firstName;
    _lastName = profile.lastName;
    _skinType = profile.skinType;
    _age = profile.age;
    selectedAllergies = List.from(profile.allergyTypes);
    _avatarUrl = widget.avatarUrl;
  }

  // ---------- Presenter Implements ----------
  @override
  void showError(String message) => _showSnackBar(message, AppColors.red);

  @override
  void showSuccess(String message) => _showSnackBar(message, Colors.green);

  @override
  void showLoading(bool isLoading) => setState(() => _isSaving = isLoading);

  @override
  void updateProfileExistsState(bool exists) {}

  @override
  void showProfile(Profile profile, String? avatarUrl) {}

  // ---------- Pick Image ----------
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _presenter.pickImageFromGallery();
    if (pickedFile != null) {
      setState(() {
        _avatarImageXFile = pickedFile;
        if (!kIsWeb) _avatarImageFile = File(pickedFile.path);
      });
    }
  }

  // ---------- Save ----------
  void _onSaveChanges() async {
    final updatedProfile = Profile(
      userId: widget.profile.userId,
      firstName: _firstName,
      lastName: _lastName,
      skinType: _skinType,
      age: _age,
      allergyTypes: List.from(selectedAllergies),
    );

    final success = await _presenter.updateProfile(
      profile: updatedProfile,
      avatarXFile: _avatarImageXFile,
      avatarFile: _avatarImageFile,
    );

    if (success && mounted) {
      Navigator.pop(context, updatedProfile);
    }
  }

  // ---------- Snackbar ----------
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------- Build ----------
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
                _buildHeader(),
                Expanded(
                  child: Stack(
                    children: [
                      _buildMainContent(),
                      _buildAvatar(),
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
  // ---------- Header ----------
  Widget _buildHeader() {
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
            "Edit Profile",
            style: TextStyle(
              fontSize: 20,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => _showSnackBar("Menu tapped", AppColors.greyDark),
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

  // ---------- Floating Avatar ----------
  Widget _buildAvatar() {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _pickImageFromGallery,
          onTapDown: isMobile ? (_) => setState(() => _isAvatarHovered = true) : null,
          onTapUp: isMobile ? (_) => setState(() => _isAvatarHovered = false) : null,
          onTapCancel: isMobile ? () => setState(() => _isAvatarHovered = false) : null,
          child: MouseRegion(
            onEnter: !isMobile ? (_) => setState(() => _isAvatarHovered = true) : null,
            onExit: !isMobile ? (_) => setState(() => _isAvatarHovered = false) : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Border container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.MainColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),

                // CircleAvatar with image or SVG
                CircleAvatar(
                  radius: 58,
                  backgroundColor: AppColors.Hover,
                  child: ClipOval(
                    child: _avatarImageXFile != null
                        ? (kIsWeb
                        ? Image.network(
                      _avatarImageXFile!.path,
                      width: 116,
                      height: 116,
                      fit: BoxFit.cover,
                    )
                        : Image.file(
                      _avatarImageFile!,
                      width: 116,
                      height: 116,
                      fit: BoxFit.cover,
                    ))
                        : (_avatarUrl != null
                        ? Image.network(
                      _avatarUrl!,
                      width: 116,
                      height: 116,
                      fit: BoxFit.cover,
                    )
                        : SvgPicture.asset(
                      'assets/icons/edit_ava.svg',
                      width: 28,
                      height: 28,
                      color: AppColors.MainColor,
                    )),
                  ),
                ),

                // Hover overlay (slightly smaller so border is visible)
                AnimatedOpacity(
                  opacity: _isAvatarHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    width: 116, // slightly smaller than border
                    height: 116,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.Hover.withOpacity(0.4), // semi-transparent overlay
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/edit_ava.svg',
                        width: 28,
                        height: 28,
                        color: AppColors.MainColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Main Content ----------
  Widget _buildMainContent() {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
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
            // Remove extra SizedBox and grey background
            Align(
              alignment: Alignment.topLeft, // ensure it's at the top
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.black,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(height: 25), // spacing after back arrow
            _buildPersonalDetailsCard(),
            const SizedBox(height: 25),
            _buildSkinTypeCard(),
            const SizedBox(height: 25),
            _buildAllergiesCard(),
            const SizedBox(height: 30),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ---------- Cards ----------
  Widget _buildPersonalDetailsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Personal Details"),
          const SizedBox(height: 16),
          _textField("First Name", _firstName),
          const SizedBox(height: 16),
          _textField("Last Name", _lastName),
          const SizedBox(height: 16),
          _buildAgeField(),
        ],
      ),
    );
  }

  Widget _buildAgeField() {
    final controller = TextEditingController(text: _age?.toString() ?? "");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Age",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.greyLight.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyLight.withOpacity(0.2)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter your age",
              hintStyle: TextStyle(
                color: AppColors.greyLight.withOpacity(0.6),
                fontSize: 14,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null && parsed >= 0 && parsed <= 120) {
                _age = parsed;
              } else {
                _age = null;
              }
            },
          ),
        ),
      ],
    );
  }


  Widget _buildSkinTypeCard() {
    final skinTypes = {
      "Normal": "assets/icons/normal.svg",
      "Dry": "assets/icons/dry.svg",
      "Oily": "assets/icons/oily.svg",
      "Sensitive": "assets/icons/sensitive.svg",
      "Combination": "assets/icons/combination.svg",
    };

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Skin Types"),
          const SizedBox(height: 8),
          const Text(
            "Select your skin",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.greyMedium,
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;
              final double itemWidth = (availableWidth - 24) / 3;
              // 24 = spacing(12) * 2

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: skinTypes.entries.map((entry) {
                  final type = entry.key;
                  final svgPath = entry.value;
                  final bool selected = _skinType == type;

                  return GestureDetector(
                    onTap: () => setState(() => _skinType = type),
                    child: Container(
                      width: itemWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      constraints: const BoxConstraints(minHeight: 110),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.MainColor
                              : AppColors.greyLight.withOpacity(0.3),
                          width: selected ? 2 : 1,
                        ),
                        color: selected
                            ? AppColors.MainColor.withOpacity(0.05)
                            : AppColors.white,
                      ),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            svgPath,
                            width: 40,
                            height: 40,
                            color: selected ? AppColors.MainColor : AppColors.greyMedium,
                          ),
                          const SizedBox(height: 10),

                          FittedBox(
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 12,
                                color: selected
                                    ? AppColors.MainColor
                                    : AppColors.greyDark,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );

  }


  Widget _buildAllergiesCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Allergies"),
          const SizedBox(height: 8),
          const Text(
            "Your Allergies",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.greyMedium,
            ),
          ),
          const SizedBox(height: 12),
          if (selectedAllergies.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedAllergies.map((item) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.MainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: AppColors.MainColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () => setState(() => selectedAllergies.remove(item)),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: AppColors.MainColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          if (selectedAllergies.isNotEmpty) const SizedBox(height: 16),
          _buildAllergySearchBox(),
        ],
      ),
    );
  }
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.greyLight.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }

  Widget _textField(String label, String value) {
    final controller = TextEditingController(text: value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.greyLight.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyLight.withOpacity(0.2)),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: TextStyle(
                color: AppColors.greyLight.withOpacity(0.6),
                fontSize: 14,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (v) {
              if (label == "First Name") _firstName = v;
              if (label == "Last Name") _lastName = v;
            },
          ),
        ),
      ],
    );
  }




  Widget _buildAllergySearchBox() {
    final filteredOptions = allergyOptions
        .where((a) =>
    !selectedAllergies.contains(a) &&
        a.toLowerCase().contains(_allergySearchQuery.toLowerCase()))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.MainColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _allergySearchQuery = value;
                  _isSearchFocused = true;
                });
              },
              onTap: () {
                setState(() => _isSearchFocused = true);
              },
              decoration: InputDecoration(
                hintText: "Add an allergy",
                hintStyle: TextStyle(
                  color: AppColors.greyMedium.withOpacity(0.8),
                  fontSize: 14,
                ),
                suffixIcon: const Icon(
                  Icons.search,
                  color: AppColors.MainColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 14,
              ),
            ),
          ),

          // Show filtered options with animation
          if (_isSearchFocused && filteredOptions.isNotEmpty)
            ...filteredOptions.map((allergy) {
              return _AllergyListItem(
                allergy: allergy,
                onTap: () {
                  setState(() {
                    selectedAllergies.add(allergy);
                    _allergySearchQuery = "";
                    _isSearchFocused = false;
                  });
                },
              );
            }).toList(),

          if (_isSearchFocused) const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _onSaveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.MainColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Save Changes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}


// Animated allergy list item widget
class _AllergyListItem extends StatefulWidget {
  final String allergy;
  final VoidCallback onTap;

  const _AllergyListItem({
    required this.allergy,
    required this.onTap,
  });

  @override
  State<_AllergyListItem> createState() => _AllergyListItemState();
}

class _AllergyListItemState extends State<_AllergyListItem> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: Container(
        width: double.infinity,                // 🔥 make it full width
        alignment: Alignment.centerLeft,       // 🔥 align content to the left
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                // Background container (full width)
                Container(
                  width: double.infinity,      // 🔥 full width
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.centerLeft, // 🔥 text left
                  child: Text(
                    "+ ${widget.allergy}",
                    textAlign: TextAlign.left,    // 🔥 ensure left
                    style: TextStyle(
                      color: _isPressed ? AppColors.MainColor : AppColors.white,
                      fontSize: 14,
                      fontWeight: _isPressed ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),

                // Animated overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _animation.value,
                        child: Container(
                          color: AppColors.Hover,
                        ),
                      ),
                    ),
                  ),
                ),

                // Top text (full width)
                Container(
                  width: double.infinity,          // 🔥 full width
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  alignment: Alignment.centerLeft,  // 🔥 left
                  child: Text(
                    "+ ${widget.allergy}",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: _isPressed ? AppColors.MainColor : AppColors.white,
                      fontSize: 14,
                      fontWeight: _isPressed ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}