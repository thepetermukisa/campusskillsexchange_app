import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  XFile? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      String? imageUrl = widget.user.profileImageUrl;

      if (_imageFile != null) {
        final uploadedUrl = await FirebaseService().uploadImage(_imageFile!, 'profile_images/${widget.user.id}.jpg');
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          throw Exception('Failed to upload image. Please check your connection or try again later.');
        }
      }

      await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        if (imageUrl != null) 'profileImageUrl': imageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark ? AppTheme.surfaceElevated : const Color(0xFFEFF6F5),
                          backgroundImage: _imageFile != null
                              ? (kIsWeb ? NetworkImage(_imageFile!.path) : FileImage(io.File(_imageFile!.path))) as ImageProvider
                              : (widget.user.profileImageUrl != null && widget.user.profileImageUrl!.isNotEmpty)
                                  ? NetworkImage(widget.user.profileImageUrl!)
                                  : null,
                          child: (_imageFile == null && (widget.user.profileImageUrl == null || widget.user.profileImageUrl!.isEmpty))
                              ? Text(
                                  widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
                                  style: TextStyle(fontSize: 40, color: AppTheme.accent, fontWeight: FontWeight.w700),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      filled: true,
                      fillColor: isDark ? AppTheme.surfaceElevated : const Color(0xFFF0F4F8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg), borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself...',
                      filled: true,
                      fillColor: isDark ? AppTheme.surfaceElevated : const Color(0xFFF0F4F8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg), borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
                      ),
                      child: Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
