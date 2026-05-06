import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/quiz.dart';

/// Calls the Gemini API to generate quiz questions for a given skill.
///
/// Returns a [Quiz] object. If generation fails (network issue, bad response,
/// etc.) the caller should fall back to the static dummy quizzes.
class GeminiQuizService {
  // ──────────────────────────────────────────────────────────────────────────
  // 🔑  API KEY
  // Replace this with your actual Gemini API key.
  // Get one free at: https://aistudio.google.com/app/apikey
  // For production, load this from --dart-define or a secure store.
  // ──────────────────────────────────────────────────────────────────────────
  // Loaded from --dart-define=GEMINI_API_KEY=<your_key> at build/run time.
  // Never hardcode a real key here. See README for setup instructions.
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const int _questionCount = 5;

  /// Generates a quiz for [skillName] in [category].
  ///
  /// Throws a [GeminiQuizException] if generation fails so callers can
  /// distinguish AI errors from other exceptions and show the right UI.
  static Future<Quiz> generateQuiz({
    required String skillId,
    required String skillName,
    required String category,
  }) async {
    if (_apiKey.isEmpty) {
      debugPrint('GeminiQuizService: GEMINI_API_KEY is not configured!');
      throw GeminiQuizException(
        'GEMINI_API_KEY is not configured. '
        'Run with --dart-define=GEMINI_API_KEY=<your_key>',
      );
    }

    final model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: _apiKey,
      requestOptions: const RequestOptions(apiVersion: 'v1beta'),
    );

    final prompt = _buildPrompt(skillName, category);

    final response = await model.generateContent([Content.text(prompt)]);

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw GeminiQuizException('Gemini returned an empty response.');
    }

    return _parseResponse(text, skillId, skillName);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────────────────────────────────

  static String _buildPrompt(String skillName, String category) {
    return '''
You are a quiz generator for a campus skill-exchange platform.
Generate exactly $_questionCount multiple-choice questions about "$skillName" in the "$category" category.

CRITICAL: Respond ONLY with a valid JSON array. No markdown, no code blocks, no extra text.

The JSON must match this exact schema:
[
  {
    "question": "Question text here?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correct": 0
  }
]

Rules:
- Each question has exactly 4 options
- "correct" is the 0-based index of the correct option (0, 1, 2, or 3)
- Questions must be practical and suitable for university students
- Difficulty: beginner to intermediate
- Generate exactly $_questionCount questions
''';
  }

  static Quiz _parseResponse(String text, String skillId, String skillName) {
    // Strip any accidental markdown code fences
    String cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceFirst(RegExp(r'^```[a-z]*\n?'), '')
          .replaceFirst(RegExp(r'\n?```$'), '')
          .trim();
    }

    late final List<dynamic> jsonList;
    try {
      jsonList = jsonDecode(cleaned) as List<dynamic>;
    } catch (e) {
      throw GeminiQuizException('Failed to parse Gemini JSON response: $e\n\nRaw: $cleaned');
    }

    final questions = <Question>[];
    for (int i = 0; i < jsonList.length; i++) {
      final item = jsonList[i] as Map<String, dynamic>;

      final text = item['question'] as String? ?? '';
      final options = (item['options'] as List<dynamic>?)
              ?.map((o) => o.toString())
              .toList() ??
          [];
      final correct = item['correct'] as int? ?? 0;

      if (text.isEmpty || options.length != 4) continue;

      questions.add(Question(
        id: '${skillId}_ai_q$i',
        text: text,
        options: options,
        correctOptionIndex: correct.clamp(0, 3),
      ));
    }

    if (questions.isEmpty) {
      throw GeminiQuizException('Gemini returned 0 valid questions.');
    }

    return Quiz(
      id: '${skillId}_ai_quiz',
      skillId: skillId,
      title: '$skillName Quiz (AI Generated)',
      questions: questions,
    );
  }
}

class GeminiQuizException implements Exception {
  final String message;
  const GeminiQuizException(this.message);

  @override
  String toString() => 'GeminiQuizException: $message';
}
