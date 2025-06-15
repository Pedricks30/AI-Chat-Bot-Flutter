import 'package:flutter_tts/flutter_tts.dart';  
  
class TTSService {  
  static final FlutterTts _flutterTts = FlutterTts();  
  static bool _isInitialized = false;  
  
  static Future<void> initialize() async {  
    if (_isInitialized) return;  
      
    await _flutterTts.setLanguage("es-ES");  
    await _flutterTts.setSpeechRate(0.5);  
    await _flutterTts.setVolume(1.0);  
    await _flutterTts.setPitch(1.0);  
      
    _isInitialized = true;  
  }  
  
  static Future<void> speak(String text) async {  
    if (!_isInitialized) await initialize();  
      
    // Limpiar texto de markdown y caracteres especiales  
    String cleanText = _cleanText(text);  
      
    await _flutterTts.speak(cleanText);  
  }  
  
  static Future<void> stop() async {  
    await _flutterTts.stop();  
  }  
  
  static String _cleanText(String text) {  
    // Remover markdown básico y caracteres especiales  
    return text  
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // **bold**  
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')     // *italic*  
        .replaceAll(RegExp(r'#{1,6}\s'), '')         // headers  
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1') // links  
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')     // code  
        .trim();  
  }  
}