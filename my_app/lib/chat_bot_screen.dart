import 'package:flutter/material.dart';
import 'package:flutter_ucs_app/constants.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  final List<ChatMessage> _messages = [];
  
  // Common predefined responses for booking-related questions
  final Map<String, String> _faqResponses = {
    'help': 'I can help you with booking rooms, checking your bookings, or answering questions about our campus facilities.',
    'book': 'To book a room, go to the home screen, select a campus, then choose your room type and features.',
    'rooms': 'We offer Quiet Rooms for individual study, Conference Rooms for meetings, and Study Rooms for group collaboration.',
    'cancel': 'You can cancel your booking from the "My Bookings" page by clicking the delete icon next to your upcoming booking.',
    'features': 'Depending on the room type, you can select features like projectors, whiteboards, video conferencing equipment, and computers.',
    'hours': 'Our campus facilities are open from 8:00 AM to 10:00 PM Monday through Friday, and 9:00 AM to 6:00 PM on weekends.',
    'contact': 'For additional help, please contact our support team at support@ucs.edu or call 01234 567890.',
  };

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    
    _messageController.clear();
    
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    
    // Scroll to the bottom after adding the message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    
    // Process the message and get a response
    final response = await _getBotResponse(text);
    
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: response, isUser: false));
    });
    
    // Scroll to the bottom again after adding the response
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }
  
  Future<String> _getBotResponse(String message) async {
    // Simulate network delay for a more natural feel
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Convert message to lowercase for case-insensitive matching
    final lowerMessage = message.toLowerCase();
    
    // Check for keywords in the message to provide relevant responses
    for (final entry in _faqResponses.entries) {
      if (lowerMessage.contains(entry.key)) {
        return entry.value;
      }
    }
    
    try {
      // Call the Ollama API for a response
      final response = await http.post(
        Uri.parse('http://localhost:11434/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'mistral',
          'prompt': '''You are a helpful booking assistant for UCS (University Centre Somerset).
You help users book rooms, check facilities, and answer questions about bookings.
Keep responses brief, friendly, and helpful. Stick to information related to:
- Room bookings (quiet rooms, conference rooms, study rooms)
- Room features (projectors, whiteboards, etc.)
- Campus facilities
- Booking procedures

User question: $message''',
          'stream': false
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse = data['response'];
        
        // Clean up the response to make it more concise
        aiResponse = aiResponse.trim();
        
        // If the response is too long, truncate it
        if (aiResponse.length > 300) {
          final sentences = aiResponse.split(RegExp(r'(?<=[.!?])\s+'));
          aiResponse = sentences.take(3).join(' ');
        }
        
        return aiResponse;
      }
    } catch (e) {
      debugPrint('Error calling Ollama API: $e');
      // Fall back to generic responses on error
    }
    
    // Fallback to predefined generic responses
    final genericResponses = [
      "I understand you're asking about ${message.split(' ').take(3).join(' ')}... Could you tell me more specifically what you need help with?",
      "For assistance with booking rooms, please try asking about 'book', 'rooms', or 'features'.",
      "I'm here to help with your booking needs. For specific questions about campus facilities, try asking about 'hours' or 'features'.",
      "I don't have enough information to answer that question. Could you try rephrasing it?",
    ];
    
    return genericResponses[DateTime.now().second % genericResponses.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chat Assistant',
          style: TextStyle(color: primaryColor),
        ),
      ),
      body: Column(
        children: [
          // Welcome message card
          if (_messages.isEmpty) _buildWelcomeCard(),
            
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          
          // Bot typing indicator
          if (_isTyping) _buildTypingIndicator(),
          
          // Divider
          const Divider(height: 1.0),
          
          // Message input field
          _buildMessageInput(),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'UCS Booking Assistant',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Hello! I can help you with:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('• Booking room information'),
              const Text('• Campus facilities'),
              const Text('• Booking procedures'),
              const Text('• Cancellation policies'),
              const SizedBox(height: 8),
              const Text(
                'How can I assist you today?',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: _TypingIndicator(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Ask a question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: () => _handleSubmitted(_messageController.text),
            backgroundColor: primaryColor,
            elevation: 0,
            child: const Icon(Icons.send, color: secondaryColor),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: message.isUser ? 64.0 : 0.0,
        right: message.isUser ? 0.0 : 64.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: message.isUser 
            ? primaryColor
            : primaryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: message.isUser ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  
  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        );
      },
    );
  }
  
  Widget _buildDot(int index) {
    final double delay = (index * 0.33).clamp(0.0, 0.5);
    final double end = (delay + 0.5).clamp(0.0, 1.0);
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, end, curve: Curves.easeOut),
      ),
    );
    
    return Transform.translate(
      offset: Offset(0, -3 * animation.value),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}