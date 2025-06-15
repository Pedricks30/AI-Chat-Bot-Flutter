import 'package:flutter/material.dart';    
  
// light theme    
ThemeData lightTheme = ThemeData(    
  brightness: Brightness.light,    
  scaffoldBackgroundColor: Colors.white, // Fondo blanco sólido  
  colorScheme: const ColorScheme.light(    
    primary: Color.fromARGB(255, 17, 129, 45),    
    surface: Color.fromARGB(255, 238, 235, 235), // Fondo sólido para widgets    
    surfaceContainerHighest: Color(0xFFE8E8E8), // Para mensajes del asistente    
    primaryContainer: Color.fromARGB(255, 17, 129, 45), // Para mensajes del usuario    
    onSurface: Color.fromARGB(255, 17, 16, 16),  
    onPrimary: Colors.white,    
  ),    
  cardColor: const Color.fromARGB(255, 242, 240, 240),  
  useMaterial3: true,    
);    
  
// dark theme    
ThemeData darkTheme = ThemeData(    
  brightness: Brightness.dark,    
  scaffoldBackgroundColor: const Color(0xFF1E1E1E), // Fondo oscuro sólido  
  colorScheme: const ColorScheme.dark(    
    primary: Color.fromARGB(255, 17, 129, 45), // 
    surface: Color.fromARGB(255, 64, 62, 62), // Fondo sólido para widgets    
    surfaceContainerHighest: Color(0xFF2D2D2D), // Para mensajes del asistente    
    primaryContainer: Color.fromARGB(255, 17, 129, 45), // Para mensajes del usuario    
    onSurface: Colors.white, // Texto blanco    
    onPrimary: Colors.white,    
  ),    
  cardColor: const Color(0xFF2D2D2D), // Para el campo de entrada    
  useMaterial3: true,    
);