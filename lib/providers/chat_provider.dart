import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatbotapp/constants/constants.dart';
import 'package:chatbotapp/hive/boxes.dart';
import 'package:chatbotapp/hive/chat_history.dart';
import 'package:chatbotapp/hive/settings.dart';
import 'package:chatbotapp/hive/user_model.dart';
import 'package:chatbotapp/models/message.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:chatbotapp/services/openrouter_service.dart';
import 'package:chatbotapp/services/tts_service.dart';  
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  // Lista de mensajes en el chat actual
  final List<Message> _inChatMessages = [];

  // Controlador de página (si aún lo necesitas)
  final PageController _pageController = PageController();

  // Índice de la pantalla actual
  int _currentIndex = 0;

  // ID del chat actual
  String _currentChatId = '';

  // Estado de carga
  bool _isLoading = false;

  // Getters
  List<Message> get inChatMessages => _inChatMessages;
  PageController get pageController => _pageController;
  int get currentIndex => _currentIndex;
  String get currentChatId => _currentChatId;
  bool get isLoading => _isLoading;

  // Cargar mensajes desde la base de datos
  Future<void> setInChatMessages({required String chatId}) async {
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);

    for (var message in messagesFromDB) {
      if (_inChatMessages.contains(message)) {
        log('Message already exists');
        continue;
      }
      _inChatMessages.add(message);
    }
    notifyListeners();
  }
  // Enviar análisis inicial si el test está completo
  Future<void> sendInitialAnalysis() async {  
    try {  
      final box = await Hive.openBox('testResults');  
      final hasCompleted = box.get('completed', defaultValue: false);  
      final answers = box.get('answers', defaultValue: <String>[]);  
        
      if (hasCompleted && answers.isNotEmpty) {  
        // Crear prompt de análisis basado en las respuestas  
        final analysisPrompt = _generateAnalysisPrompt(answers);  
          
        // Enviar como primer mensaje al chat  
        await sentMessage(message: analysisPrompt);  
      }  
    } catch (e) {  
      print('Error al enviar análisis inicial: $e');  
    }  
  }  
  
