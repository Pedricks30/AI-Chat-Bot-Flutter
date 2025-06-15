import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenRouterService {
  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';

  // Configuración desde .env
  static String get _apiKey {
    final key = dotenv.env['OPENROUTER_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('OPENROUTER_API_KEY no encontrada en .env');
    }
    return key;
  }

  static String get _model => dotenv.env['OPENROUTER_API_MODEL'] ?? 'openai/gpt-3.5-turbo';

  // Prompt del sistema con presentación inicial
  static const Map<String, String> _systemPrompt = {
    "role": "system",
    "content": "Hola, soy AIRI, tu asistente de apoyo emocional. "
        "Estoy aquí para escucharte y ayudarte a sentirte mejor. Puedes hablar conmigo con total confianza. "
        "¿Cómo te sientes hoy?\n\n"
        "Eres un psicólogo virtual especializado en terapia cognitivo-conductual. "
        "Ofrece apoyo emocional, escucha activa y sugerencias prácticas. "
        "Nunca des diagnósticos médicos, pero orienta sobre cuándo buscar ayuda profesional. "
        "Mantén respuestas breves (máximo 3 párrafos), claras y empáticas. "
        "No uses jerga técnica, habla en un tono amigable y accesible. "
        "Tu objetivo es ayudar al usuario a sentirse comprendido y apoyado emocionalmente. "
        "Si el usuario menciona síntomas graves, sugiere que consulte a un profesional de salud mental. "
        "Siempre responde con empatía y comprensión, evitando juicios o críticas. "
        "Si el usuario comparte información personal, trata de mantener la privacidad y confidencialidad. "
        "Si el usuario se siente abrumado, ofrécele técnicas de relajación o mindfulness. "
        "Si el usuario expresa pensamientos suicidas o autolesivos, sugiere que busque ayuda inmediata de un profesional de salud mental o una línea de crisis. "
        "Si el usuario menciona problemas de relación, ofrécele consejos sobre comunicación efectiva y resolución de conflictos. "
        "Si el usuario se siente ansioso, sugiere técnicas de respiración profunda o ejercicios de relajación. "
        "Si el usuario se siente deprimido, ofrécele actividades que puedan mejorar su estado de ánimo, como ejercicio o pasatiempos creativos. "
        "Si el usuario menciona problemas de autoestima, ofrécele afirmaciones positivas y ejercicios para mejorar la autoconfianza. "
        "Si el usuario se siente estresado, sugiere técnicas de manejo del estrés como la meditación o el yoga. "
        "Si el usuario menciona problemas de sueño, ofrécele consejos sobre higiene del sueño y relajación antes de dormir. "
        "Si el usuario se siente solo, ofrécele recursos para conectarse con amigos o grupos de apoyo. "
        "Sugiere links de YouTube o videos de relajación, meditación o mindfulness que puedan ayudar al usuario a sentirse mejor. "
        "Recuerda que tu objetivo es brindar apoyo emocional y sugerencias prácticas, no reemplazar la terapia profesional. "
        "Siempre mantén un tono positivo y alentador, y evita el uso de lenguaje negativo o crítico aunque a veces sea necesario hacerlo."
  };

  // Headers para la API
  static Map<String, String> get _headers {
    return {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
      'HTTP-Referer': 'YOUR_APP_DOMAIN',  // Sustituir por tu dominio real
      'X-Title': 'AIRI - Asistente Emocional'
    };
  }

  // Lista de frases de cierre para mantener la conversación abierta
  static const List<String> _frasesFinales = [
    "¿Quieres seguir hablando sobre esto?",
    "Estoy aquí si deseas continuar.",
    "¿Hay algo más que te gustaría compartir?",
    "Estoy para ti, ¿quieres que sigamos conversando?",
    "Cuando estés listo, podemos seguir charlando."
    "Recuerda que siempre puedes volver a hablar conmigo.",
    "Estoy aquí para escucharte cuando lo necesites.",
    "Si necesitas más apoyo, no dudes en decírmelo.",
    "Tu bienestar es importante, ¿quieres seguir hablando?",
    "Siempre estoy aquí para ti, ¿quieres continuar la conversación?",
    "No dudes en regresar si necesitas más apoyo.",
    "Estoy aquí para ayudarte, ¿quieres seguir conversando?",
    "Recuerda que siempre puedes contar conmigo.",
    "Si tienes más cosas en mente, estoy aquí para escucharte.",
    "Tu bienestar es mi prioridad, ¿quieres seguir hablando?",
    "Estoy aquí para ti, ¿hay algo más que te gustaría discutir?",
    "Siempre estoy disponible si necesitas hablar más.",
    "Tu bienestar es importante, ¿quieres seguir la conversación?",
    "Estoy aquí para apoyarte, ¿quieres continuar?",
    "Recuerda que siempre puedes volver a hablar conmigo.",
    "Estoy aquí para escucharte cuando lo necesites.",
    "Si necesitas más apoyo, no dudes en decírmelo.",
  ];

  // Función que elige una frase final aleatoria y la agrega a la respuesta
  static String _agregarFraseFinal(String respuesta) {
    final random = Random();
    final frase = _frasesFinales[random.nextInt(_frasesFinales.length)];
    return "$respuesta\n\n$frase";
  }

  // Función principal para obtener la respuesta desde OpenRouter
  static Future<String> obtenerRespuesta(String mensajeUsuario) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: _headers,
        body: jsonEncode({
          "model": _model,
          "messages": [
            _systemPrompt,
            {"role": "user", "content": mensajeUsuario}
          ],
          "max_tokens": 1000,
        }),
      );

      if (response.statusCode == 200) {
        final utf8Response = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utf8Response);
        final contenido = data['choices'][0]['message']['content'].trim();
        return _agregarFraseFinal(contenido);
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception("Error ${response.statusCode}: ${errorData['error']?['message'] ?? response.body}");
      }
    } catch (e) {
      throw Exception("Error al consultar OpenRouter: ${e.toString()}");
    }
  }
}
