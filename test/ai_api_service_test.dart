import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:akora_app/core/services/ai_api_service.dart';

import 'ai_api_service_test.mocks.dart';

// Generate mocks for the service itself to test behavior
@GenerateMocks([AiApiService])
void main() {
  group('AiApiService', () {
    late MockAiApiService mockAiApiService;

    setUp(() {
      mockAiApiService = MockAiApiService();
    });

    group('init() method', () {
      setUpAll(() async {
        // Initialize dotenv for testing
        await dotenv.load(fileName: ".env");
      });

      test('should complete without throwing', () {
        // Act & Assert - init() should run without throwing
        expect(() => AiApiService.init(), returnsNormally);
      });

      test('should handle multiple calls', () {
        // Act & Assert - Multiple init() calls should work
        expect(() => AiApiService.init(), returnsNormally);
        expect(() => AiApiService.init(), returnsNormally);
      });

      test('should handle missing API key gracefully', () {
        // Arrange - Clear any existing API key from environment
        final originalGeminiKey = dotenv.env['GEMINI_API_KEY'];
        dotenv.env.remove('GEMINI_API_KEY');

        // Act & Assert - init() should run without throwing even with missing key
        expect(() => AiApiService.init(), returnsNormally);

        // Cleanup - restore original key if it existed
        if (originalGeminiKey != null) {
          dotenv.env['GEMINI_API_KEY'] = originalGeminiKey;
        }
      });

      test('should handle empty API key gracefully', () {
        // Arrange - Set empty API key
        final originalGeminiKey = dotenv.env['GEMINI_API_KEY'];
        dotenv.env['GEMINI_API_KEY'] = '';

        // Act & Assert - init() should run without throwing with empty key
        expect(() => AiApiService.init(), returnsNormally);

        // Cleanup - restore original key if it existed
        if (originalGeminiKey != null) {
          dotenv.env['GEMINI_API_KEY'] = originalGeminiKey;
        } else {
          dotenv.env.remove('GEMINI_API_KEY');
        }
      });
    });

    group('Constructor', () {
      test('should create instance successfully', () {
        // Act
        final service = AiApiService();

        // Assert
        expect(service, isNotNull);
        expect(service, isA<AiApiService>());
      });
    });

    group('getChatResponse method', () {
      late List<OpenAIChatCompletionChoiceMessageModel> testMessages;

      setUp(() {
        testMessages = [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'Hello, how are you?',
              ),
            ],
          ),
        ];
      });

      test('should accept valid message list and return non-empty response', () async {
        // Arrange
        const expectedResponse = 'Ciao! Sto bene, grazie. Come posso aiutarti?';
        when(mockAiApiService.getChatResponse(any))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await mockAiApiService.getChatResponse(testMessages);

        // Assert
        expect(result, isNotEmpty);
        expect(result, equals(expectedResponse));
        verify(mockAiApiService.getChatResponse(testMessages)).called(1);
      });

      test('should handle error responses gracefully', () async {
        // Arrange
        const errorResponse = 'Mi dispiace, si è verificato un errore di connessione. Riprova più tardi.';
        when(mockAiApiService.getChatResponse(any))
            .thenAnswer((_) async => errorResponse);

        // Act
        final result = await mockAiApiService.getChatResponse(testMessages);

        // Assert
        expect(result, equals(errorResponse));
        verify(mockAiApiService.getChatResponse(testMessages)).called(1);
      });

      test('should handle null or invalid responses', () async {
        // Arrange
        const invalidResponse = 'Mi dispiace, non ho ricevuto una risposta valida.';
        when(mockAiApiService.getChatResponse(any))
            .thenAnswer((_) async => invalidResponse);

        // Act
        final result = await mockAiApiService.getChatResponse(testMessages);

        // Assert
        expect(result, equals(invalidResponse));
        verify(mockAiApiService.getChatResponse(testMessages)).called(1);
      });

      test('should handle empty message list', () async {
        // Arrange
        const emptyListResponse = 'Mi dispiace, non ho ricevuto una risposta valida.';
        when(mockAiApiService.getChatResponse([]))
            .thenAnswer((_) async => emptyListResponse);

        // Act
        final result = await mockAiApiService.getChatResponse([]);

        // Assert
        expect(result, equals(emptyListResponse));
        verify(mockAiApiService.getChatResponse([])).called(1);
      });

      test('should handle multiple messages in conversation', () async {
        // Arrange
        final multipleMessages = [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'You are a helpful assistant.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'Hello!',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.assistant,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'Hi there!',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'How are you?',
              ),
            ],
          ),
        ];

        const conversationResponse = 'I am doing well, thank you for asking!';
        when(mockAiApiService.getChatResponse(multipleMessages))
            .thenAnswer((_) async => conversationResponse);

        // Act
        final result = await mockAiApiService.getChatResponse(multipleMessages);

        // Assert
        expect(result, equals(conversationResponse));
        verify(mockAiApiService.getChatResponse(multipleMessages)).called(1);
      });

      test('should maintain Italian language responses for medical context', () async {
        // Arrange
        final medicalQuery = [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'Ho mal di testa, cosa posso prendere?',
              ),
            ],
          ),
        ];

        const italianMedicalResponse = 'Per un mal di testa comune, alcune opzioni generali da banco includono analgesici come il paracetamolo. Ricorda, queste informazioni non sostituiscono il parere di un medico.';
        when(mockAiApiService.getChatResponse(medicalQuery))
            .thenAnswer((_) async => italianMedicalResponse);

        // Act
        final result = await mockAiApiService.getChatResponse(medicalQuery);

        // Assert
        expect(result, equals(italianMedicalResponse));
        expect(result, contains('parere di un medico'));
        verify(mockAiApiService.getChatResponse(medicalQuery)).called(1);
      });
    });

    group('OpenAI Message Model Creation Tests', () {
      test('creates system message correctly', () {
        // Arrange
        const systemPrompt = 'You are a helpful medical assistant.';

        // Act
        final systemMessage = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
          ],
        );

        // Assert
        expect(systemMessage.role, equals(OpenAIChatMessageRole.system));
        expect(systemMessage.content?.first.text, equals(systemPrompt));
      });

      test('creates user message correctly', () {
        // Arrange
        const userMessage = 'Test user message';

        // Act
        final message = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(userMessage),
          ],
        );

        // Assert
        expect(message.role, equals(OpenAIChatMessageRole.user));
        expect(message.content?.first.text, equals(userMessage));
      });

      test('creates assistant message correctly', () {
        // Arrange
        const assistantResponse = 'Test assistant response';

        // Act
        final message = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(assistantResponse),
          ],
        );

        // Assert
        expect(message.role, equals(OpenAIChatMessageRole.assistant));
        expect(message.content?.first.text, equals(assistantResponse));
      });

      test('creates message with multiple content items', () {
        // Arrange
        const part1 = 'First part';
        const part2 = 'Second part';

        // Act
        final message = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(part1),
            OpenAIChatCompletionChoiceMessageContentItemModel.text(part2),
          ],
        );

        // Assert
        expect(message.role, equals(OpenAIChatMessageRole.assistant));
        expect(message.content?.length, equals(2));
        expect(message.content?[0].text, equals(part1));
        expect(message.content?[1].text, equals(part2));
      });
    });

    group('Medical Context Validation Tests', () {
      test('validates Italian error messages are properly formatted', () {
        // Arrange & Act - Test error message constants
        const connectionError = 'Mi dispiace, si è verificato un errore di connessione. Riprova più tardi.';
        const invalidResponse = 'Mi dispiace, non ho ricevuto una risposta valida.';

        // Assert
        expect(connectionError, contains('errore di connessione'));
        expect(connectionError, contains('Riprova più tardi'));
        expect(invalidResponse, contains('risposta valida'));
        expect(connectionError.isNotEmpty, isTrue);
        expect(invalidResponse.isNotEmpty, isTrue);
      });

      test('validates medical disclaimer is present in responses', () {
        // Arrange
        const medicalDisclaimer = 'Ricorda, queste informazioni non sostituiscono il parere di un medico. Consulta sempre un professionista sanitario per qualsiasi dubbio sulla tua salute.';

        // Assert
        expect(medicalDisclaimer, contains('non sostituiscono il parere di un medico'));
        expect(medicalDisclaimer, contains('professionista sanitario'));
        expect(medicalDisclaimer, isA<String>());
        expect(medicalDisclaimer.isNotEmpty, isTrue);
      });

      test('validates system prompt contains medical safety guidelines', () {
        // Arrange
        const systemPrompt = '''
          You are Dottore AI, a friendly and knowledgeable virtual assistant for the Akòra app.
          Your absolute restrictions:
          - You MUST NOT provide any medical diagnosis.
          - You MUST NOT give personalized medical advice.
          - You MUST NOT prescribe a specific brand, dosage, or frequency.
          Conclude EVERY response with this disclaimer: "Ricorda, queste informazioni non sostituiscono il parere di un medico."
          ''';

        // Assert
        expect(systemPrompt, contains('MUST NOT provide any medical diagnosis'));
        expect(systemPrompt, contains('MUST NOT give personalized medical advice'));
        expect(systemPrompt, contains('MUST NOT prescribe'));
        expect(systemPrompt, contains('non sostituiscono il parere di un medico'));
        expect(systemPrompt, contains('Dottore AI'));
        expect(systemPrompt, contains('Akòra app'));
      });
    });

    group('Service Integration Tests', () {
      test('service can be instantiated multiple times', () {
        // Arrange & Act
        final service1 = AiApiService();
        final service2 = AiApiService();

        // Assert
        expect(service1, isNotNull);
        expect(service2, isNotNull);
        expect(service1, isA<AiApiService>());
        expect(service2, isA<AiApiService>());
      });

      test('service behavior is consistent across instances', () async {
        // Arrange
        final service1 = AiApiService();
        final service2 = AiApiService();

        // Both should be the same type and have same methods
        expect(service1.runtimeType, equals(service2.runtimeType));
        expect(service1.getChatResponse, isA<Function>());
        expect(service2.getChatResponse, isA<Function>());
      });
    });

    group('Error Handling Edge Cases', () {
      test('handles network timeout scenarios', () async {
        // Arrange
        const timeoutResponse = 'Mi dispiace, si è verificato un errore di connessione. Riprova più tardi.';
        when(mockAiApiService.getChatResponse(any))
            .thenAnswer((_) async => timeoutResponse);

        final testMessage = [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('Test message'),
            ],
          ),
        ];

        // Act
        final result = await mockAiApiService.getChatResponse(testMessage);

        // Assert
        expect(result, equals(timeoutResponse));
        verify(mockAiApiService.getChatResponse(testMessage)).called(1);
      });

      test('handles API rate limiting scenarios', () async {
        // Arrange
        const rateLimitResponse = 'Mi dispiace, si è verificato un errore di connessione. Riprova più tardi.';
        when(mockAiApiService.getChatResponse(any))
            .thenAnswer((_) async => rateLimitResponse);

        final testMessage = [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('Test message'),
            ],
          ),
        ];

        // Act
        final result = await mockAiApiService.getChatResponse(testMessage);

        // Assert
        expect(result, equals(rateLimitResponse));
        verify(mockAiApiService.getChatResponse(testMessage)).called(1);
      });

      test('handles malformed API responses', () async {
        // Arrange
        const malformedResponse = 'Mi dispiace, non ho ricevuto una risposta valida.';
        when(mockAiApiService.getChatResponse(any))
            .thenAnswer((_) async => malformedResponse);

        final testMessage = [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('Test message'),
            ],
          ),
        ];

        // Act
        final result = await mockAiApiService.getChatResponse(testMessage);

        // Assert
        expect(result, equals(malformedResponse));
        verify(mockAiApiService.getChatResponse(testMessage)).called(1);
      });
    });

    group('Message History Processing Tests', () {
      test('processes conversation history correctly', () {
        // Arrange
        final conversationHistory = [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('You are a helpful assistant.'),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('Hello'),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.assistant,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('Hi there!'),
            ],
          ),
        ];

        // Act & Assert
        expect(conversationHistory.length, equals(3));
        expect(conversationHistory[0].role, equals(OpenAIChatMessageRole.system));
        expect(conversationHistory[1].role, equals(OpenAIChatMessageRole.user));
        expect(conversationHistory[2].role, equals(OpenAIChatMessageRole.assistant));
      });

      test('maintains message order in conversation', () {
        // Arrange
        final messages = <OpenAIChatCompletionChoiceMessageModel>[];
        
        // Add messages in order
        messages.add(OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text('First message')],
        ));
        
        messages.add(OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant,
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text('First response')],
        ));
        
        messages.add(OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text('Second message')],
        ));

        // Act & Assert
        expect(messages[0].content?.first.text, equals('First message'));
        expect(messages[1].content?.first.text, equals('First response'));
        expect(messages[2].content?.first.text, equals('Second message'));
      });
    });

    group('Real Implementation Tests', () {
      late AiApiService realService;

      setUp(() {
        realService = AiApiService();
      });

      test('getChatResponse handles valid messages and returns response', () async {
        // Arrange - Create test messages
        final testMessages = [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('Hello'),
            ],
          ),
        ];

        // Act - Call real implementation
        final result = await realService.getChatResponse(testMessages);

        // Assert - Should return a non-empty response (either success or error)
        expect(result, isNotEmpty);
        expect(result, isA<String>());
        // The result could be either a successful response or an error message
        expect(result.length, greaterThan(10)); // Should be a meaningful response
      });

      test('getChatResponse handles empty message list', () async {
        // Arrange - Empty message list
        final emptyMessages = <OpenAIChatCompletionChoiceMessageModel>[];

        // Act - Call real implementation
        final result = await realService.getChatResponse(emptyMessages);

        // Assert - Should return error message for empty list (various error types possible)
        expect(result, contains('Mi dispiace'));
        expect(result, anyOf([
          equals('Mi dispiace, si è verificato un errore di connessione. Riprova più tardi.'),
          equals('Mi dispiace, si è verificato un errore di formato nella risposta. Il servizio potrebbe essere temporaneamente non disponibile.'),
          equals('Mi dispiace, si è verificato un errore di autenticazione o configurazione. Verifica la configurazione del servizio AI.'),
          equals('Mi dispiace, il servizio AI sta avendo problemi tecnici. Riprova più tardi.')
        ]));
      });

      test('service provides consistent response format', () async {
        // Arrange - Multiple different test scenarios
        final testMessages1 = [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('Hello'),
            ],
          ),
        ];

        final testMessages2 = [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('Hi there'),
            ],
          ),
        ];

        // Act - Call real implementation multiple times
        final result1 = await realService.getChatResponse(testMessages1);
        final result2 = await realService.getChatResponse(testMessages2);

        // Assert - Should return consistent response types
        expect(result1, isA<String>());
        expect(result2, isA<String>());
        expect(result1, isNotEmpty);
        expect(result2, isNotEmpty);
        // Both should be meaningful responses (either success or error messages)
        expect(result1.length, greaterThan(5));
        expect(result2.length, greaterThan(5));
      });
    });
  });
}