String _generateAnalysisPrompt(List<String> answers) {  
  final analysis = StringBuffer();  
  analysis.write("Análisis del test psicológico del usuario:\n\n");  
    
  // Aquí necesitarías importar tus preguntas psicológicas  
  for (int i = 0; i < answers.length && i < 5; i++) {  // Limitar a 5 preguntas por ahora  
    analysis.write("Pregunta ${i + 1}: Respuesta: ${answers[i]}\n");  
  }  
    
  analysis.write("\nPor favor, proporciona consejos personalizados basados en estas respuestas para ayudar con ansiedad, depresión y bienestar mental.");  
  return analysis.toString();  
}
  // Cargar mensajes desde Hive
  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');

    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      return Message.fromMap(Map<String, dynamic>.from(message));
    }).toList();
    
    notifyListeners();
    return newData;
  }

  // Cambiar índice de página actual
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  // Establecer ID de chat actual
  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  // Establecer estado de carga
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  // Eliminar chat
  Future<void> deleteChatMessages({required String chatId}) async {
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    } else {
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    }

    if (currentChatId.isNotEmpty && currentChatId == chatId) {
      setCurrentChatId(newChatId: '');
      _inChatMessages.clear();
      notifyListeners();
    }
  }

  // Preparar sala de chat
  Future<void> prepareChatRoom({
    required bool isNewChat,
    required String chatID,
  }) async {
    _inChatMessages.clear();

    if (!isNewChat) {
      final chatHistory = await loadMessagesFromDB(chatId: chatID);
      _inChatMessages.addAll(chatHistory);
    }

    setCurrentChatId(newChatId: chatID);
  }

  // Enviar mensaje (versión simplificada solo texto)
  Future<void> sentMessage({
    required String message,
  }) async {
    setLoading(value: true);
    final chatId = getChatId();
    final messagesBox = await Hive.openBox('${Constants.chatMessagesBox}$chatId');

    // Generar IDs únicos para los mensajes
    final userMessageId = const Uuid().v4();
    final assistantMessageId = const Uuid().v4();

    // Mensaje del usuario
    final userMessage = Message(
      messageId: userMessageId,
      chatId: chatId,
      role: Role.user,
      message: StringBuffer(message),
      timeSent: DateTime.now(),
    );

    _inChatMessages.add(userMessage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }

    // Enviar mensaje a OpenRouter y manejar respuesta
    await sendMessageToOpenRouter(
      message: message,
      chatId: chatId,
      userMessage: userMessage,
      modelMessageId: assistantMessageId,
      messagesBox: messagesBox,
    );
  }

  // Enviar mensaje a OpenRouter
  Future<void> sendMessageToOpenRouter({
    required String message,
    required String chatId,
    required Message userMessage,
    required String modelMessageId,
    required Box messagesBox,
  }) async {
    // Mensaje del asistente (inicialmente vacío)
    final assistantMessage = userMessage.copyWith(
      messageId: modelMessageId,
      role: Role.assistant,
      message: StringBuffer(),
      timeSent: DateTime.now(),
    );

    _inChatMessages.add(assistantMessage);
    notifyListeners();

    try {
      // Obtener respuesta de OpenRouter
      final respuesta = await OpenRouterService.obtenerRespuesta(message);
      
      // Actualizar mensaje del asistente
      final assistantMsgIndex = _inChatMessages.indexWhere(
        (m) => m.messageId == assistantMessage.messageId && m.role == Role.assistant
      );
      
      if (assistantMsgIndex != -1) {
        _inChatMessages[assistantMsgIndex].message.write(respuesta);
        notifyListeners();
        // Verificar si TTS está habilitado y reproducir  
        await _speakResponseIfEnabled(respuesta);  
      }
      // Agregar este método al ChatProvider:  
      
      // Guardar mensajes en la base de datos
      await saveMessagesToDB(
        chatID: chatId,
        userMessage: userMessage,
        assistantMessage: _inChatMessages[assistantMsgIndex],
        messagesBox: messagesBox,
      );
    } catch (error) {
      log('Error en OpenRouter: $error');
      
      // Mostrar mensaje de error al usuario
      final errorMsgIndex = _inChatMessages.indexWhere(
        (m) => m.messageId == assistantMessage.messageId && m.role == Role.assistant
      );
      
      if (errorMsgIndex != -1) {
        _inChatMessages[errorMsgIndex].message.write(
          'Lo siento, ocurrió un error al procesar tu mensaje. Por favor intenta nuevamente.'
        );
        notifyListeners();
      }
    } finally {
      setLoading(value: false);
    }
  }

  // Método privado para TTS si está habilitado
  Future<void> _speakResponseIfEnabled(String response) async {  
    try {  
      final settingsBox = Boxes.getSettings();  
      if (settingsBox.isNotEmpty) {  
        final settings = settingsBox.getAt(0);  
        if (settings?.shouldSpeak == true) {  
          await TTSService.speak(response);  
        }  
      }  
    } catch (e) {  
      log('Error en TTS: $e');  
    }  
  }

  // Guardar mensajes en la base de datos
  Future<void> saveMessagesToDB({
    required String chatID,
    required Message userMessage,
    required Message assistantMessage,
    required Box messagesBox,
  }) async {
    await messagesBox.add(userMessage.toMap());
    await messagesBox.add(assistantMessage.toMap());

    // Guardar en el historial de chats
    final chatHistoryBox = Boxes.getChatHistory();
    final chatHistory = ChatHistory(
      chatId: chatID,
      prompt: userMessage.message.toString(),
      response: assistantMessage.message.toString(),
      imagesUrls: [], // Vacío ya que no manejamos imágenes
      timestamp: DateTime.now(),
    );
    await chatHistoryBox.put(chatID, chatHistory);

    await messagesBox.close();
  }

// En chat_provider.dart, modifica getChatId()  
  String getChatId() {  
    final user = FirebaseAuth.instance.currentUser;  
    final userPrefix = user?.uid ?? 'anonymous';  
      
    if (currentChatId.isEmpty) {  
      return '${userPrefix}_${const Uuid().v4()}';  
    } else {  
      return currentChatId;  
    }  
  }

  // Inicializar Hive
  static initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDB);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      await Hive.openBox<UserModel>(Constants.userBox);
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }
}