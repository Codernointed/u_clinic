import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AIDoctorService {
  static const String _apiKey = 'AIzywuigwoucgbwjefbclusbdooaiednlcsdjv';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  static final AIDoctorService _instance = AIDoctorService._internal();
  factory AIDoctorService() => _instance;
  AIDoctorService._internal();

  Future<String> chatWithAIDoctor(String userMessage, {String? conversationHistory}) async {
    try {
      final messages = [
        {
          "role": "system",
          "content": """You are Dr. AI, a friendly and knowledgeable AI doctor assistant for UMaT E-Health. Your role is to:

1. Provide helpful health information and general medical guidance
2. Be empathetic, professional, and encouraging
3. Always remind users that you're an AI and they should consult real doctors for serious concerns
4. Use simple, easy-to-understand language
5. Ask follow-up questions to better understand their concerns
6. Provide general wellness tips and preventive care advice
7. Never provide specific medical diagnoses or treatment recommendations
8. Always encourage users to book appointments with real doctors for proper medical care

Remember: You're here to help and guide, but always emphasize the importance of professional medical consultation for serious health issues."""
        },
        if (conversationHistory != null && conversationHistory.isNotEmpty)
          {
            "role": "assistant", 
            "content": conversationHistory
          },
        {
          "role": "user",
          "content": userMessage
        }
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'I apologize, but I couldn\'t process your message. Please try again.';
      } else {
        print('AI API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      print('AI Service Error: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  String _getFallbackResponse(String userMessage) {
    // Fallback responses when API is unavailable
    final responses = [
      "I'm Dr. AI! I'm here to help with general health questions. However, I'm currently experiencing some technical difficulties. For immediate health concerns, please contact UMaT Clinic at +233-595-920-831 or book an appointment with a real doctor.",
      "Hello! I'm your AI health assistant. While I'm having some connectivity issues right now, I'd be happy to help with general wellness questions. Remember, for serious health concerns, always consult with a healthcare professional.",
      "Hi there! I'm Dr. AI, your friendly health companion. I'm temporarily offline, but I'm designed to provide general health guidance and wellness tips. For medical emergencies, please call UMaT Clinic immediately.",
    ];
    
    return responses[DateTime.now().millisecond % responses.length];
  }

  List<String> getWelcomeMessages() {
    return [
      "Hello! I'm Dr. AI, your friendly health assistant. How can I help you today?",
      "Hi there! I'm here to answer your general health questions and provide wellness guidance. What's on your mind?",
      "Welcome! I'm Dr. AI, ready to help with your health and wellness questions. What would you like to know?",
    ];
  }

  List<String> getQuickQuestions() {
    return [
      "What are the symptoms of common cold?",
      "How can I improve my sleep?",
      "What foods boost immunity?",
      "How to manage stress?",
      "Exercise tips for beginners",
      "Signs of dehydration",
    ];
  }
}
