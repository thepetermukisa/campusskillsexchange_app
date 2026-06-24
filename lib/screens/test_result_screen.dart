import 'package:flutter/material.dart';
// ignore: unused_import
import './home_screen.dart';

class TestResultScreen extends StatelessWidget {
  static const routeName = '/test-result';

  final double score;
  final int totalQuestions;

  const TestResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final int correctAnswers = (score / 100 * totalQuestions).round();
    final bool passed = score >= 60;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            margin: EdgeInsets.all(16.0),
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    passed ? 'Congratulations!' : 'Keep Practicing!',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: passed
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your Score',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${score.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 60.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'You answered $correctAnswers out of $totalQuestions questions correctly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      // Pop back to BecomeExpertScreen
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5.0,
                    ),
                    child: Text(
                      'Continue Application',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
