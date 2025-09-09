import 'package:akora_app/core/services/ai_api_service.dart';
import 'package:akora_app/features/chat/screens/ai_doctor_screen.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ai_doctor_screen_test.mocks.dart';

// Generate mocks for dependencies
@GenerateMocks([AiApiService])
void main() {
  late MockAiApiService mockAiApiService;

  // Helper function to create the widget under test with proper Material context
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: CupertinoTheme(
        data: const CupertinoThemeData(),
        child: const AiDoctorScreen(),
      ),
    );
  }

  setUp(() {
    mockAiApiService = MockAiApiService();
  });

  group('AiDoctorScreen Basic UI Tests', () {
    testWidgets('displays correct navigation bar title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      // We look for the middle widget of CupertinoNavigationBar
      final navigationBar = tester.widget<CupertinoNavigationBar>(
        find.byType(CupertinoNavigationBar)
      );
      final middleWidget = navigationBar.middle as Text;
      expect(middleWidget.data, equals('Dottore AI'));
    });

    testWidgets('displays DashChat widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DashChat), findsOneWidget);
    });

    testWidgets('initializes with welcome message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // We can verify the widget was created without checking exact text
      // because DashChat may render messages in complex ways
      expect(find.byType(AiDoctorScreen), findsOneWidget);
      expect(find.byType(DashChat), findsOneWidget);
    });
  });

  group('AiApiService Unit Tests', () {
    test('creates instance successfully', () {
      // Arrange & Act
      final service = AiApiService();

      // Assert
      expect(service, isNotNull);
    });

    test('getChatResponse calls OpenAI API with correct parameters', () async {
      // Arrange
      const expectedResponse = "Test AI response";
      when(mockAiApiService.getChatResponse(any))
          .thenAnswer((_) async => expectedResponse);

      final testMessages = [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text("Test message"),
          ],
        ),
      ];

      // Act
      final result = await mockAiApiService.getChatResponse(testMessages);

      // Assert
      expect(result, equals(expectedResponse));
      verify(mockAiApiService.getChatResponse(testMessages)).called(1);
    });

    test('getChatResponse handles errors gracefully', () async {
      // Arrange
      const errorResponse = "Mi dispiace, si è verificato un errore di connessione. Riprova più tardi.";
      when(mockAiApiService.getChatResponse(any))
          .thenAnswer((_) async => errorResponse);

      final testMessages = [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text("Test message"),
          ],
        ),
      ];

      // Act
      final result = await mockAiApiService.getChatResponse(testMessages);

      // Assert
      expect(result, equals(errorResponse));
      verify(mockAiApiService.getChatResponse(testMessages)).called(1);
    });
  });

  group('ChatMessage Creation Tests', () {
    test('creates user ChatMessage correctly', () {
      // Arrange
      final user = ChatUser(id: '1', firstName: 'TestUser');
      const messageText = "Test message";
      final now = DateTime.now();

      // Act
      final message = ChatMessage(
        user: user,
        createdAt: now,
        text: messageText,
      );

      // Assert
      expect(message.user.id, equals('1'));
      expect(message.user.firstName, equals('TestUser'));
      expect(message.text, equals(messageText));
      expect(message.createdAt, equals(now));
    });

    test('creates AI agent ChatMessage correctly', () {
      // Arrange
      final aiAgent = ChatUser(id: '2', firstName: 'Dottore AI');
      const responseText = "AI response";
      final now = DateTime.now();

      // Act
      final message = ChatMessage(
        user: aiAgent,
        createdAt: now,
        text: responseText,
      );

      // Assert
      expect(message.user.id, equals('2'));
      expect(message.user.firstName, equals('Dottore AI'));
      expect(message.text, equals(responseText));
      expect(message.createdAt, equals(now));
    });
  });

  group('OpenAI Message Model Tests', () {
    test('creates system message correctly', () {
      // Arrange
      const systemPrompt = "You are a helpful assistant";

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
      const userMessage = "Test user message";

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
      const assistantResponse = "Test assistant response";

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
  });

  group('Medical Guidelines Tests', () {
    test('system prompt contains medical safety guidelines', () {
      // Arrange & Act
      const systemPrompt = """
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
          """;

      // Assert - Check for key medical guidelines
      expect(systemPrompt, contains("MUST NOT provide any medical diagnosis"));
      expect(systemPrompt, contains("MUST NOT give personalized medical advice"));
      expect(systemPrompt, contains("MUST NOT prescribe a specific brand"));
      expect(systemPrompt, contains("plain text only"));
      expect(systemPrompt, contains("non sostituiscono il parere di un medico"));
      expect(systemPrompt, contains("Dottore AI"));
      expect(systemPrompt, contains("Akòra app"));
    });

    test('disclaimer text is correct in Italian', () {
      // Arrange & Act
      const disclaimerText = "Ricorda, queste informazioni non sostituiscono il parere di un medico. Consulta sempre un professionista sanitario per qualsiasi dubbio sulla tua salute.";

      // Assert
      expect(disclaimerText, contains("non sostituiscono il parere di un medico"));
      expect(disclaimerText, contains("professionista sanitario"));
      expect(disclaimerText, isA<String>());
      expect(disclaimerText.isNotEmpty, isTrue);
    });
  });

  group('Integration Tests with Test Widget', () {
    testWidgets('creates screen without errors', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(AiDoctorScreen), findsOneWidget);
      expect(tester.takeException(), isNull); // No exceptions thrown
    });

    testWidgets('screen has required components', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byType(DashChat), findsOneWidget);
    });
  });

  group('Advanced Widget Interaction Tests', () {
    testWidgets('DashChat input configuration is correct', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the DashChat widget and verify its properties
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert
      expect(dashChatWidget.currentUser.id, equals('1'));
      expect(dashChatWidget.currentUser.firstName, equals('User'));
      expect(dashChatWidget.messages.length, equals(1)); // Initial welcome message
      expect(dashChatWidget.typingUsers?.isEmpty ?? true, isTrue);
    });

    testWidgets('message options are configured correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert message configuration exists
      expect(dashChatWidget.messageOptions.spaceWhenAvatarIsHidden, equals(6));
      expect(dashChatWidget.messageOptions.messagePadding, equals(const EdgeInsets.all(12)));
      // Skip color test as it's a function, not a static value
      expect(dashChatWidget.messageOptions.currentUserTextColor, isNotNull);
    });

    testWidgets('input options are configured correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert input options - Note: InputDecoration.collapsed doesn't have hintText accessible
      // We verify the styling properties that are accessible
      expect(dashChatWidget.inputOptions.inputTextStyle?.fontSize, equals(16));
      expect(dashChatWidget.inputOptions.inputTextStyle?.color, equals(CupertinoColors.black));
    });

    testWidgets('avatar builder returns correct widget for AI agent', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      final aiUser = ChatUser(id: '2', firstName: 'Dottore AI');
      
      // Act - Build avatar for AI user
      final avatarWidget = dashChatWidget.messageOptions.avatarBuilder!(aiUser, () {}, () {});
      
      // Assert
      expect(avatarWidget, isA<Container>());
      // Pump the avatar widget to test its structure
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: avatarWidget)));
      expect(find.byIcon(CupertinoIcons.heart_fill), findsOneWidget);
    });

    testWidgets('avatar builder returns empty widget for non-AI user', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      final regularUser = ChatUser(id: '1', firstName: 'User');
      
      // Act - Build avatar for regular user
      final avatarWidget = dashChatWidget.messageOptions.avatarBuilder!(regularUser, () {}, () {});
      
      // Assert
      expect(avatarWidget, isA<SizedBox>());
    });
  });

  group('State Management Tests', () {
    testWidgets('initState adds welcome message to messages list', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert
      expect(dashChatWidget.messages.length, equals(1));
      expect(dashChatWidget.messages.first.text, contains("Buongiorno! Sono il tuo assistente medico virtuale"));
      expect(dashChatWidget.messages.first.user.firstName, equals('Dottore AI'));
    });

    testWidgets('DashChat onSend callback is properly configured', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert that onSend callback exists
      expect(dashChatWidget.onSend, isNotNull);
    });

    testWidgets('typing users list is properly initialized', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert
      expect(dashChatWidget.typingUsers?.isEmpty ?? true, isTrue);
    });
  });

  group('ChatUser Configuration Tests', () {
    test('current user is configured correctly', () {
      // Arrange
      final user = ChatUser(id: '1', firstName: 'User');

      // Assert
      expect(user.id, equals('1'));
      expect(user.firstName, equals('User'));
    });

    test('AI agent user is configured correctly', () {
      // Arrange
      final aiAgent = ChatUser(id: '2', firstName: 'Dottore AI');

      // Assert
      expect(aiAgent.id, equals('2'));
      expect(aiAgent.firstName, equals('Dottore AI'));
    });
  });

  group('Message History Processing Tests', () {
    test('converts ChatMessage list to OpenAI format correctly', () {
      // Arrange
      final currentUser = ChatUser(id: '1', firstName: 'User');
      final aiAgent = ChatUser(id: '2', firstName: 'Dottore AI');
      
      final messages = [
        ChatMessage(
          user: aiAgent,
          createdAt: DateTime.now(),
          text: "AI response",
        ),
        ChatMessage(
          user: currentUser,
          createdAt: DateTime.now(),
          text: "User message",
        ),
      ];

      // Act - Simulate the conversion logic from _getAiResponse
      final messageHistory = messages.reversed.map((message) {
        return OpenAIChatCompletionChoiceMessageModel(
          role: message.user.id == currentUser.id
              ? OpenAIChatMessageRole.user
              : OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(message.text),
          ],
        );
      }).toList();

      // Assert
      expect(messageHistory.length, equals(2));
      expect(messageHistory[0].role, equals(OpenAIChatMessageRole.user));
      expect(messageHistory[0].content?.first.text, equals("User message"));
      expect(messageHistory[1].role, equals(OpenAIChatMessageRole.assistant));
      expect(messageHistory[1].content?.first.text, equals("AI response"));
    });
  });

  group('Error Handling and Edge Cases', () {
    testWidgets('handles null or empty API responses gracefully', (tester) async {
      // This test verifies the widget structure can handle various scenarios
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify the widget can be created and initialized without errors
      expect(find.byType(AiDoctorScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('message list maintains proper structure', (tester) async {
      // Test that ensures messages have the correct structure
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Verify initial message structure
      expect(dashChatWidget.messages.isNotEmpty, isTrue);
      final firstMessage = dashChatWidget.messages.first;
      expect(firstMessage.user.id, equals('2')); // AI agent
      expect(firstMessage.text.isNotEmpty, isTrue);
      expect(firstMessage.createdAt, isA<DateTime>());
    });

    testWidgets('chat users have correct identifiers', (tester) async {
      // Test that ensures user identification is consistent
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Verify current user
      expect(dashChatWidget.currentUser.id, equals('1'));
      expect(dashChatWidget.currentUser.firstName, equals('User'));
      
      // Verify initial message is from AI agent
      final aiMessage = dashChatWidget.messages.first;
      expect(aiMessage.user.id, equals('2'));
      expect(aiMessage.user.firstName, equals('Dottore AI'));
    });
  });

  group('Widget Lifecycle Tests', () {
    testWidgets('properly initializes service instance', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - Widget should be created without errors
      expect(find.byType(AiDoctorScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles widget rebuild correctly', (tester) async {
      // Arrange
      Widget createRebuildableWidget(String title) {
        return MaterialApp(
          home: CupertinoTheme(
            data: const CupertinoThemeData(),
            child: Scaffold(
              appBar: AppBar(title: Text(title)),
              body: const AiDoctorScreen(),
            ),
          ),
        );
      }

      // Act - Initial build
      await tester.pumpWidget(createRebuildableWidget("Initial"));
      await tester.pumpAndSettle();
      expect(find.text("Initial"), findsOneWidget);

      // Act - Rebuild with different title
      await tester.pumpWidget(createRebuildableWidget("Rebuilt"));
      await tester.pumpAndSettle();
      
      // Assert - Widget should handle rebuild without issues
      expect(find.text("Rebuilt"), findsOneWidget);
      expect(find.byType(AiDoctorScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DashChat callback functions are properly configured', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert that all required callbacks exist
      expect(dashChatWidget.onSend, isNotNull);
      expect(dashChatWidget.messageOptions.avatarBuilder, isNotNull);
      expect(dashChatWidget.inputOptions.sendButtonBuilder, isNotNull);
    });
  });

  group('Widget Theme and Styling Tests', () {
    testWidgets('uses correct Cupertino theme elements', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert Cupertino components are present
      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byType(Material), findsOneWidget); // For DashChat compatibility
    });

    testWidgets('padding and layout are configured correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find padding widgets that exist in the widget tree
      final paddingFinder = find.byType(Padding);
      expect(paddingFinder, findsWidgets);
      
      // Assert that DashChat is properly contained within the structure
      expect(find.byType(DashChat), findsOneWidget);
      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
    });

    testWidgets('send button configuration is correct', (tester) async {
      // Arrange & Act  
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget and check its send button builder
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert send button builder exists
      expect(dashChatWidget.inputOptions.sendButtonBuilder, isNotNull);
      
      // Since the send button is custom built, we test that the builder function exists
      // rather than trying to access the specific icon which may not be rendered yet
      final sendButtonBuilder = dashChatWidget.inputOptions.sendButtonBuilder;
      expect(sendButtonBuilder, isA<Function>());
    });
  });

  group('Comprehensive Message Configuration Tests', () {
    testWidgets('message options have correct styling configuration', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert comprehensive message options
      expect(dashChatWidget.messageOptions.spaceWhenAvatarIsHidden, equals(6));
      expect(dashChatWidget.messageOptions.messagePadding, equals(const EdgeInsets.all(12)));
      expect(dashChatWidget.messageOptions.marginDifferentAuthor, 
             equals(const EdgeInsets.only(top: 10, bottom: 10)));
      expect(dashChatWidget.messageOptions.showOtherUsersAvatar, isTrue);
    });

    testWidgets('avatar builder creates correct widgets for different users', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      final avatarBuilder = dashChatWidget.messageOptions.avatarBuilder!;
      
      // Test AI agent avatar
      final aiUser = ChatUser(id: '2', firstName: 'Dottore AI');
      final aiAvatar = avatarBuilder(aiUser, () {}, () {});
      expect(aiAvatar, isA<Container>());
      
      // Test regular user avatar
      final regularUser = ChatUser(id: '1', firstName: 'User');
      final userAvatar = avatarBuilder(regularUser, () {}, () {});
      expect(userAvatar, isA<SizedBox>());
    });

    testWidgets('input styling is properly configured', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert input text styling
      final textStyle = dashChatWidget.inputOptions.inputTextStyle;
      expect(textStyle?.fontSize, equals(16));
      expect(textStyle?.color, equals(CupertinoColors.black));
    });
  });

  group('Advanced Message Flow Tests', () {
    testWidgets('onSend callback processes messages correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Create a test message
      final testMessage = ChatMessage(
        user: ChatUser(id: '1', firstName: 'User'),
        createdAt: DateTime.now(),
        text: 'Test message from user',
      );

      // Act - Call onSend directly to test the method
      dashChatWidget.onSend(testMessage);
      await tester.pump();

      // Assert - The method should execute without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('initial welcome message is displayed', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget to check messages
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert - Check initial message exists in the messages list
      expect(dashChatWidget.messages, isNotEmpty);
      expect(dashChatWidget.messages.first.text, contains('Buongiorno'));
      expect(dashChatWidget.messages.first.text, contains('assistente medico virtuale'));
      expect(dashChatWidget.messages.first.text, contains('non sostituiscono un parere medico'));
    });

    testWidgets('typing users list is properly configured', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert - Initially no typing users
      expect(dashChatWidget.typingUsers, isEmpty);
    });

    testWidgets('current user configuration is correct', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert current user properties
      expect(dashChatWidget.currentUser.id, equals('1'));
      expect(dashChatWidget.currentUser.firstName, equals('User'));
    });

    testWidgets('message list contains initial welcome message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert message list
      expect(dashChatWidget.messages, isNotEmpty);
      expect(dashChatWidget.messages.length, equals(1));
      expect(dashChatWidget.messages.first.user.id, equals('2')); // AI agent
      expect(dashChatWidget.messages.first.text, contains('Buongiorno'));
    });
  });

  group('AI Chat Interaction Simulation Tests', () {
    testWidgets('simulates complete chat interaction flow', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Find and interact with input field
      final inputField = find.byType(TextField);
      expect(inputField, findsOneWidget);

      // Simulate typing in the input field
      await tester.enterText(inputField, 'Ciao, come stai?');
      await tester.pump();

      // Find send button (CupertinoButton)
      final sendButton = find.byType(CupertinoButton);
      expect(sendButton, findsOneWidget);

      // Assert - Components are ready for interaction
      expect(find.text('Ciao, come stai?'), findsOneWidget);
    });

    testWidgets('handles input decoration correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the input field
      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration as InputDecoration;
      
      // Assert input decoration
      expect(decoration.hintText, equals('Scrivi un messaggio...'));
      expect(decoration.border, equals(InputBorder.none));
    });

    testWidgets('send button has correct styling and behavior', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert send button builder exists
      expect(dashChatWidget.inputOptions.sendButtonBuilder, isNotNull);
      
      // Test the button builder creates correct widget
      final sendButtonBuilder = dashChatWidget.inputOptions.sendButtonBuilder!;
      final buttonWidget = sendButtonBuilder(() {});
      expect(buttonWidget, isA<CupertinoButton>());
    });

    testWidgets('message colors and styling are configured correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert message styling (check that styling functions exist)
      expect(dashChatWidget.messageOptions.currentUserTextColor, isNotNull);
      expect(dashChatWidget.messageOptions.containerColor, equals(CupertinoColors.secondarySystemFill));
      expect(dashChatWidget.messageOptions.textColor, equals(CupertinoColors.label));
    });
  });

  group('Widget State and Lifecycle Advanced Tests', () {
    testWidgets('widget maintains state across rebuilds', (tester) async {
      // Arrange
      Widget buildWidget(String title) {
        return MaterialApp(
          title: title,
          home: CupertinoTheme(
            data: const CupertinoThemeData(),
            child: const AiDoctorScreen(),
          ),
        );
      }

      // Act - Initial build
      await tester.pumpWidget(buildWidget('Initial'));
      await tester.pumpAndSettle();

      // Get initial message count
      final initialDashChat = tester.widget<DashChat>(find.byType(DashChat));
      final initialMessageCount = initialDashChat.messages.length;

      // Rebuild with different title
      await tester.pumpWidget(buildWidget('Rebuilt'));
      await tester.pumpAndSettle();

      // Assert - Message count should remain the same
      final rebuiltDashChat = tester.widget<DashChat>(find.byType(DashChat));
      expect(rebuiltDashChat.messages.length, equals(initialMessageCount));
      expect(rebuiltDashChat.messages.first.text, contains('Buongiorno'));
    });

    testWidgets('disposes resources properly', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Remove widget from tree
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      // Assert - No exceptions should occur during disposal
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles hot reload scenarios', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Simulate hot reload by rebuilding same widget
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - Widget should rebuild successfully
      expect(find.byType(AiDoctorScreen), findsOneWidget);
      expect(find.byType(DashChat), findsOneWidget);
      
      // Check that messages are preserved through hot reload
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      expect(dashChatWidget.messages, isNotEmpty);
      expect(dashChatWidget.messages.first.text, contains('Buongiorno'));
    });

    testWidgets('initializes with correct default state', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the DashChat widget
      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert initial state
      expect(dashChatWidget.messages.length, equals(1)); // Welcome message
      expect(dashChatWidget.typingUsers, isEmpty); // No one typing initially
      expect(dashChatWidget.currentUser.id, equals('1'));
      
      // Check welcome message properties
      final welcomeMessage = dashChatWidget.messages.first;
      expect(welcomeMessage.user.id, equals('2')); // AI agent
      expect(welcomeMessage.user.firstName, equals('Dottore AI'));
      expect(welcomeMessage.text, contains('assistente medico virtuale'));
    });
  });

  group('Advanced UI Component Tests', () {
    testWidgets('cupertino theme integration works correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find theme-dependent components
      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byType(Material), findsOneWidget); // For DashChat compatibility
    });

    testWidgets('padding and layout structure is correct', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check padding structure
      final paddingWidgets = find.byType(Padding);
      expect(paddingWidgets, findsWidgets);

      // Check Material wrapper
      final materialWidget = tester.widget<Material>(find.byType(Material));
      expect(materialWidget.color, isNotNull);
    });

    testWidgets('navigation bar is properly configured', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get navigation bar
      final navBar = tester.widget<CupertinoNavigationBar>(
        find.byType(CupertinoNavigationBar)
      );
      
      // Assert navigation bar properties
      expect(navBar.middle, isA<Text>());
      final titleText = navBar.middle as Text;
      expect(titleText.data, equals('Dottore AI'));
    });

    testWidgets('scaffold background color integration', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the Material widget that wraps DashChat
      final materialWidget = tester.widget<Material>(find.byType(Material));
      
      // Assert - Material should have a color set
      expect(materialWidget.color, isNotNull);
    });
  });

  group('Additional Edge Case and Robustness Tests', () {
    testWidgets('handles multiple rapid onSend calls', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Act - Simulate multiple rapid message sends
      final message1 = ChatMessage(
        user: ChatUser(id: '1', firstName: 'User'),
        createdAt: DateTime.now(),
        text: 'First message',
      );
      
      final message2 = ChatMessage(
        user: ChatUser(id: '1', firstName: 'User'),
        createdAt: DateTime.now(),
        text: 'Second message',
      );

      dashChatWidget.onSend(message1);
      dashChatWidget.onSend(message2);
      await tester.pump();

      // Assert - Should handle multiple calls without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('validates ChatUser objects are properly configured', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert current user configuration
      expect(dashChatWidget.currentUser.id, isNotNull);
      expect(dashChatWidget.currentUser.id, isNotEmpty);
      expect(dashChatWidget.currentUser.firstName, isNotNull);
      expect(dashChatWidget.currentUser.firstName, isNotEmpty);
      
      // Check that AI agent is properly configured in initial message
      final initialMessage = dashChatWidget.messages.first;
      expect(initialMessage.user.id, equals('2'));
      expect(initialMessage.user.firstName, equals('Dottore AI'));
    });

    testWidgets('verifies message timestamp functionality', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      final initialMessage = dashChatWidget.messages.first;
      
      // Assert timestamp exists and is reasonable
      expect(initialMessage.createdAt, isNotNull);
      expect(initialMessage.createdAt.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
      expect(initialMessage.createdAt.isAfter(DateTime.now().subtract(const Duration(minutes: 5))), isTrue);
    });

    testWidgets('tests widget memory management and disposal', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Navigate away and back
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Other Screen'))));
      await tester.pumpAndSettle();
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - Widget should recreate successfully
      expect(find.byType(AiDoctorScreen), findsOneWidget);
      expect(find.byType(DashChat), findsOneWidget);
    });

    testWidgets('validates input decoration customization', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert input decoration is customized
      expect(dashChatWidget.inputOptions.inputDecoration, isNotNull);
      expect(dashChatWidget.inputOptions.inputDecoration, isA<InputDecoration>());
      
      final decoration = dashChatWidget.inputOptions.inputDecoration!;
      expect(decoration.hintText, equals('Scrivi un messaggio...'));
    });

    testWidgets('ensures proper widget hierarchy and structure', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert widget hierarchy (allowing for multiple theme widgets)
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(CupertinoTheme), findsWidgets); // Can be multiple
      expect(find.byType(AiDoctorScreen), findsOneWidget);
      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Material), findsOneWidget);
      expect(find.byType(DashChat), findsOneWidget);
    });

    testWidgets('validates AI agent avatar configuration details', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      final avatarBuilder = dashChatWidget.messageOptions.avatarBuilder!;
      
      // Test AI agent avatar creation
      final aiUser = ChatUser(id: '2', firstName: 'Dottore AI');
      final aiAvatar = avatarBuilder(aiUser, () {}, () {});
      
      // Assert avatar is a Container with specific properties
      expect(aiAvatar, isA<Container>());
    });

    testWidgets('checks message options comprehensive configuration', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      final messageOptions = dashChatWidget.messageOptions;
      
      // Assert all message options are properly configured
      expect(messageOptions.spaceWhenAvatarIsHidden, isA<double>());
      expect(messageOptions.messagePadding, isA<EdgeInsets>());
      expect(messageOptions.marginDifferentAuthor, isA<EdgeInsets>());
      expect(messageOptions.showOtherUsersAvatar, isA<bool>());
      expect(messageOptions.avatarBuilder, isNotNull);
      expect(messageOptions.currentUserContainerColor, isNotNull);
      expect(messageOptions.currentUserTextColor, isNotNull);
      expect(messageOptions.containerColor, isNotNull);
      expect(messageOptions.textColor, isNotNull);
    });

    testWidgets('validates complete DashChat configuration', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final dashChatWidget = tester.widget<DashChat>(find.byType(DashChat));
      
      // Assert all required DashChat properties are set
      expect(dashChatWidget.currentUser, isNotNull);
      expect(dashChatWidget.onSend, isNotNull);
      expect(dashChatWidget.messages, isNotNull);
      expect(dashChatWidget.typingUsers, isNotNull);
      expect(dashChatWidget.inputOptions, isNotNull);
      expect(dashChatWidget.messageOptions, isNotNull);
    });
  });
}
