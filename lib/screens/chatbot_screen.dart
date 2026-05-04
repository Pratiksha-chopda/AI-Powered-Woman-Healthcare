import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hf_chat_service.dart';

class ChatBotScreen extends StatefulWidget {
  final String userId;

  const ChatBotScreen({super.key, required this.userId});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    messages.insert(0, {
      "user": true,
      "message": text,
      "timestamp": DateTime.now(),
    });

    _animationController
      ..reset()
      ..forward();

    final reply = await HFChatService.sendMessage(text);

    messages.insert(0, {
      "user": false,
      "message": reply,
      "timestamp": DateTime.now(),
    });

    _controller.clear();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildPremiumAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildPremiumInputSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(88),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage:
                    AssetImage('assets/icons/counselor.png'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Care Counselor",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${messages.length} messages",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0 && _isLoading) return _buildTypingIndicator();
        final msgIndex = _isLoading ? index - 1 : index;
        final msg = messages[msgIndex];
        final bool isUser = msg["user"] == true;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: _buildMessageBubble(msg, isUser),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints:
      BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUser
                ? const [Color(0xFF667eea), Color(0xFF764ba2)]
                : [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          msg["message"],
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text("AI is typing...", style: TextStyle(color: Colors.grey[600])),
    );
  }

  Widget _buildPremiumInputSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Type a message",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (_controller.text.trim().isNotEmpty) {
                _sendMessage(_controller.text.trim());
              }
            },
            child: const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFF2196F3),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}