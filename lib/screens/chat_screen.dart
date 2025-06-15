import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/utility/animated_dialog.dart';
import 'package:chatbotapp/widgets/bottom_chat_field.dart';
import 'package:chatbotapp/widgets/chat_messages.dart';
import 'package:provider/provider.dart';
import 'package:chatbotapp/providers/settings_provider.dart';
import 'package:chatbotapp/services/tts_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.inChatMessages.isNotEmpty) {
          _scrollToBottom();
        }

        // auto scroll to bottom on new message
        chatProvider.addListener(() {
          if (chatProvider.inChatMessages.isNotEmpty) {
            _scrollToBottom();
          }
        });

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            centerTitle: true,
            title: const Text('Chat de terapia'),
            actions: [
              if (chatProvider.inChatMessages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.add),
                      onPressed: () async {
                        // show my animated dialog to start new chat
                        showMyAnimatedDialog(
                          context: context,
                          title: 'Comenzar nuevo chat',
                          content: '¿Estás seguro de que quieres comenzar un nuevo chat?',
                          actionText: 'Sí',
                          onActionPressed: (value) async {
                            if (value) {
                              // prepare chat room
                              await chatProvider.prepareChatRoom(
                                isNewChat: true, 
                                chatID: '',
                              );
                            }
                          }, cancelText: 'No',
                          onCancelPressed: (value) {
                            if (value) {
                              Navigator.of(context).pop();
                            }
                          },
                        );
                      },
                    ),
                  ),
                )
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: chatProvider.inChatMessages.isEmpty
                        ? const Center(
                            child: Text('Aún no hay mensajes'),
                          )
                        : ChatMessages(
                            scrollController: _scrollController,
                            chatProvider: chatProvider,
                          ),
                  ),
                  // input field
                  BottomChatField(
                    chatProvider: chatProvider, onSend: () { 
                      // scroll to bottom after sending a message
                      _scrollToBottom();
                    },
                  )
                ],
              ),
            ),
          ),
            // Mover el botón a la parte inferior usando un Stack
            bottomNavigationBar: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              if (settingsProvider.shouldSpeak) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5.0, right: 5.0),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                  mini: true,
                  onPressed: () => TTSService.stop(),
                  child: const Icon(Icons.stop),
                  tooltip: 'Detener voz',
                  ),
                ],
                ),
              );
              }
              return const SizedBox.shrink();
            },
            ),

        );
      },
    );
  }
}