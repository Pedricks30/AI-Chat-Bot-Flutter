import 'package:chatbotapp/providers/test_provider.dart';  
import 'package:chatbotapp/screens/test_screen.dart';  
import 'package:flutter/cupertino.dart';  
import 'package:flutter/material.dart';  
import 'package:chatbotapp/providers/chat_provider.dart';  
import 'package:chatbotapp/screens/chat_history_screen.dart';  
import 'package:chatbotapp/screens/chat_screen.dart';  
import 'package:chatbotapp/screens/profile_screen.dart';  
import 'package:provider/provider.dart';  
  
class HomeScreen extends StatefulWidget {  
  const HomeScreen({super.key});  
  
  @override  
  State<HomeScreen> createState() => _HomeScreenState();  
}  
  
class _HomeScreenState extends State<HomeScreen> {  
  bool _testCompleted = false;  
    
  @override  
  void initState() {  
    super.initState();  
    // Usar WidgetsBinding para esperar a que el contexto esté listo  
    WidgetsBinding.instance.addPostFrameCallback((_) {  
      _checkTestStatus();  
    });  
  }  
    
  Future<void> _checkTestStatus() async {  
    try {  
      final testProvider = context.read<TestProvider>();  
      final completed = await testProvider.hasCompletedTest();  
      if (mounted) {  // Verificar que el widget sigue montado  
        setState(() {  
          _testCompleted = completed;  
        });  
      }  
    } catch (e) {  
      print('Error checking test status: $e');  
      // En caso de error, asumir que el test no está completado  
      if (mounted) {  
        setState(() {  
          _testCompleted = false;  
        });  
      }  
    }  
  }  
    
  // list of screens  
  final List<Widget> _screens = [  
    const ChatHistoryScreen(),  
    const ChatScreen(),  
    const ProfileScreen(),  
  ];  
  
  @override  
  Widget build(BuildContext context) {  
    // Si el test no está completado, mostrar la pantalla del test  
    if (!_testCompleted) {  
      return TestScreen(  
        onTestCompleted: () {  
          setState(() {  
            _testCompleted = true;  
          });  
          // Enviar análisis inicial al chat después de completar el test  
          Future.delayed(const Duration(milliseconds: 500), () {  
            context.read<ChatProvider>().sendInitialAnalysis();  
          });  
        },  
      );  
    }  
      
    // Si el test ya está completado, mostrar la navegación normal  
    return Consumer<ChatProvider>(  
      builder: (context, chatProvider, child) {  
        return Scaffold(  
          body: PageView(  
            controller: chatProvider.pageController,  
            children: _screens,  
            onPageChanged: (index) {  
              chatProvider.setCurrentIndex(newIndex: index);  
            },  
          ),  
          bottomNavigationBar: BottomNavigationBar(  
            currentIndex: chatProvider.currentIndex,  
            elevation: 0,  
            // Usar el color del tema para el fondo de la barra de navegación
            selectedItemColor: Theme.of(context).colorScheme.primary,  
            onTap: (index) {  
              chatProvider.setCurrentIndex(newIndex: index);  
              chatProvider.pageController.jumpToPage(index);  
            },  
            items: const [  
                BottomNavigationBarItem(  
                icon: Icon(Icons.history),  
                label: 'Historial de Chats',  
              ),  
              BottomNavigationBarItem(  
                icon: Icon(CupertinoIcons.chat_bubble),  
                label: 'Chat',  
              ),  
              BottomNavigationBarItem(  
                icon: Icon(CupertinoIcons.person),  
                label: 'Perfil',  
              ),  
            ],  
          ),  
        );  
      },  
    );  
  }  
}