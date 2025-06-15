import 'package:flutter/material.dart';  
import 'package:hive/hive.dart';  
import '../data/psychological_questions.dart';  
  
class TestProvider extends ChangeNotifier {  
  final List<String> _selectedAnswers = [];  
  int _currentQuestionIndex = 0;  
  bool _isTestCompleted = false;  
  
  List<String> get selectedAnswers => _selectedAnswers;  
  int get currentQuestionIndex => _currentQuestionIndex;  
  bool get isTestCompleted => _isTestCompleted;  
  int get totalQuestions => psychologicalQuestions.length;  
  
  void selectAnswer(String answer) {  
    if (_selectedAnswers.length <= _currentQuestionIndex) {  
      _selectedAnswers.add(answer);  
    } else {  
      _selectedAnswers[_currentQuestionIndex] = answer;  
    }  
    notifyListeners();  
  }  
  
  void nextQuestion() {  
    if (_currentQuestionIndex < psychologicalQuestions.length - 1) {  
      _currentQuestionIndex++;  
      notifyListeners();  
    } else {  
      _completeTest();  
    }  
  }  
  
  void _completeTest() {  
    _isTestCompleted = true;  
    _saveTestResults();  
    notifyListeners();  
  }  
  
  Future<void> _saveTestResults() async {  
    final box = await Hive.openBox('testResults');  
    await box.put('answers', _selectedAnswers);  
    await box.put('completed', true);  
    await box.put('completedAt', DateTime.now().toIso8601String());  
  }  
  
  Future<bool> hasCompletedTest() async {  
    final box = await Hive.openBox('testResults');  
    return box.get('completed', defaultValue: false);  
  }  
  
  String generateAnalysisPrompt() {  
    final analysis = StringBuffer();  
    analysis.write("=== ANÁLISIS COMPLETO DEL TEST PSICOLÓGICO ===\n\n");  

    for (int i = 0; i < _selectedAnswers.length; i++) {  
      analysis.write("PREGUNTA ${i + 1}:\n");  
      analysis.write("${psychologicalQuestions[i].text}\n\n");  
      analysis.write("RESPUESTA SELECCIONADA: ${_selectedAnswers[i]}\n");  
      analysis.write("OPCIONES DISPONIBLES:\n");  
      for (int j = 0; j < psychologicalQuestions[i].answers.length; j++) {  
        final isSelected = psychologicalQuestions[i].answers[j] == _selectedAnswers[i];  
        analysis.write("${isSelected ? '✓' : '○'} ${psychologicalQuestions[i].answers[j]}\n");  
      }  
      analysis.write("\n" + "="*50 + "\n\n");  
    }
    analysis.write("Por favor, analiza estas respuestas y proporciona consejos personalizados para ayudar con ansiedad, depresión y bienestar mental, considerando el nivel de severidad indicado en cada respuesta.");  
    return analysis.toString();  
  }
  
  void resetTest() {  
    _selectedAnswers.clear();  
    _currentQuestionIndex = 0;  
    _isTestCompleted = false;  
    notifyListeners();  
  }  
}