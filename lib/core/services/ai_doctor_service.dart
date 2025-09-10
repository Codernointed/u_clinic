import 'dart:convert';
import 'package:http/http.dart' as http;

class AIDoctorService {
  static const String _apiKey = 'AIzaSyC_iVAGdmwlszToZOawkyInMc497Wd3hQE';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static final AIDoctorService _instance = AIDoctorService._internal();
  factory AIDoctorService() => _instance;
  AIDoctorService._internal();

  Future<String> chatWithAIDoctor(
    String userMessage, {
    String? conversationHistory,
  }) async {
    print('🤖 AI Doctor Service - Starting chat');
    print('📝 User message: "$userMessage"');
    print('📚 Conversation history: ${conversationHistory ?? "None"}');

    try {
      // Build conversation context
      final List<Map<String, dynamic>> conversationParts = [];

      // Add system prompt
      conversationParts.add({
        "role": "user",
        "parts": [
          {"text": _getSystemPrompt()},
        ],
      });

      conversationParts.add({
        "role": "model",
        "parts": [
          {
            "text":
                "Hello! I'm Dr. AI, your friendly health assistant at UMaT E-Health. I'm here to help with general health questions and wellness guidance. How can I assist you today?",
          },
        ],
      });

      // Add conversation history if available
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        conversationParts.add({
          "role": "user",
          "parts": [
            {"text": conversationHistory},
          ],
        });
      }

      // Add current user message
      conversationParts.add({
        "role": "user",
        "parts": [
          {"text": userMessage},
        ],
      });

      final requestBody = {
        "contents": conversationParts,
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 1024,
          "stopSequences": [],
        },
        "safetySettings": [
          {
            "category": "HARM_CATEGORY_HARASSMENT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE",
          },
          {
            "category": "HARM_CATEGORY_HATE_SPEECH",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE",
          },
          {
            "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE",
          },
          {
            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE",
          },
        ],
      };

      print('🌐 Making API request to: $_baseUrl');
      print('🔑 Using API key: ${_apiKey.substring(0, 10)}...');
      print('📦 Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully parsed response');

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          print('🎯 Found candidate: ${candidate.toString()}');

          if (candidate['content'] != null &&
              candidate['content']['parts'] != null &&
              candidate['content']['parts'].isNotEmpty) {
            final responseText =
                candidate['content']['parts'][0]['text'] ??
                'I apologize, but I couldn\'t process your message. Please try again.';
            print('💬 AI Response: "$responseText"');
            return responseText;
          }
        }
        print('❌ No valid response found in API data');
        return 'I apologize, but I couldn\'t process your message. Please try again.';
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      print('💥 AI Service Error: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  String _getSystemPrompt() {
    return """You are Dr. AI, a friendly and knowledgeable AI health assistant for UMaT E-Health at the University of Mines and Technology. Your role is to:

🎯 **Primary Responsibilities:**
- Provide helpful health information and general medical guidance
- Be empathetic, professional, and encouraging
- Use simple, easy-to-understand language
- Ask follow-up questions to better understand concerns
- Provide general wellness tips and preventive care advice

⚠️ **Important Limitations:**
- You are an AI assistant, NOT a replacement for professional medical care
- Never provide specific medical diagnoses or treatment recommendations
- Always remind users to consult real doctors for serious concerns
- Encourage users to book appointments with real doctors for proper medical care

🏥 **UMaT E-Health Context:**
- You're serving students and staff at UMaT
- Emergency contact: UMaT Clinic +233-595-920-831
- Users can book appointments through the app
- You're available 24/7 for general health questions

💡 **Response Guidelines:**
- Be warm and approachable
- Use emojis sparingly but effectively
- Provide actionable advice when appropriate
- Always end serious health concerns with encouragement to see a real doctor
- Keep responses concise but informative (under 200 words)
- Use markdown formatting for better readability (bold, lists, etc.)

Remember: You're here to help and guide, but always emphasize the importance of professional medical consultation for serious health issues. You're a supportive health companion, not a diagnostic tool.""";
  }

  String _getFallbackResponse(String userMessage) {
    print('🔄 AI Doctor Service - Using fallback response for: "$userMessage"');
    // Fallback responses when API is unavailable
    final responses = [
      "I'm Dr. AI! I'm here to help with general health questions. However, I'm currently experiencing some technical difficulties. For immediate health concerns, please contact UMaT Clinic at +233-595-920-831 or book an appointment with a real doctor.",
      "Hello! I'm your AI health assistant at UMaT E-Health. While I'm having some connectivity issues right now, I'd be happy to help with general wellness questions. Remember, for serious health concerns, always consult with a healthcare professional.",
      "Hi there! I'm Dr. AI, your friendly health companion at UMaT. I'm temporarily offline, but I'm designed to provide general health guidance and wellness tips. For medical emergencies, please call UMaT Clinic immediately at +233-595-920-831.",
    ];

    final selectedResponse =
        responses[DateTime.now().millisecond % responses.length];
    print('📝 AI Doctor Service - Selected fallback: "$selectedResponse"');
    return selectedResponse;
  }

  List<String> getWelcomeMessages() {
    return [
      "Hello! I'm Dr. AI, your friendly health assistant at UMaT E-Health. How can I help you today?",
      "Hi there! I'm here to answer your general health questions and provide wellness guidance. What's on your mind?",
      "Welcome! I'm Dr. AI, ready to help with your health and wellness questions. What would you like to know?",
      "Hey! I'm your AI health companion at UMaT. I'm here 24/7 to help with general health questions and wellness tips!",
    ];
  }

  List<String> getQuickQuestions() {
    return [
      "What are the symptoms of common cold?",
      "How can I improve my sleep as a student?",
      "What foods boost immunity?",
      "How to manage stress during exams?",
      "Exercise tips for busy students",
      "Signs of dehydration",
      "How to prevent headaches?",
      "Best study break activities",
      "Healthy snacks for students",
      "How to stay healthy during rainy season?",
    ];
  }
}
