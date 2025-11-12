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
  int _age = 0;

  List<String> selectedAllergies = [];
  final List<String> allergyOptions = ["Gluten", "Pollen", "Dust", "Nut", "Milk", "Pet Dander"];
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
        child: Column(
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
                size: 24,
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
      top: 25,
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
              children: [
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
                  child: CircleAvatar(
                    radius: 58,
                    backgroundImage: _avatarImageXFile != null
                        ? (kIsWeb
                        ? NetworkImage(_avatarImageXFile!.path)
                        : FileImage(_avatarImageFile!) as ImageProvider)
                        : (_avatarUrl != null
                        ? NetworkImage(_avatarUrl!)
                        : const AssetImage("assets/images/placeholder.png")),
                  ),
                ),
                // Improved hover/edit overlay
                AnimatedOpacity(
                  opacity: _isAvatarHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.greyLight.withOpacity(0.95),
                          AppColors.greyLight.withOpacity(0.95),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
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
      margin: const EdgeInsets.only(top: 85),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            const SizedBox(height: 45),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
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
          _textField("Prénom", _firstName),
          const SizedBox(height: 16),
          _textField("Nom", _lastName),
          const SizedBox(height: 16),
          _buildAgeField(),
        ],
      ),
    );
  }

  Widget _buildAgeField() {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.greyLight.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyLight.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 34,
                width: 34,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.MainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: AppColors.MainColor,
                      size: 18,
                    ),
                  ),
                  onPressed: () {
                    if (_age > 1) setState(() => _age--);
                  },
                ),
              ),
              Text(
                '$_age ans',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              SizedBox(
                height: 34,
                width: 34,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.MainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.MainColor,
                      size: 18,
                    ),
                  ),
                  onPressed: () {
                    if (_age < 120) setState(() => _age++);
                  },
                ),
              ),
            ],
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
          _title("Types De Peau"),
          const SizedBox(height: 8),
          const Text(
            "Sélectionner votre peau",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.greyMedium,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: skinTypes.entries.map((entry) {
              final type = entry.key;
              final svgPath = entry.value;
              final bool selected = _skinType == type;

              return GestureDetector(
                onTap: () => setState(() => _skinType = type),
                child: Container(
                  width: 82,
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.MainColor : AppColors.greyLight.withOpacity(0.3),
                      width: selected ? 2 : 1,
                    ),
                    color: selected ? AppColors.MainColor.withOpacity(0.05) : AppColors.white,
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
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 7,
                          color: selected ? AppColors.MainColor : AppColors.greyDark,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
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
            "Vos Allergies",
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
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.MainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.MainColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item,
                        style: const TextStyle(
                          color: AppColors.MainColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => selectedAllergies.remove(item)),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.MainColor,
                        ),
                      ),
                    ],
                  ),
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
              if (label == "Prénom") _firstName = v;
              if (label == "Nom") _lastName = v;
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
          TextField(
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
              hintText: "Ajouter une allergie",
              hintStyle: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
              ),
              suffixIcon: const Icon(
                Icons.search,
                color: AppColors.white,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.MainColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
            ),
          ),

          // List of filtered allergies with animation
          if (_isSearchFocused && filteredOptions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                color: AppColors.MainColor.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filteredOptions.length,
                itemBuilder: (context, index) {
                  final allergy = filteredOptions[index];
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
                },
              ),
            ),
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
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                // Background container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "• ${widget.allergy}",
                    style: TextStyle(
                      color: _isPressed ? AppColors.MainColor : AppColors.white,
                      fontSize: 14,
                      fontWeight: _isPressed ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                // Animated fill overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _animation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.Hover,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Text on top
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    "• ${widget.allergy}",
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