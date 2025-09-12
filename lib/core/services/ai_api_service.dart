import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiApiService {
  static bool _isInitialized = false;
  static GenerativeModel? _nativeGeminiModel;
  
  /// Initializes the AI service with Gemini configuration.
  /// Uses Gemini's OpenAI-compatible endpoint with native SDK fallback.
  /// 
  /// Environment variables:
  /// - GEMINI_API_KEY: Required for AI functionality
  static void init() {
    final geminiApiKey = dotenv.env['GEMINI_API_KEY'];

    if (geminiApiKey != null && geminiApiKey.isNotEmpty) {
      // Use Gemini with OpenAI-compatible endpoint
      print("Using Gemini AI service");
      OpenAI.apiKey = geminiApiKey;
      OpenAI.baseUrl = 'https://generativelanguage.googleapis.com/v1beta/openai';
      OpenAI.requestsTimeOut = Duration(seconds: 60);
      
      // Initialize the native Gemini model as a fallback
      _nativeGeminiModel = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: geminiApiKey,
      );
      
      print("AI Api Service Initialized with Gemini.");
    } else {
      print('!!! WARNING: No GEMINI_API_KEY found. Set GEMINI_API_KEY in .env file. AI Doctor will not work. !!!');
      return;
    }
    
    _isInitialized = true;
  }
  
  static bool get isInitialized => _isInitialized;
  
  AiApiService();

  // This method takes the history of messages and sends them to the AI.
  Future<String> getChatResponse(List<OpenAIChatCompletionChoiceMessageModel> messages) async {
    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: 'gemini-2.5-flash-lite',
        messages: messages,
      );
      
      final content = chatCompletion.choices.first.message.content;

      if (content == null || content.isEmpty) {
        return "Mi dispiace, non ho ricevuto una risposta valida.";
      }
      
      // Join the content parts into a single string.
      final response = content.map((item) => item.text).join('');
      return response;
    } catch (e) {
      // If OpenAI compatibility fails, try native Gemini SDK
      if (_nativeGeminiModel != null && (e.toString().contains('FormatException') || e.toString().contains('JSON'))) {
        try {
          return await _useNativeGeminiSDK(messages);
        } catch (nativeError) {
          return "Mi dispiace, il servizio AI sta avendo problemi tecnici. Riprova più tardi.";
        }
      }
      
      if (e.toString().contains('timeout') || e.toString().contains('connection')) {
        return "Mi dispiace, il servizio AI non risponde. Riprova più tardi.";
      }
      
      return "Mi dispiace, si è verificato un errore di connessione. Riprova più tardi.";
    }
  }

  // Fallback method using native Gemini SDK
  Future<String> _useNativeGeminiSDK(List<OpenAIChatCompletionChoiceMessageModel> messages) async {
    if (_nativeGeminiModel == null) {
      throw Exception("Native Gemini model not initialized");
    }

    // Convert OpenAI format messages to Gemini format
    final List<Content> geminiMessages = [];
    
    for (final message in messages) {
      final role = message.role == OpenAIChatMessageRole.user ? 'user' : 
                   message.role == OpenAIChatMessageRole.assistant ? 'model' : 
                   'user'; // System messages will be treated as user messages
      
      final text = message.content?.map((item) => item.text).join('') ?? '';
      
      if (text.isNotEmpty) {
        geminiMessages.add(Content(role, [TextPart(text)]));
      }
    }
    
    // Create a chat session with conversation history
    final chat = _nativeGeminiModel!.startChat(history: geminiMessages.take(geminiMessages.length - 1).toList());
    
    // Send the last message
    final lastMessage = geminiMessages.last;
    final lastMessageText = lastMessage.parts.whereType<TextPart>().first.text;
    final response = await chat.sendMessage(Content.text(lastMessageText));
    
    final responseText = response.text;
    if (responseText != null && responseText.isNotEmpty) {
      return responseText;
    } else {
      throw Exception("Empty response from native Gemini SDK");
    }
  }
}