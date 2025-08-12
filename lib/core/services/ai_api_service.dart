import 'package:dart_openai/dart_openai.dart';

class AiApiService {
  // The service now initializes itself using the compile-time variable.
  AiApiService() {
    const apiKey = String.fromEnvironment('OPENAI_API_KEY');
    if (apiKey.isEmpty) {
      print('!!! WARNING: OPENAI_API_KEY is not set. AI Doctor will not work. !!!');
    } else {
      OpenAI.apiKey = apiKey;
    }
  }

  // This method takes the history of messages and sends them to the AI.
  Future<String> getChatResponse(List<OpenAIChatCompletionChoiceMessageModel> messages) async {
    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo', // A fast and cost-effective model
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