import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quiz.dart';
import '../services/gemini_quiz_service.dart';

class SkillTestScreen extends StatefulWidget {
  static const routeName = '/skill-test';

  final String skillId;
  final String skillName;
  final String category;

  const SkillTestScreen({
    Key? key,
    required this.skillId,
    required this.skillName,
    required this.category,
  }) : super(key: key);

  @override
  _SkillTestScreenState createState() => _SkillTestScreenState();
}

class _SkillTestScreenState extends State<SkillTestScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  Quiz? _quiz;
  bool _isLoading = true;
  String? _errorMessage;

  int _currentQuestionIndex = 0;
  int _score = 0;
  Map<String, int> _answers = {};

  int? _selectedOptionIndex;
  bool _answerRevealed = false;

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _cardController;
  late Animation<double> _cardSlide;
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  // ── Theme colours ──────────────────────────────────────────────────────────
  static const _primary = Color(0xFFFF6B6B);
  static const _surface = Color(0xFF1E1E1E);

  // ──────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _cardSlide =
        CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController);

    _loadQuiz();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Data loading ───────────────────────────────────────────────────────────
  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final quiz = await GeminiQuizService.generateQuiz(
        skillId: widget.skillId,
        skillName: widget.skillName,
        category: widget.category,
      );
      _setQuiz(quiz);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString()
              .replaceFirst('Exception: ', '')
              .replaceFirst('GeminiQuizException: ', '');
        });
      }
    }
  }

  void _setQuiz(Quiz quiz) {
    if (!mounted) return;
    setState(() {
      _quiz = quiz;
      _isLoading = false;
      _currentQuestionIndex = 0;
      _score = 0;
      _answers = {};
      _selectedOptionIndex = null;
      _answerRevealed = false;
    });
    _cardController.forward(from: 0);
  }

  // ── Quiz logic ─────────────────────────────────────────────────────────────
  void _selectOption(int idx) {
    if (_answerRevealed) return;

    final question = _quiz!.questions[_currentQuestionIndex];
    final bool correct = idx == question.correctOptionIndex;

    setState(() {
      _selectedOptionIndex = idx;
      _answerRevealed = true;
      if (correct) _score++;
      _answers[question.id] = idx;
    });

    Future.delayed(const Duration(milliseconds: 900), _advance);
  }

  void _advance() {
    if (!mounted) return;
    final quiz = _quiz!;
    if (_currentQuestionIndex < quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _answerRevealed = false;
      });
      _cardController.forward(from: 0);
    } else {
      final finalScore = (_score / quiz.questions.length) * 100;

      // Optionally save the attempt to Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // Fire-and-forget — do not await to keep UX snappy
        _saveAttempt(uid, quiz.id, finalScore);
      }

      Navigator.of(context).pop(finalScore);
    }
  }

  /// Persists a quiz attempt to Firestore so the admin 'Approve Quizzes'
  /// screen has data to review.
  Future<void> _saveAttempt(
      String uid, String quizId, double score) async {
    try {
      await FirebaseFirestore.instance.collection('quiz_results').add({
        'userId': uid,
        'skillId': widget.skillId,
        'skillName': widget.skillName,
        'quizId': quizId,
        // Store as integer percentage (0-100) to match ApproveQuizzesScreen's
        // `score as int? ?? 0` cast and the `score >= 60` pass threshold.
        'score': score.round(),
        'passed': score >= 60,
        'status': 'pending', // pending | approved | discarded
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Non-critical — the quiz result is still returned to the caller.
      debugPrint('Failed to save quiz attempt: $e');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.skillName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading && _quiz != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(child: _AiBadge()),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildQuizBody(),
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Opacity(
                opacity: _pulse.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [_primary, Color(0xFFFF9A8B)]),
                    boxShadow: [
                      BoxShadow(
                          color: _primary.withOpacity(0.5),
                          blurRadius: 24,
                          spreadRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 36),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Generating your quiz with AI…',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Gemini is crafting fresh questions\njust for ${widget.skillName}',
              style:
                  TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                color: Colors.white.withOpacity(0.4), size: 56),
            const SizedBox(height: 20),
            const Text('Could not generate quiz',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(_errorMessage!,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _loadQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quiz body ──────────────────────────────────────────────────────────────
  Widget _buildQuizBody() {
    final quiz = _quiz!;
    final question = quiz.questions[_currentQuestionIndex];
    final total = quiz.questions.length;
    final progress = (_currentQuestionIndex + 1) / total;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Question ${_currentQuestionIndex + 1} of $total',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  Text(
                    'Score: $_score / ${_currentQuestionIndex + (_answerRevealed ? 1 : 0)}',
                    style: const TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(_primary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.12, 0),
              end: Offset.zero,
            ).animate(_cardSlide),
            child: FadeTransition(
              opacity: _cardSlide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Text(question.text,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.45),
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 20),
                    ...question.options.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final label = entry.value;
                      return _OptionTile(
                        index: idx,
                        label: label,
                        selectedIndex: _selectedOptionIndex,
                        correctIndex: question.correctOptionIndex,
                        revealed: _answerRevealed,
                        onTap: () => _selectOption(idx),
                      );
                    }).toList(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Option tile ──────────────────────────────────────────────────────────────
class _OptionTile extends StatelessWidget {
  final int index;
  final String label;
  final int? selectedIndex;
  final int correctIndex;
  final bool revealed;
  final VoidCallback onTap;

  const _OptionTile({
    required this.index,
    required this.label,
    required this.selectedIndex,
    required this.correctIndex,
    required this.revealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const correct = Color(0xFF4CAF50);
    const wrong = Color(0xFFEF5350);

    Color borderColor;
    Color bgColor;
    Color textColor;
    IconData? trailingIcon;

    if (!revealed) {
      borderColor = Colors.white12;
      bgColor = const Color(0xFF1E1E1E);
      textColor = Colors.white;
      trailingIcon = null;
    } else if (index == correctIndex) {
      borderColor = correct;
      bgColor = correct.withOpacity(0.15);
      textColor = correct;
      trailingIcon = Icons.check_circle_rounded;
    } else if (index == selectedIndex) {
      borderColor = wrong;
      bgColor = wrong.withOpacity(0.15);
      textColor = wrong;
      trailingIcon = Icons.cancel_rounded;
    } else {
      borderColor = Colors.white12;
      bgColor = const Color(0xFF1E1E1E);
      textColor = Colors.white38;
      trailingIcon = null;
    }

    final letters = ['A', 'B', 'C', 'D'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: revealed ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: revealed && index == correctIndex
                      ? correct.withOpacity(0.25)
                      : revealed && index == selectedIndex
                          ? wrong.withOpacity(0.25)
                          : Colors.white.withOpacity(0.08),
                ),
                child: Center(
                  child: Text(letters[index],
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: index == correctIndex && revealed
                            ? FontWeight.bold
                            : FontWeight.normal)),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, color: textColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AI badge ─────────────────────────────────────────────────────────────────
class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF9A8B)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 13, color: Colors.white),
          SizedBox(width: 4),
          Text('AI Quiz',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
