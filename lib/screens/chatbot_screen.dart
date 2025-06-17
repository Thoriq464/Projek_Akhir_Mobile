import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  
  // Speech to text variables
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  @override
  void initState() {
    super.initState();
    _initSpeech();
    // Add welcome message
    _messages.add(ChatMessage(
      text: 'Halo! Saya asisten kamus bahasa Jawa. Apa yang ingin Anda tanyakan tentang bahasa Jawa hari ini?',
      isMe: false,
    ));
  }
  /// Initialize speech to text
  void _initSpeech() async {
    try {
      // Initialize speech to text without permission handler first
      _speechEnabled = await _speechToText.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      print('Speech enabled: $_speechEnabled');
    } catch (e) {
      print('Speech initialization error: $e');
      _speechEnabled = false;
    }
    setState(() {});
  }/// Start listening for speech
  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
        localeId: 'id_ID', // Indonesian locale
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  /// Stop listening for speech
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  /// Handle speech recognition results
  void _onSpeechResult(result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _messageController.text = _lastWords;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.smart_toy_rounded, 
                  color: Color(0xFF1565C0), 
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Chatbot Javdict',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _isListening 
                          ? Colors.red.withOpacity(0.2)
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isListening) ...[
                          const Icon(
                            Icons.mic,
                            color: Colors.red,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Mendengarkan...',
                            style: TextStyle(
                              fontSize: 12, 
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Asisten Bahasa Jawa • Online',
                            style: TextStyle(
                              fontSize: 12, 
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF1565C0),
                Color(0xFF1976D2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
      ),      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: ChatBackgroundPainter(),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return const TypingIndicator();
                      }
                      return _messages[index];
                    },
                  ),
                ),
                _buildChatInput(),
              ],
            ),
          ],
        ),
      ),
    );
  }  Widget _buildChatInput() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,                decoration: InputDecoration(
                  hintText: _speechEnabled 
                      ? 'Ketik atau tekan mic untuk berbicara...'
                      : 'Ketik pertanyaan tentang bahasa Jawa...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Microphone button
          if (_speechEnabled)
            Container(
              decoration: BoxDecoration(
                gradient: _isListening 
                    ? const LinearGradient(
                        colors: [
                          Color(0xFFE53E3E),
                          Color(0xFFFC8181),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [
                          Color(0xFF38A169),
                          Color(0xFF68D391),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : Colors.green).withOpacity(0.4),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: _isListening ? _stopListening : _startListening,
                splashRadius: 24,
              ),
            ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1565C0),
                  Color(0xFF1976D2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.4),
                  spreadRadius: 0,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded, 
                color: Colors.white,
                size: 22,
              ),
              onPressed: _sendMessage,
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: message,
          isMe: true,
        ));
        _isTyping = true;
      });
      _messageController.clear();
      _scrollToBottom();

      try {
        String response = await _apiService.kirimPesanKeDialogflowCX(message);
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: response,
            isMe: false,
          ));
        });
        _scrollToBottom();
      } catch (e) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: 'Maaf, terjadi kesalahan. Silakan coba lagi nanti.',
            isMe: false,
          ));
        });
        _scrollToBottom();      }
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    Key? key,
    required this.text,
    required this.isMe,
  }) : super(key: key);

  final String text;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF1565C0),
                child: Icon(
                  Icons.smart_toy_rounded, 
                  color: Colors.white, 
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isMe 
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF0D47A1),
                              Color(0xFF1565C0),
                              Color(0xFF1976D2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isMe ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(24),
                      topRight: const Radius.circular(24),
                      bottomLeft: Radius.circular(isMe ? 24 : 8),
                      bottomRight: Radius.circular(isMe ? 8 : 24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe 
                            ? const Color(0xFF1565C0).withOpacity(0.3)
                            : Colors.black.withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: isMe ? 12 : 8,
                        offset: Offset(0, isMe ? 4 : 2),
                      ),
                    ],
                    border: isMe 
                        ? null 
                        : Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: isMe ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    isMe ? 'Anda' : 'Javdict Bot',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF1F5F9),
                child: Icon(
                  Icons.person_rounded, 
                  color: Colors.grey[600], 
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF1565C0),
              child: Icon(
                Icons.smart_toy_rounded, 
                color: Colors.white, 
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sedang mengetik',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(3, (index) {
                      final animationValue = (_animationController.value + index * 0.2) % 1.0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withOpacity(
                              0.3 + (animationValue * 0.7),
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter untuk background pattern
class ChatBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Pattern spacing
    const double spacing = 40.0;
    const double dotSize = 3.0;
    const double circleRadius = 15.0;

    // Draw dot pattern
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        // Small dots
        canvas.drawCircle(
          Offset(x, y),
          dotSize,
          paint,
        );
        
        // Larger circles at specific intervals
        if ((x / spacing) % 3 == 0 && (y / spacing) % 3 == 0) {
          canvas.drawCircle(
            Offset(x, y),
            circleRadius,
            strokePaint,
          );
        }
      }
    }

    // Draw subtle diagonal lines
    final linePaint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double i = -size.height; i < size.width + size.height; i += spacing * 2) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );
    }

    // Draw chat bubble inspired shapes
    final bubblePaint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.02)
      ..style = PaintingStyle.fill;

    for (double x = spacing; x < size.width; x += spacing * 4) {
      for (double y = spacing; y < size.height; y += spacing * 4) {
        final path = Path();
        path.addRRect(
          RRect.fromRectAndCorners(
            Rect.fromCenter(
              center: Offset(x, y),
              width: 20,
              height: 12,
            ),
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: const Radius.circular(2),
            bottomRight: const Radius.circular(8),
          ),
        );
        canvas.drawPath(path, bubblePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}