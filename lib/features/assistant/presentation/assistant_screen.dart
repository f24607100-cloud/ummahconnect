import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map) {
    return ChatMessage(
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final Map<String, String> _mockKnowledgeBase = {
    'explain surah ikhlas': 
        'Surah Al-Ikhlas (Chapter 112) is one of the shortest yet most profound chapters in the Quran. It summarizes the core concept of Tawhid (the absolute Oneness of Allah):\n\n'
        '1. "Say, He is Allah, [who is] One" - Excludes all forms of partnerships.\n'
        '2. "Allah, the Eternal Refuge" - He is self-sufficient, and everyone depends on Him.\n'
        '3. "He neither begets nor is born" - Rejects the idea of Allah having ancestors or children.\n'
        '4. "Nor is there to Him any equivalent" - Nothing is comparable to Him in any way.',
    
    'what is wudu?': 
        'Wudu (ablution) is the ritual purification performed by Muslims before offering Salah (prayers). The essential steps are:\n\n'
        '1. Niyyah (intention) & saying "Bismillah".\n'
        '2. Washing hands up to the wrists three times.\n'
        '3. Rinsing the mouth three times.\n'
        '4. Sniffing water into the nose and blowing it out three times.\n'
        '5. Washing the face from forehead to chin, ear to ear, three times.\n'
        '6. Washing arms up to and including the elbows three times (right first).\n'
        '7. Wiping the head (Masah) once.\n'
        '8. Washing feet up to the ankles three times (right first).\n\n'
        'Keep water usage minimal as taught by the Sunnah.',
        
    'how to pray tahajjud?': 
        'Tahajjud is a voluntary night prayer performed after Isha and after waking up from sleep in the last third of the night:\n\n'
        '1. Wake up during the night (preferably before Fajr).\n'
        '2. Perform Wudu beautifully.\n'
        '3. Make the intention for Tahajjud prayer.\n'
        '4. Pray in units of 2 Rak\'ahs (you can pray 2, 4, 6, 8, or up to 12 Rak\'ahs).\n'
        '5. Conclude with Witr prayer (1 or 3 Rak\'ahs) if you haven\'t prayed it yet.\n\n'
        'It is a highly rewarded time for making deep, personal Duas.',
        
    'importance of salah': 
        'Salah is the second pillar of Islam and the primary connection between a Muslim and Allah:\n\n'
        '1. It is the first deed we will be questioned about on Judgement Day.\n'
        '2. It serves as a spiritual anchor five times a day, keeping us mindful of our purpose.\n'
        '3. Quran says: "Indeed, prayer prohibits immorality and wrongdoing" (29:45).\n'
        '4. It cleanses sins, just like washing in a river five times a day.\n'
        '5. It brings peace (Sakinah) and relief into a hectic daily life.'
  };

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  void _loadChatHistory() {
    final hive = HiveService();
    final cached = hive.getValue<List>(HiveService.bookmarksBox, 'chat_history');
    if (cached != null) {
      setState(() {
        _messages.addAll(cached.map((e) => ChatMessage.fromMap(e as Map)).toList());
      });
      _scrollToBottom();
    }
  }

  Future<void> _saveChatHistory() async {
    final hive = HiveService();
    final list = _messages.map((e) => e.toMap()).toList();
    await hive.setValue<List>(HiveService.bookmarksBox, 'chat_history', list);
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
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true, timestamp: DateTime.now()));
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();
    _saveChatHistory();

    // Trigger Mock Reply
    Timer(const Duration(milliseconds: 1500), () {
      final query = text.toLowerCase().trim();
      String reply = 'Thank you for asking. I am here to help you study and understand Islamic topics. '
          'Please ask about Quranic verses, Salah, Hadith, or basic jurisprudence. '
          'Remember to double-check references with verified scholars.';

      // Lookup in local mockup KB
      for (final key in _mockKnowledgeBase.keys) {
        if (query.contains(key)) {
          reply = _mockKnowledgeBase[key]!;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()));
          _isTyping = false;
        });
        _scrollToBottom();
        _saveChatHistory();
      }
    });
  }

  void _clearChat() async {
    setState(() {
      _messages.clear();
    });
    await HiveService().deleteValue(HiveService.bookmarksBox, 'chat_history');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Spiritual Assistant'),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Conversation',
              onPressed: _clearChat,
            ),
        ],
      ),
      body: IslamicPatternDecoration(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty 
                  ? _buildEmptyState() 
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildChatBubble(_messages[index]);
                      },
                    ),
            ),
            
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Assistant is typing',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Input field panel
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final suggestedPrompts = [
      'Explain Surah Ikhlas',
      'What is Wudu?',
      'How to pray Tahajjud?',
      'Importance of Salah',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Icon(
              Icons.psychology_outlined,
              size: 54,
              color: isDark ? AppColors.gold : AppColors.lightPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ask Me Anything about Islam',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore Quran meanings, prayer steps, or daily spiritual habits. Responses are simulated offline.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          const IslamicDivider(width: 80),
          const SizedBox(height: 32),
          
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Suggested Prompts:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.gold : AppColors.lightPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: suggestedPrompts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final prompt = suggestedPrompts[index];
              return InkWell(
                onTap: () => _sendMessage(prompt),
                borderRadius: BorderRadius.circular(16),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Center(
                    child: Text(
                      prompt,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () {
                // Copy options
                _showBubbleOptions(message);
              },
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: message.isUser 
                      ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary) 
                      : (isDark ? AppColors.darkSurface : Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                    bottomRight: Radius.circular(message.isUser ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: message.isUser 
                      ? null 
                      : Border.all(
                          color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                        ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, "0")}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showBubbleOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Message'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.text));
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message copied to clipboard.')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete Message'),
                onTap: () {
                  setState(() {
                    _messages.remove(message);
                  });
                  _saveChatHistory();
                  context.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your question...',
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.gold : AppColors.lightPrimary,
                    width: 1.5,
                  ),
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: isDark ? AppColors.gold : AppColors.lightPrimary,
            radius: 22,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}
