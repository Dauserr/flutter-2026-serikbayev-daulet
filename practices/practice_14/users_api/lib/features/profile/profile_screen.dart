import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _prefs = SharedPreferencesAsync();
  final _picker = ImagePicker();

  File? _avatar;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final path = await _prefs.getString('avatarPath');

    if (path == null) return;

    final file = File(path);
    final exists = await file.exists();

    if (!mounted || !exists) return;

    setState(() {
      _avatar = file;
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Camera permission blocked'),
        content: const Text(
          'The camera is blocked for this app. Open settings and allow '
          'camera access to take a photo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );

    if (open == true) {
      await openAppSettings();
    }
  }

  Future<void> _pick(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();

      if (!mounted) return;

      switch (status) {
        case PermissionStatus.granted:
          break;
        case PermissionStatus.denied:
          _snack('Camera access was denied.');
          return;
        case PermissionStatus.permanentlyDenied:
          await _showSettingsDialog();
          return;
        case PermissionStatus.restricted:
        case PermissionStatus.limited:
        case PermissionStatus.provisional:
          _snack('Camera access is not available.');
          return;
      }
    }

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (picked == null || !mounted) return;

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/avatar.jpg');

    await picked.saveTo(file.path);
    await _prefs.setString('avatarPath', file.path);

    if (!mounted) return;

    setState(() {
      _avatar = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _avatar;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile photo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: avatar == null ? null : FileImage(avatar),
              child: avatar == null ? const Icon(Icons.person, size: 64) : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose photo'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pick(ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Take photo'),
            ),
          ],
        ),
      ),
    );
  }
}
