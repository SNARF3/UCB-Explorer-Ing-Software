import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/gemini_service.dart';

class ChatWidget extends StatefulWidget {
  final VoidCallback onClose;

  const ChatWidget({super.key, required this.onClose});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> with SingleTickerProviderStateMixin {
  final List<ChatMessage> messages = [];
  final TextEditingController textController = TextEditingController();
  final GeminiService geminiService = GeminiService();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Mensaje de bienvenida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        messages.add(ChatMessage(
          text: '👋 Hola, ¿cómo estás? 🎓 Bienvenido a UCB Explorer, donde puedes preguntar cualquier cosa sobre la Universidad Católica Boliviana "San Pablo" 😊✨',
          sender: 'bot',
          time: '${DateTime.now().hour}:${DateTime.now().minute}',
          structuredData: [],
        ));
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleMessage(String message) async {
    setState(() {
      messages.add(ChatMessage(
        text: message,
        sender: 'user',
        time: '${DateTime.now().hour}:${DateTime.now().minute}',
        structuredData: [],
      ));
      _isLoading = true;
    });

    try {
      final response = await geminiService.getResponse(message);

      setState(() {
        messages.add(ChatMessage(
          text: response.text,
          sender: 'bot',
          time: '${DateTime.now().hour}:${DateTime.now().minute}',
          structuredData: response.structuredData,
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        messages.add(ChatMessage(
          text: 'Error al obtener respuesta: $e',
          sender: 'bot',
          time: '${DateTime.now().hour}:${DateTime.now().minute}',
          structuredData: [],
        ));
        _isLoading = false;
      });
    }
  }

  void _handleClose() async {
    await _animationController.forward();
    widget.onClose();
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace: $url')),
      );
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Texto copiado al portapapeles')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          // Header (igual que antes)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'UCB - Explorer 💬',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _handleClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: message.sender == 'user'
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: message.sender == 'user'
                                  ? Colors.blue.shade600
                                  : Colors.yellow.shade600,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: message.sender == 'user'
                                    ? const Radius.circular(12)
                                    : Radius.zero,
                                bottomRight: message.sender == 'user'
                                    ? Radius.zero
                                    : const Radius.circular(12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: message.sender == 'user'
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                  message.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                if (message.structuredData.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  ...message.structuredData.map((data) {
                                    if (data.type == 'link') {
                                      return InkWell(
                                        onTap: () => _launchUrl(data.metadata!['url']!),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                          margin: const EdgeInsets.only(bottom: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.link, 
                                                color: Colors.white, size: 16),
                                              const SizedBox(width: 4),
                                              Text(data.content,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  decoration: TextDecoration.underline,
                                                )),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return GestureDetector(
                                        onLongPress: () => _copyToClipboard(data.content),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                          margin: const EdgeInsets.only(bottom: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(data.content,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            )),
                                        ),
                                      );
                                    }
                                  }),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  message.time,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: const Icon(Icons.mood, color: Colors.grey),
                    ),
                    onSubmitted: (message) async {
                      if (message.isNotEmpty) {
                        await _handleMessage(message);
                        textController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade400],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      if (textController.text.isNotEmpty) {
                        await _handleMessage(textController.text);
                        textController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final String sender;
  final String time;
  final List<StructuredData> structuredData;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.time,
    required this.structuredData,
  });
}