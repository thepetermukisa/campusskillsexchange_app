import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/skill.dart';
import '../models/service_request.dart';

class AIMatchmakingService {
  // Loaded from --dart-define=GEMINI_API_KEY=<your_key> at build/run time.
  // Never hardcode a real key here. See README for setup instructions.
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<List<String>> getMatches({
    required ServiceRequest request,
    required List<Skill> availableSkills,
  }) async {
    if (_apiKey.isEmpty) {
      debugPrint('AIMatchmakingService: GEMINI_API_KEY is not set. Pass --dart-define=GEMINI_API_KEY=<key> when running.');
      return [];
    }

    final model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: _apiKey,
      requestOptions: const RequestOptions(apiVersion: 'v1beta'),
    );

    final skillsPool = availableSkills.map((s) => {
      'id': s.id,
      'name': s.name,
      'category': s.category,
      'instructor': s.instructorName,
      'bio': s.bio,
    }).toList();

    final prompt = '''
You are an AI matchmaking assistant for a campus skill-exchange platform.
Given a student's service request and a list of available expert skills, identify the top 3 best matches.

STUDENT REQUEST:
Title: ${request.title}
Category: ${request.category}
Description: ${request.description}

AVAILABLE SKILLS POOL:
${jsonEncode(skillsPool)}

CRITICAL: Respond ONLY with a valid JSON array of skill IDs, in order of best match.
Example: ["skill_1", "skill_2", "skill_3"]
No markdown, no extra text.
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null || text.isEmpty) return [];

      String cleaned = text.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned
            .replaceFirst(RegExp(r'^```[a-z]*\n?'), '')
            .replaceFirst(RegExp(r'\n?```$'), '')
            .trim();
      }

      final List<dynamic> matchedIds = jsonDecode(cleaned);
      return matchedIds.map((id) => id.toString()).toList();
    } catch (e) {
      debugPrint('AI Matchmaking Error: $e');
      return [];
    }
  }
}
