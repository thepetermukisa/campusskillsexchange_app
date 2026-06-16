import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/skill.dart';
import '../services/firebase_service.dart';
import './skill_test_screen.dart';
import './test_result_screen.dart';


class BecomeExpertScreen extends StatefulWidget {
  const BecomeExpertScreen({super.key});

  @override
  State<BecomeExpertScreen> createState() => _BecomeExpertScreenState();
}

class _BecomeExpertScreenState extends State<BecomeExpertScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _testPassed = false;
  bool _isUploading = false;

  // Form data
  String? _selectedCategory;
  String? _selectedSkill;
  final List<String> _portfolioUrls = [];
  String? _studentIdUrl;

  final List<String> _categories = [
    'Programming',
    'IT',
    'Design',
    'Multimedia',
    'Security',
  ];

  final Map<String, List<String>> _subSkillOptions = {
    'Programming': ['Flutter Development', 'Java Development'],
    'IT': ['Network Administration'],
    'Design': ['UI/UX Design'],
    'Multimedia': ['Video Editing'],
    'Security': ['Ethical Hacking'],
  };

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage(bool isPortfolio) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final path = isPortfolio 
          ? 'portfolios/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg'
          : 'verifications/${user.uid}.jpg';
      
      final url = await FirebaseService().uploadImage(image, path);
      
      if (url == null) throw 'Upload failed';
      
      setState(() {
        if (isPortfolio) {
          _portfolioUrls.add(url);
        } else {
          _studentIdUrl = url;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitApplication() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isUploading = true);

    try {
      // 1. Update user verification status
      await FirebaseService().updateUser(user.uid, {
        'isVerified': false, // Pending verification
        'studentIdUrl': _studentIdUrl,
      });

      // 2. Create the Skill record
      final skill = Skill(
        id: '', // Will be generated
        name: _selectedSkill!,
        description: 'Verified ${_selectedSkill} expert.',
        category: _selectedCategory!,
        userIds: [user.uid],
        instructorId: user.uid,
        instructorPhotoUrl: user.photoURL ?? 'https://i.pravatar.cc/150?u=${user.uid}',
        instructorName: user.displayName ?? 'Student Expert',
        rating: 5.0,
        reviews: 0,
        pricePerLesson: '50000',
        country: 'Uganda',
        flag: '🇺🇬',
        lessons: 0,
        experienceYears: 1,
        bio: 'I am a passionate ${_selectedSkill} expert.',
        tags: [_selectedCategory!, _selectedSkill!],
        coverImageUrl: _portfolioUrls.isNotEmpty ? _portfolioUrls[0] : '',
      );

      await FirebaseService().addSkill(skill.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted! We will review your ID.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become an Expert'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFCCCCCC),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentPage == 0
              ? () => Navigator.of(context).pop()
              : _prevPage,
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          _buildCategoryStep(
            categories: _categories,
            onSelect: (cat) => setState(() {
              _selectedCategory = cat;
              _selectedSkill = null;
              _testPassed = false;
            }),
            selected: _selectedCategory,
          ),
          _buildSubSkillsStep(
            options: _selectedCategory != null
                ? _subSkillOptions[_selectedCategory!]!
                : [],
            selectedSkill: _selectedSkill,
            onToggle: (skill) {
              setState(() {
                _selectedSkill = skill;
                _testPassed = false;
              });
            },
          ),
          _buildSkillTestStep(
            skillName: _selectedSkill,
            onTestPassed: (passed) {
              setState(() {
                _testPassed = passed;
              });
            },
            totalQuestions: 5, // Mock questions count
          ),
          _buildPortfolioStep(
            onAddPortfolio: () => _pickAndUploadImage(true),
            portfolioUrls: _portfolioUrls,
          ),
          _buildVerificationStep(
            onUploadId: () => _pickAndUploadImage(false),
            idUrl: _studentIdUrl,
          ),
          _buildReviewStep(
            category: _selectedCategory ?? '',
            subSkills: _selectedSkill != null ? [_selectedSkill!] : [],
            portfolioCount: _portfolioUrls.length,
            hasId: _studentIdUrl != null,
            onSubmit: _submitApplication,
          ),
        ],
      ),
      bottomNavigationBar: _currentPage == 5
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed:
                      (_currentPage == 0 && _selectedCategory == null) ||
                          (_currentPage == 1 && _selectedSkill == null) ||
                          (_currentPage == 2 && !_testPassed)
                      ? null
                      : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == 4 ? 'Submit for Verification' : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // Category Selection Step
  Widget _buildCategoryStep({
    required List<String> categories,
    required Function(String) onSelect,
    required String? selected,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Your Main Category',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ...categories.map(
            (cat) => Card(
              color: selected == cat
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFF1E1E1E),
              child: ListTile(
                title: Text(cat),
                trailing: selected == cat ? const Icon(Icons.check) : null,
                onTap: () => onSelect(cat),
                tileColor: selected == cat
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF1E1E1E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sub-skills Selection Step
  Widget _buildSubSkillsStep({
    required List<String> options,
    required String? selectedSkill,
    required Function(String) onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Your Sub-skill',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (skill) => FilterChip(
                    label: Text(skill),
                    selected: selectedSkill == skill,
                    onSelected: (isSelected) => onToggle(skill),
                    selectedColor: const Color(0xFFFF6B6B),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // Skill Test Step
  Widget _buildSkillTestStep({
    required String? skillName,
    required Function(bool) onTestPassed,
    required int totalQuestions,
  }) {
    if (skillName == null) {
      return const Center(child: Text('Please select a skill first.'));
    }

    // Use the skill name (slugged) as the ID — Gemini generates questions
    // dynamically so no static quiz lookup is required.
    final skillId = skillName.toLowerCase().replaceAll(' ', '_');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Skill Test: $skillName',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text('You need to pass a short AI-generated quiz to verify your skill.'),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              final score = await Navigator.of(context).push<double>(
                MaterialPageRoute(
                  builder: (ctx) => SkillTestScreen(
                    skillId: skillId,
                    skillName: skillName,
                    category: _selectedCategory ?? 'Unknown',
                  ),
                ),
              );
              if (!mounted) return;
              if (score != null) {
                onTestPassed(score >= 60);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => TestResultScreen(
                      score: score,
                      totalQuestions: totalQuestions,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            ),
            child: const Text('Take the Quiz', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  // Portfolio Step
  Widget _buildPortfolioStep({
    required VoidCallback onAddPortfolio,
    required List<String> portfolioUrls,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Portfolio Items',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Upload photos of your previous work'),
          const SizedBox(height: 24),
          if (_isUploading)
            const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
          else
            ElevatedButton.icon(
              onPressed: onAddPortfolio,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.1),
                foregroundColor: const Color(0xFFFF6B6B),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
            ),
          const SizedBox(height: 24),
          if (portfolioUrls.isNotEmpty)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: portfolioUrls.length,
                itemBuilder: (ctx, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(portfolioUrls[i], fit: BoxFit.cover),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Verification Step
  Widget _buildVerificationStep({
    required VoidCallback onUploadId,
    required String? idUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student ID Verification',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Upload a photo of your student ID for verification'),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isUploading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
                  : idUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(idUrl, fit: BoxFit.cover),
                        )
                      : const Icon(
                          Icons.badge_outlined,
                          size: 60,
                          color: Color(0xFFCCCCCC),
                        ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : onUploadId,
              label: Text(idUrl != null ? 'Change ID Photo' : 'Upload ID'),
              icon: const Icon(Icons.camera_alt),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Review Step
  Widget _buildReviewStep({
    required String category,
    required List<String> subSkills,
    required int portfolioCount,
    required bool hasId,
    required Function() onSubmit,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Your Application',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildInfoCard('Category', category),
          _buildInfoCard('Sub-skills', subSkills.join(', ')),
          _buildInfoCard('Portfolio Items', portfolioCount.toString()),
          _buildInfoCard('ID Uploaded', hasId ? 'Yes' : 'No'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('Submit for Verification'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Flexible(child: Text(value)),
          ],
        ),
      ),
    );
  }
}
