import 'package:chatbotapp/providers/test_provider.dart';
import 'package:chatbotapp/widgets/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:chatbotapp/themes/my_theme.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/providers/settings_provider.dart';
import 'package:chatbotapp/services/tts_service.dart';  
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:chatbotapp/providers/auth_provider.dart';

void main() async {
  // Inicialización de servicios
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  await ChatProvider.initHive();
  await TTSService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => TestProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.getSavedSettings();
  }

  @override  
  Widget build(BuildContext context) {  
    return MaterialApp(  
      title: 'Flutter Chat Bot App',  
      theme: context.watch<SettingsProvider>().isDarkMode ? darkTheme : lightTheme,  
      debugShowCheckedModeBanner: false,  
      home: const AuthWrapper(),  // Eliminar el parámetro incorrecto  
    );  
  }
}