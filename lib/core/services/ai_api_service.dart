import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiApiService {
  static void init() {
    // Read the API key from the loaded dotenv environment
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      print('!!! WARNING: OPENAI_API_KEY not found in .env file. AI Doctor will not work. !!!');
      return;
    }
    
    OpenAI.apiKey = apiKey;
    print("AI Api Service Initialized.");
  }
  
  AiApiService();

  // This method takes the history of messages and sends them to the AI.
  Future<String> getChatResponse(List<OpenAIChatCompletionChoiceMessageModel> messages) async {
    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: 'gpt-4o',
        messages: messages,
      );
      final content = chatCompletion.choices.first.message.content;

      if (content == null || content.isEmpty) {
        return "Mi dispiace, non ho ricevuto una risposta valida.";
      }
      // Join the content parts into a single string.
      return content.map((item) => item.text).join('');
    } catch (e) {
      print("Error fetching AI response: $e");
      return "Mi dispiace, si è verificato un errore di connessione. Riprova più tardi.";
    }
  }
}