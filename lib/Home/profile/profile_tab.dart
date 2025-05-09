import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:absent_detector/Home/About/about_page.dart';
import 'package:absent_detector/Home/About/help_page.dart';
import 'package:absent_detector/Login/screens/login_panel.dart';

class ProfileTab extends StatefulWidget {
  final String token; // Pass the token that identifies the logged-in user
  final String teacherName;
  final String teacherEmail;
  final String teacherRole;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.token,
    required this.teacherName,
    required this.teacherEmail,
    required this.teacherRole,
    required this.onLogout,
  });

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  static const String _profileImageKey = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_profileImageKey);
    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _saveProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImageKey, imagePath);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      bool hasPermission = false;
      
      if (source == ImageSource.gallery) {
        if (Platform.isAndroid) {
          // For Android 13 and above
          if (await Permission.photos.status.isGranted) {
            hasPermission = true;
          } else {
            hasPermission = await _requestPermission(Permission.photos);
          }
        } else {
          hasPermission = await _requestPermission(Permission.photos);
        }
      } else if (source == ImageSource.camera) {
        hasPermission = await _requestPermission(Permission.camera);
      }

      if (!hasPermission) {
        _showPermissionDeniedDialog(source == ImageSource.gallery ? 'Photo Library' : 'Camera');
        return;
      }

      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 500,
          maxHeight: 500,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          final File imageFile = File(pickedFile.path);
          if (await imageFile.exists()) {
            setState(() {
              _profileImage = imageFile;
            });
            await _saveProfileImage(pickedFile.path);
          } else {
            throw Exception('Selected image file does not exist');
          }
        }
      } catch (e) {
        debugPrint('Error picking image: $e');
        _showErrorDialog('Failed to pick image: ${e.toString()}');
      }
    } catch (e) {
      debugPrint('Error in permission handling: $e');
      _showErrorDialog('Error accessing ${source == ImageSource.gallery ? 'gallery' : 'camera'}: ${e.toString()}');
    }
  }

  void _showPermissionDeniedDialog(String permission) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Permission Required'),
        content: Text('This app needs access to $permission to set your profile picture. Please grant permission in your device settings.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Open Settings'),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _removeProfileImage() async {
    if (_profileImage != null) {
      try {
        await _profileImage!.delete();
      } catch (e) {
        debugPrint('Error deleting image file: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileImageKey);
    setState(() {
      _profileImage = null;
    });
  }

  void _showImagePickerOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Choose Profile Picture'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.camera),
                SizedBox(width: 8),
                Text('Take Photo'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo),
                SizedBox(width: 8),
                Text('Choose from Gallery'),
              ],
            ),
          ),
          if (_profileImage != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                _removeProfileImage();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.delete),
                  SizedBox(width: 8),
                  Text('Remove Photo'),
                ],
              ),
            ),
        ],
        cancelButton: CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('ProfileTab - Name: ${widget.teacherName}, Email: ${widget.teacherEmail}, Role: ${widget.teacherRole}');
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      child: ListView(
        children: [
          Container(
            color: CupertinoColors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0084FF).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                CupertinoIcons.person_fill,
                                size: 50,
                                color: Color(0xFF0084FF),
                              ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0084FF),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CupertinoColors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.pencil,
                            size: 16,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.teacherName.isNotEmpty)
                  Text(
                    widget.teacherName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                if (widget.teacherEmail.isNotEmpty)
                  Text(
                    widget.teacherEmail,
                    style: const TextStyle(color: CupertinoColors.systemGrey),
                  ),
                if (widget.teacherRole.isNotEmpty)
                  Text(
                    widget.teacherRole,
                    style: const TextStyle(color: CupertinoColors.systemGrey2, fontSize: 13),
                  ),
                const SizedBox(height: 16),
                CupertinoButton(
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.pencil),
                      SizedBox(width: 8),
                      Text('Edit Profile Picture'),
                    ],
                  ),
                  onPressed: _showImagePickerOptions,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildProfileSection([
            _buildProfileTile(
              context,
              icon: CupertinoIcons.info_circle_fill,
              iconColor: const Color(0xFF0084FF),
              title: 'About',
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const AboutPage()),
              ),
            ),
            _buildProfileTile(
              context,
              icon: CupertinoIcons.question_circle_fill,
              iconColor: const Color(0xFF0084FF),
              title: 'Help',
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const HelpPage()),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _buildProfileSection([
            _buildProfileTile(
              context,
              icon: CupertinoIcons.power,
              iconColor: CupertinoColors.systemRed,
              title: 'Log Out',
              showChevron: false,
              onTap: () {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: Text('Log Out'),
                    content: Text('Are you sure you want to log out?'),
                    actions: [
                      CupertinoDialogAction(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        child: Text('Log Out'),
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          widget.onLogout();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Attendance App v1.0',
              style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: children),
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    bool showChevron = true,
    VoidCallback? onTap,
  }) {
    return CupertinoListTile(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: showChevron
          ? const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey3,
            )
          : null,
    );
  }

  Future<bool> _requestPermission(Permission permission) async {
    try {
      if (Platform.isAndroid) {
        if (permission == Permission.photos) {
          // For Android 13 and above
          if (await Permission.storage.status.isDenied) {
            final result = await Permission.storage.request();
            if (!result.isGranted) {
              return false;
            }
          }
          return true;
        }
      }
      
      final status = await permission.status;
      if (status.isGranted) {
        return true;
      }

      final result = await permission.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }
}
