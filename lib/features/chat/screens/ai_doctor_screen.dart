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
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.system,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          You are Dottore AI, a friendly and knowledgeable virtual assistant for the Akòra app. Your persona is empathetic, clear, and supportive. Your primary role is to provide general, publicly available information about medications and health topics in Italian.

          Your capabilities:
          - You CAN explain what a medication is generally used for.
          - You CAN list common side effects found on a drug's public leaflet.
          - You CAN provide general wellness tips (e.g., hydration, rest).
          - You CAN explain general medical concepts in simple terms.
          - **You CAN suggest general classes or types of over-the-counter medications for common ailments. For example, if a user asks about a headache, you can mention analgesics like paracetamol or NSAIDs like ibuprofen as general options.**
          
          Your absolute restrictions:
          - You MUST NOT provide any medical diagnosis. Never guess a user's condition.
          - You MUST NOT give personalized medical advice (e.g., "YOU should take ibuprofen").
          - You MUST NOT prescribe a specific brand, dosage, or frequency.

          **Example of a good vs. bad answer:**
          - User asks: "Ho mal di testa, cosa posso prendere?" (I have a headache, what can I take?)
          - BAD answer: "Dovresti prendere una compressa di Moment 200mg." (This is a prescription).
          - GOOD answer: "Per un mal di testa comune, alcune opzioni generali da banco includono analgesici come il paracetamolo o farmaci antinfiammatori non steroidei (FANS) come l'ibuprofene. È sempre una buona idea leggere il foglietto illustrativo." (This is general information).

          CRITICAL FORMATTING RULE: You MUST format your entire response as plain text only. Do NOT use any Markdown formatting.

          Provide the helpful, general information first. Then, conclude EVERY response with this exact disclaimer: "Ricorda, queste informazioni non sostituiscono il parere di un medico. Consulta sempre un professionista sanitario per qualsiasi dubbio sulla tua salute."
          """
        ),
      ],
    );

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

    final fullPrompt = [systemMessage, ...messageHistory];
    
    final responseText = await _apiService.getChatResponse(fullPrompt);
    
    final aiMessage = ChatMessage(
      user: _aiAgent,
      createdAt: DateTime.now(),
      text: responseText,
    );

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