import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import '../providers/test_provider.dart';  
import '../data/psychological_questions.dart';  
  
class TestScreen extends StatelessWidget {  
  final VoidCallback onTestCompleted;  
  
  const TestScreen({super.key, required this.onTestCompleted});  
  
  @override  
  Widget build(BuildContext context) {  
    return Consumer<TestProvider>(  
      builder: (context, testProvider, child) {  
        final currentQuestion = psychologicalQuestions[testProvider.currentQuestionIndex];  
          
        return Scaffold(  
          body: Container(  
            decoration: BoxDecoration(  
              //Color verde
              //color: Color.fromARGB(255, 15, 200, 18) // Color de fondo claro,  
              // Usar el color del tema en lugar de colores fijos  
              color: Theme.of(context).scaffoldBackgroundColor,  
            ),  
            child: SafeArea(  
              child: Padding(  
                padding: const EdgeInsets.all(24.0),  
                child: Column(  
                  crossAxisAlignment: CrossAxisAlignment.stretch,  
                  children: [  
                    // Barra de progreso que muestra el progreso del test
                    LinearProgressIndicator(  
                      value: (testProvider.currentQuestionIndex + 1) / testProvider.totalQuestions,  
                      backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),  
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),  
                    ),  
                    const SizedBox(height: 40),  
                    Text(  
                      // Mostrar el índice de la pregunta actual y el total de preguntas
                      'Pregunta ${testProvider.currentQuestionIndex + 1}/${testProvider.totalQuestions}',  
                      style: TextStyle(  
                        // Usar un color de texto que contraste con el fondo
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,  
                        fontWeight: FontWeight.w600,  
                      ),  
                      textAlign: TextAlign.center,
                    ),  
                    const SizedBox(height: 20),  
                    Card(  
                      elevation: 8,  
                      shape: RoundedRectangleBorder(  
                        borderRadius: BorderRadius.circular(15),  
                      ),  

                      // Usar el color del tema para el fondo de la tarjeta
                      color: const Color.fromARGB(255, 15, 200, 18),   
                      child: Padding(  
                        padding: const EdgeInsets.all(20),  
                        child: Text(  
                          currentQuestion.text,  
                          style: TextStyle(  
                            color: const Color.fromARGB(255, 255, 255, 255), // Cambiar a blanco
                            fontSize: 22,  
                            fontWeight: FontWeight.w600,  
                          ),  
                          textAlign: TextAlign.center,  
                        ),  
                      ),  
                    ),  
                    const SizedBox(height: 30),  
                    // Lista de botones de respuesta
                    Expanded(  
                      child: ListView(  
                      // Usar un ListView para permitir el desplazamiento si hay muchas respuestas
                        children: currentQuestion.answers  
                            .map((answer) => _AnswerButton(  
                                  answer: answer,  
                                  onTap: () {  
                                    testProvider.selectAnswer(answer);  
                                    Future.delayed(const Duration(milliseconds: 300), () {  
                                      if (testProvider.currentQuestionIndex == testProvider.totalQuestions - 1) {  
                                        testProvider.nextQuestion();  
                                        onTestCompleted();  
                                      } else {  
                                        testProvider.nextQuestion();  
                                      }  
                                    });  
                                  },  
                                ))  
                            .toList(),  
                      ),  
                    ),  
                  ],  
                ),  
              ),  
            ),  
          ),  
        );  
      },  
    );  
  }  
}  
  
class _AnswerButton extends StatelessWidget {  
  final String answer;  
  final VoidCallback onTap;  
  
  const _AnswerButton({required this.answer, required this.onTap});  
  
  @override  
  Widget build(BuildContext context) {  
    return Padding(  
      padding: const EdgeInsets.symmetric(vertical: 8),  
      child: ElevatedButton(  
        // Usar ElevatedButton para un botón con sombra y estilo elevado
        style: ElevatedButton.styleFrom(  
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),  
          backgroundColor: Theme.of(context).colorScheme.surface,  
          foregroundColor: Theme.of(context).colorScheme.primary,  
          shape: RoundedRectangleBorder(  
            borderRadius: BorderRadius.circular(30),  
          ),  
          elevation: 4,  
        ),  
        onPressed: onTap,  
        child: Text(  
          answer,  
          style: const TextStyle(  
            fontSize: 18,  
            fontWeight: FontWeight.w500,  
          ),  
        ),  
      ),  
    );  
  }  
}