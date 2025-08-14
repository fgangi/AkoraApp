import 'package:akora_app/core/services/ai_api_service.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AiDoctorScreen extends StatefulWidget {
  const AiDoctorScreen({super.key});

  @override
  State<AiDoctorScreen> createState() => _AiDoctorScreenState();
}

class _AiDoctorScreenState extends State<AiDoctorScreen> {
  // Create an instance of our service
  final AiApiService _apiService = AiApiService();

  // Define the user and the AI agent
  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'User');
  final ChatUser _aiAgent = ChatUser(id: '2', firstName: 'Dottore AI');

  // A list to hold all the messages in the conversation
  List<ChatMessage> _messages = [];
  final List<ChatUser> _typingUsers = [];

  @override
  void initState() {
    super.initState();
    // Add an initial welcome message from the AI when the screen opens
    _messages.add(
      ChatMessage(
        user: _aiAgent,
        createdAt: DateTime.now(),
        text: "Buongiorno! Sono il tuo assistente medico virtuale. Come posso aiutarti oggi? Ricorda, le mie risposte non sostituiscono un parere medico professionale.",
      ),
    );
  }

  // This method is called when the user sends a message
  void _onSend(ChatMessage message) {
    setState(() {
      _messages.insert(0, message);
      _typingUsers.add(_aiAgent); // Show typing indicator
    });
    _getAiResponse(); // Call the live AI method
  }

  Future<void> _getAiResponse() async {
    // 1. Create the "System Prompt" to define the AI's persona and rules.
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.system,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
           """
          You are Dottore AI, a helpful and empathetic virtual assistant for the Akòra app. Your purpose is to provide clear and safe general information about medications and health topics.
          
          Your rules are:
          1.  ALWAYS answer in Italian.
          2.  You are an informational tool, NOT a medical professional.
          3.  You MUST NEVER provide a medical diagnosis, suggest a specific treatment, or tell a user to take or not take a specific medication.
          4.  You CAN explain what a drug is generally used for.
          5.  You CAN list common, publicly known side effects of a medication.
          6.  You CAN explain general best practices, such as what to do if a dose is missed.
          7.  Every single response MUST end with a clear disclaimer, for example: "Ricorda, queste informazioni non sostituiscono il parere di un medico. Consulta sempre un professionista sanitario per qualsiasi dubbio sulla tua salute."
          """
        ),
      ],
    );

    // 2. Convert our app's message history to the format OpenAI requires.
    final messageHistory = _messages.reversed.map((message) {
      return OpenAIChatCompletionChoiceMessageModel(
        role: message.user.id == _currentUser.id
            ? OpenAIChatMessageRole.user
            : OpenAIChatMessageRole.assistant,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(message.text),
        ],
      );
    }).toList();

    // 3. Combine the system prompt with the message history.
    final fullPrompt = [systemMessage, ...messageHistory];
    
    // 4. Call our API service.
    final responseText = await _apiService.getChatResponse(fullPrompt);
    
    // 5. Create a new ChatMessage with the AI's response.
    final aiMessage = ChatMessage(
      user: _aiAgent,
      createdAt: DateTime.now(),
      text: responseText,
    );

    // 6. Update the UI.
    if (mounted) {
      setState(() {
        _messages.insert(0, aiMessage);
        _typingUsers.remove(_aiAgent); // Hide typing indicator
      });
    }
  }

    @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Dottore AI'),
      ),
      // Add padding to prevent the chat UI from touching the screen edges.
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Material(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          child: DashChat(
            currentUser: _currentUser,
            onSend: _onSend,
            messages: _messages,
            typingUsers: _typingUsers,
            
            inputOptions: InputOptions(
              // Change the placeholder text here
              inputDecoration: const InputDecoration.collapsed(
                hintText: 'Scrivi un messaggio...',
              ),
              inputTextStyle: const TextStyle(fontSize: 16, color: CupertinoColors.black),
              sendButtonBuilder: (send) {
                return CupertinoButton(
                  onPressed: send,
                  padding: const EdgeInsets.all(8),
                  child: const Icon(CupertinoIcons.arrow_up_circle_fill, size: 30),
                );
              },
            ),
            messageOptions: MessageOptions(
              spaceWhenAvatarIsHidden: 6,
              messagePadding: const EdgeInsets.all(12),
              marginDifferentAuthor: const EdgeInsets.only(top: 10, bottom: 10),
              currentUserContainerColor: CupertinoTheme.of(context).primaryColor,
              currentUserTextColor: CupertinoColors.white,
              containerColor: CupertinoColors.secondarySystemFill,
              textColor: CupertinoColors.label,
              showOtherUsersAvatar: true,
              avatarBuilder: (user, onPress, onLongPress) {
                if (user.id == _aiAgent.id) {
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: CupertinoColors.systemGrey,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(CupertinoIcons.heart_fill, color: CupertinoColors.white, size: 20),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}