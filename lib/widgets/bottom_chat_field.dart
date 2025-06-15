import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:chatbotapp/providers/chat_provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.chatProvider,
    required this.onSend,
  });

  final ChatProvider chatProvider;
  final VoidCallback onSend;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  // Controller para el campo de texto
  final TextEditingController textController = TextEditingController();

  // Focus node para el campo de texto
  final FocusNode textFieldFocus = FocusNode();

  @override
  void dispose() {
    textController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
  }) async {
    try {
      await chatProvider.sentMessage(message: message);
      widget.onSend(); // callback si se quiere ejecutar algo externo tras enviar
    } catch (e) {
      log('Error al enviar mensaje: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar el mensaje'),
          backgroundColor: Color.fromARGB(255, 17, 129, 45),
        ),
      );
    } finally {
      textController.clear();
      textFieldFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).textTheme.titleLarge!.color!,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              focusNode: textFieldFocus,
              controller: textController,
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 5,
              onSubmitted: widget.chatProvider.isLoading
                  ? null
                  : (String value) {
                      if (value.trim().isNotEmpty) {
                        sendChatMessage(
                          message: value.trim(),
                          chatProvider: widget.chatProvider,
                        );
                      }
                    },
              decoration: const InputDecoration.collapsed(
                hintText: 'Escribe tu mensaje...',
              ),
            ),
          ),
          IconButton(
            icon: widget.chatProvider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.send,
                    color: Color.fromARGB(255, 17, 129, 45),
                  ),
            onPressed: widget.chatProvider.isLoading
                ? null
                : () {
                    final message = textController.text.trim();
                    if (message.isNotEmpty) {
                      sendChatMessage(
                        message: message,
                        chatProvider: widget.chatProvider,
                      );
                    }
                  },
          ),
        ],
      ),
    );
  }
}
