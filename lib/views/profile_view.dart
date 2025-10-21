import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import '../presenters/profile_presenter.dart';
import '../utils/constants.dart';
import 'profile_summary_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    implements ProfileViewContract {
  late ProfilePresenter _presenter;

  // UI state
  File? _avatarImageFile;
  XFile? _avatarImageXFile;
  String? _userName;
  String? _avatarUrl;
  String _skinType = "Choose your skin type";
  String _allergyType = "Choose your allergy type";
  int _age = 18;
  bool _isSaving = false;
  bool _isExistingProfile = false;
  Profile? _profileData;

  @override
  void initState() {
    super.initState();
    _presenter = ProfilePresenter(this);
    _presenter.loadProfile();
  }

  // ========== ProfileViewContract ==========

  @override
  void showProfile(Profile profile, String? avatarUrl) {
    setState(() {
      _profileData = profile;
      _userName = profile.userId;
      _skinType = profile.skinType;
      _allergyType = profile.allergyType;
      _age = profile.age;
      _avatarUrl = avatarUrl;
      _isExistingProfile = true;
    });
  }

  @override
  void showError(String message) {
    _showSnackBar(message, AppColors.red);
  }

  @override
  void showSuccess(String message) {
    _showSnackBar(message, AppColors.greenDark);
  }

  @override
  void showLoading(bool isLoading) {
    setState(() => _isSaving = isLoading);
  }

  @override
  void updateProfileExistsState(bool exists) {
    setState(() => _isExistingProfile = exists);
  }

  // ========== Image Picker ==========

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _presenter.pickImageFromGallery();
    if (pickedFile != null) {
      setState(() {
        _avatarImageXFile = pickedFile;
        if (!kIsWeb) {
          _avatarImageFile = File(pickedFile.path);
        }
      });
    }
  }

  // ========== Save or Update ==========

  void _onSaveOrUpdate() async {
    final profile = Profile(
      userId: _userName ?? "default_user",
      skinType: _skinType,
      allergyType: _allergyType,
      age: _age,
    );

    if (_isExistingProfile) {
      await _presenter.updateProfile(
        profile: profile,
        avatarXFile: _avatarImageXFile,
        avatarFile: _avatarImageFile,
      );
    } else {
      await _presenter.saveProfile(
        profile: profile,
        avatarXFile: _avatarImageXFile,
        avatarFile: _avatarImageFile,
      );
    }

    setState(() {
      _profileData = profile;
      _isExistingProfile = true;
    });
  }

  // ========== SnackBar ==========

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: AppColors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ========== UI ==========

  @override
  Widget build(BuildContext context) {
    if (_isExistingProfile && _profileData != null) {
      return ProfileSummaryView(
        profile: _profileData!,
        avatarUrl: _avatarUrl,
      );
    }

    // ✅ Replace SafeArea + Column with this:
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.greenPastel,
      body: SafeArea(
        child: Container(
          color: AppColors.white, // 👈 SafeArea background
          child: SizedBox.expand(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildMainContent(),
                      _buildAvatarSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }

  Widget _buildHeader() {

    return Container(

      height: 80,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),

      child: Stack(
        alignment: Alignment.center,

        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              'Profile',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Menu tapped")),
                );
              },
              child: SvgPicture.asset(
                'assets/icons/menu.svg',
                width: 24,
                height: 24,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: AppColors.greenPastel,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.elliptical(40, 30),
          topRight: Radius.elliptical(40, 30),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'Hello, ${_userName ?? ''}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 40),
            _buildDropdownField(
              label: 'SKIN TYPE',
              value: _skinType,
              items: [
                "Choose your skin type",
                "Normal",
                "Dry",
                "Oily",
                "Combination"
              ],
              onChanged: (v) => setState(() => _skinType = v!),
            ),
            const SizedBox(height: 24),
            _buildDropdownField(
              label: 'ALLERGY TYPE',
              value: _allergyType,
              items: [
                "Choose your allergy type",
                "None",
                "Pollen",
                "Dust",
                "Food"
              ],
              onChanged: (v) => setState(() => _allergyType = v!),
            ),
            const SizedBox(height: 24),
            _buildAgeSelector(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.greenPastel,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: _avatarImageXFile != null
                    ? (kIsWeb
                    ? NetworkImage(_avatarImageXFile!.path)
                    : FileImage(_avatarImageFile!) as ImageProvider)
                    : (_avatarUrl != null
                    ? NetworkImage(_avatarUrl!)
                    : const AssetImage("assets/images/placeholder.png")),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImageFromGallery,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.greyDark,
                  child:
                  Icon(Icons.camera_alt, color: AppColors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AGE',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.black)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: AppColors.greyMedium),
                onPressed: () {
                  if (_age > 1) setState(() => _age--);
                },
              ),
              Text('$_age',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyDark)),
              IconButton(
                icon: Icon(Icons.add, color: AppColors.greyMedium),
                onPressed: () {
                  if (_age < 120) setState(() => _age++);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _onSaveOrUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greyDark,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSaving
            ? const SizedBox(
          height: 24,
          width: 24,
          child:
          CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download, color: AppColors.white),
            const SizedBox(width: 8),
            Text(
              _isExistingProfile ? 'Modify' : 'Save',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.black)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.greyMedium),
            style: TextStyle(color: AppColors.greyDark, fontSize: 14),
            onChanged: onChanged,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
