// lib/screens/smart_assistant_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// --- نموذج بسيط لتمثيل رسالة في المحادثة ---
class ChatMessage {
  final String text;
  final bool isUserMessage;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    this.isError = false,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: "مرحباً! أنا المساعد الذكي، كيف يمكنني مساعدتك اليوم؟", isUserMessage: false),
  ];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // --- الألوان المحددة ---
  final Color userMessageColor = const Color(0xFF007AFF);
  final Color botMessageColor = const Color(0xFFE5E5EA);
  final Color appBarTextColor = const Color(0xFF007AFF);
  final Color backgroundColor = Colors.white;
  final Color userTextColor = Colors.white;
  final Color botTextColor = Colors.black87;
  final Color errorTextColor = Colors.red.shade700;

  // --- ***** تعديل رابط الـ API والمسار ***** ---
  final String _apiUrl = "https://chatbot-api-971671592038.us-central1.run.app/ask"; // <-- استخدام المسار الصحيح /ask

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    final String messageText = text.trim();
    if (messageText.isEmpty || _isLoading) return; // منع الإرسال المتعدد أثناء التحميل

    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: messageText, isUserMessage: true));
      _isLoading = true;
    });
    _scrollToBottom();

    _getBotResponse(messageText);
  }

  // --- ***** تعديل وظيفة الاتصال بالـ API ***** ---
  Future<void> _getBotResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl), // استخدام المسار الصحيح
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'application/json', // إضافة Header accept الذي يظهر في Curl
        },
        // --- ***** تعديل جسم الطلب ليستخدم المفتاح 'text' ***** ---
        body: jsonEncode(<String, String>{
          'text': userMessage, // <-- استخدام المفتاح الصحيح 'text'
        }),
        // --------------------------------------------------------
      ).timeout(const Duration(seconds: 45)); // زيادة المهلة قليلاً احتياطياً

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        // --- ***** تعديل استخراج الرد ليستخدم المفتاح 'answer' ***** ---
        final String botReply = responseBody['answer'] ?? 'لم أجد إجابة واضحة في الرد.'; // <-- استخدام المفتاح الصحيح 'answer'
        // -----------------------------------------------------------

        if (mounted) {
          setState(() {
            _isLoading = false;
            _messages.add(ChatMessage(text: botReply, isUserMessage: false));
          });
        }
      } else {
        // عرض رسالة خطأ أكثر وضوحًا مع محتوى الرد إن وجد
        String errorBody = '';
        try {
          // محاولة قراءة جسم الخطأ (قد يكون JSON أو نص عادي)
          errorBody = utf8.decode(response.bodyBytes);
        } catch (e) {
          errorBody = response.reasonPhrase ?? 'خطأ غير معروف';
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
            _messages.add(ChatMessage(
                text: 'حدث خطأ ${response.statusCode}: $errorBody',
                isUserMessage: false,
                isError: true));
          });
        }
        print('API Error: ${response.statusCode} - ${response.body}'); // طباعة الخطأ للمطور
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add(ChatMessage(
              text: 'انتهت مهلة الاتصال بالخادم. يرجى المحاولة مرة أخرى.',
              isUserMessage: false,
              isError: true));
        });
      }
      print('API Error: Request timed out');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add(ChatMessage(
              text: 'حدث خطأ غير متوقع أثناء الاتصال: $e',
              isUserMessage: false,
              isError: true));
        });
      }
      print('API Error: $e');
    } finally {
      if (mounted && _isLoading) {
        setState(() { _isLoading = false; });
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // ... (نفس الكود بدون تغيير) ...
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

  @override
  Widget build(BuildContext context) {
    // ... (نفس الكود بدون تغيير) ...
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar( /* ... نفس كود AppBar ... */
          title: Text(
            'المساعد الذكي',
            style: TextStyle(
                color: appBarTextColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo'),
          ),
          centerTitle: true,
          backgroundColor: backgroundColor,
          elevation: 1.0,
          shadowColor: Colors.grey.shade300,
          iconTheme: IconThemeData(color: appBarTextColor),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: appBarTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            Divider(height: 1.0, color: Colors.grey.shade300),
            _buildTextComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // ... (نفس الكود بدون تغيير) ...
    final isUser = message.isUserMessage;
    final isError = message.isError;

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.75),
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: isError
                ? Colors.red.shade100
                : (isUser ? userMessageColor : botMessageColor),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0),
              bottomLeft: Radius.circular(isUser ? 0 : 20.0),
              bottomRight: Radius.circular(isUser ? 20.0: 0),
            ),
            boxShadow: [ /* ... نفس الظل ... */
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: isError
                  ? errorTextColor
                  : (isUser ? userTextColor : botTextColor),
              fontSize: 16,
              fontFamily: 'Cairo',
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    // ... (نفس الكود بدون تغيير) ...
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: botMessageColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(0),
            ),
          ),
          child: const SizedBox(
              width: 40,
              height: 20,
              child: RepaintBoundary(
                child: ThreeDotsLoadingIndicator(),
              )
          ),
        ),
      ],
    );
  }

  Widget _buildTextComposer() {
    // ... (نفس الكود بدون تغيير) ...
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 8.0,
          left: 8.0,
          right: 8.0,
          top: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _isLoading ? null : _handleSubmitted,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: _isLoading ? "يرجى الانتظار..." : "اكتب رسالتك هنا...",
                hintStyle: TextStyle(
                    color: _isLoading ? Colors.grey.shade400 : Colors.grey.shade500,
                    fontFamily: 'Cairo'),
                hintTextDirection: TextDirection.rtl,
                filled: true,
                fillColor: _isLoading ? Colors.grey.shade50 : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: userMessageColor.withOpacity(0.5)),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: _isLoading ? Colors.grey.shade600 : Colors.black87),
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 5,
            ),
          ),
          const SizedBox(width: 8.0),
          Material(
            color: _isLoading ? Colors.grey : userMessageColor,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _isLoading ? null : () => _handleSubmitted(_textController.text),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.send, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- ويدجت النقاط المتحركة (كما هو) ---
class ThreeDotsLoadingIndicator extends StatefulWidget {
  // ... (نفس الكود بدون تغيير) ...
  const ThreeDotsLoadingIndicator({super.key});
  @override
  State<ThreeDotsLoadingIndicator> createState() => _ThreeDotsLoadingIndicatorState();
}
class _ThreeDotsLoadingIndicatorState extends State<ThreeDotsLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(); // تكرار الحركة

    _animation1 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6))); // تأخير بداية الحركة

    _animation2 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.7)));

    _animation3 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder( // استخدام AnimatedBuilder لإعادة البناء عند تغير قيمة الـ animation
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // توزيع النقاط بالتساوي
          children: [
            Transform.translate(offset: Offset(0, _animation1.value), child: _buildDot()),
            Transform.translate(offset: Offset(0, _animation2.value), child: _buildDot()),
            Transform.translate(offset: Offset(0, _animation3.value), child: _buildDot()),
          ],
        );
      },
    );
  }

  Widget _buildDot() {
    return Container(
      width: 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        color: Colors.grey.shade500, // لون النقاط
        shape: BoxShape.circle,
      ),
    );
  }
}