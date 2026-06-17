import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/chatbot_provider.dart';
import '../../models/chatbot_qa_model.dart';
import '../../services/connectivity_service.dart';
import '../../utils/app_colors.dart';
import '../../common_widgets/custom_widgets/custom_text.dart';
import '../../common_widgets/custom_widgets/custom_loading.dart';

enum _ChatStep { selectApp, selectQuestion }

class _ChatMessage {
  final String role;
  final String text;

  const _ChatMessage({required this.role, required this.text});
}

class ChatbotChatTwoScreen extends StatefulWidget {
  const ChatbotChatTwoScreen({super.key});

  @override
  State<ChatbotChatTwoScreen> createState() => _ChatbotChatTwoScreenState();
}

class _ChatbotChatTwoScreenState extends State<ChatbotChatTwoScreen> {
  final ConnectivityService _connectivityService =
      ConnectivityService.instance;
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ScrollController _quickReplyScrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  _ChatStep _currentStep = _ChatStep.selectApp;
  List<ChatbotQAModel> _filteredQuestions = [];
  bool _greetingAdded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _quickReplyScrollController.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final connected = await _connectivityService.hasConnection();
      if (!mounted) return;
      if (!connected) {
        _showNoInternetDialog();
        return;
      }
      if (!mounted) return;
      context.read<ChatbotProvider>().fetchAllData();
    });
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
      _currentStep = _ChatStep.selectApp;
      _filteredQuestions = [];
      _greetingAdded = false;
    });
    _loadData();
  }

  void _addGreetingAndApps(ChatbotProvider provider) {
    if (_greetingAdded) return;
    _greetingAdded = true;

    _messages.add(const _ChatMessage(
      role: 'bot',
      text: 'مرحباً! أنا بوت الدعم الفني. اختر المنظومة:',
    ));

    final categories = provider.categories;
    if (categories.isNotEmpty) {
      final numberedApps = categories
          .asMap()
          .entries
          .map((e) => '${e.key + 1}. ${e.value}')
          .join('\n');
      _messages.add(_ChatMessage(
        role: 'bot',
        text: numberedApps,
      ));
    }
  }

  void _onAppNumberTapped(int number, ChatbotProvider provider) {
    final categories = provider.categories;
    if (number < 1 || number > categories.length) return;

    final selected = categories[number - 1];
    setState(() {
      _currentStep = _ChatStep.selectQuestion;
      _messages.add(_ChatMessage(
        role: 'user',
        text: 'المنظومة: $selected',
      ));
    });
    _scrollToBottom();

    provider.fetchByCategory(selected);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentProvider = context.read<ChatbotProvider>();
        setState(() {
          _filteredQuestions = List.from(currentProvider.questions);
          if (_filteredQuestions.isEmpty) {
            _messages.add(const _ChatMessage(
              role: 'bot',
              text: 'لا توجد أسئلة في هذا التصنيف.',
            ));
          } else {
            final numberedQuestions = _filteredQuestions
                .asMap()
                .entries
                .map((e) => '${e.key + 1}. ${e.value.question}')
                .join('\n');
            _messages.add(_ChatMessage(
              role: 'bot',
              text: 'اختر السؤال:\n$numberedQuestions',
            ));
          }
        });
        _scrollToBottom();
      });
    });
  }

  void _onQuestionNumberTapped(int number) {
    if (number < 1 || number > _filteredQuestions.length) return;

    final selected = _filteredQuestions[number - 1];
    setState(() {
      _messages.add(_ChatMessage(
        role: 'user',
        text: 'السؤال: ${selected.question}',
      ));
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          role: 'bot',
          text: selected.answer,
        ));
      });
      _scrollToBottom();
    });
  }

  void _onBackToApps() {
    setState(() {
      _currentStep = _ChatStep.selectApp;
      _filteredQuestions = [];
      _messages.add(const _ChatMessage(
        role: 'bot',
        text: 'اختر المنظومة:',
      ));

      final provider = context.read<ChatbotProvider>();
      final categories = provider.categories;
      if (categories.isNotEmpty) {
        final numberedApps = categories
            .asMap()
            .entries
            .map((e) => '${e.key + 1}. ${e.value}')
            .join('\n');
        _messages.add(_ChatMessage(
          role: 'bot',
          text: numberedApps,
        ));
      }
    });
    _scrollToBottom();
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

  void _onTextSubmitted(String value) {
    final trimmed = value.trim();
    _textController.clear();
    _textFocusNode.unfocus();

    if (trimmed.isEmpty) return;

    final number = int.tryParse(trimmed);
    if (number == null || number < 1) {
      setState(() {
        _messages.add(_ChatMessage(
          role: 'user',
          text: trimmed,
        ));
        _messages.add(const _ChatMessage(
          role: 'bot',
          text: 'الرجاء إدخال رقم صحيح.',
        ));
      });
      _scrollToBottom();
      return;
    }

    final provider = context.read<ChatbotProvider>();

    if (_currentStep == _ChatStep.selectApp) {
      _onAppNumberTapped(number, provider);
    } else if (_currentStep == _ChatStep.selectQuestion) {
      _onQuestionNumberTapped(number);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('2تشات بوت'),
      automaticallyImplyLeading: !kIsWeb,
      actions: [
        IconButton(
          onPressed: _resetChat,
          icon: const Icon(Icons.refresh),
          tooltip: 'بدء من جديد',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<ChatbotProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && _messages.isEmpty) {
          return const CustomLoading(size: 40);
        }
        if (provider.error != null && _messages.isEmpty) {
          return _buildErrorState(provider);
        }

        _addGreetingAndApps(provider);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final chatMaxWidth = isWide
                ? (constraints.maxWidth > 1024
                    ? 800.0
                    : constraints.maxWidth * 0.75)
                : constraints.maxWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: chatMaxWidth),
                child: Column(
                  children: [
                    Expanded(child: _buildChatArea()),
                    _buildQuickReplyArea(provider),
                    _buildTextInputArea(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatArea() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 24 : 12,
            vertical: 8,
          ),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final msg = _messages[index];
            if (msg.role == 'bot') {
              return _buildBotBubble(msg.text, isWide: isWide);
            }
            return _buildUserBubble(msg.text, isWide: isWide);
          },
        );
      },
    );
  }

  Widget _buildBotBubble(String text, {bool isWide = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 450 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'بوت الدعم الفني',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CustomText(
                      text: text,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBubble(String text, {bool isWide = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 450 : double.infinity,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomText(
                  text: text,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplyArea(ChatbotProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        List<Widget> buttons = [];

        if (_currentStep == _ChatStep.selectApp) {
          final categories = provider.categories;
          buttons = List.generate(categories.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ActionChip(
                label: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isWide ? 14 : 12,
                  ),
                ),
                onPressed: () =>
                    _onAppNumberTapped(index + 1, provider),
                backgroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primaryDark),
                avatar: null,
              ),
            );
          });
        } else if (_currentStep == _ChatStep.selectQuestion) {
          buttons = List.generate(_filteredQuestions.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ActionChip(
                label: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isWide ? 14 : 12,
                  ),
                ),
                onPressed: () => _onQuestionNumberTapped(index + 1),
                backgroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primaryDark),
                avatar: null,
              ),
            );
          });

          buttons.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ActionChip(
                label: Text(
                  'رجوع',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: isWide ? 14 : 12,
                  ),
                ),
                onPressed: _onBackToApps,
                backgroundColor: AppColors.card,
                side: const BorderSide(color: AppColors.error),
                avatar: const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.error,
                ),
              ),
            ),
          );
        }

        return Container(
          height: isWide ? 70 : 60,
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.stylus,
                PointerDeviceKind.trackpad,
              },
            ),
            child: Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  final position =
                      _quickReplyScrollController.position;
                  final delta = pointerSignal.scrollDelta.dy != 0
                      ? pointerSignal.scrollDelta.dy
                      : pointerSignal.scrollDelta.dx;

                  final newOffset = (position.pixels + delta).clamp(
                    position.minScrollExtent,
                    position.maxScrollExtent,
                  );

                  _quickReplyScrollController.jumpTo(newOffset);
                }
              },
              child: ListView(
                controller: _quickReplyScrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 16 : 8,
                  vertical: 8,
                ),
                children: buttons,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _textFocusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.send,
                onSubmitted: _onTextSubmitted,
                decoration: InputDecoration(
                  hintText: _currentStep == _ChatStep.selectApp
                      ? 'اكتب رقم المنظومة...'
                      : 'اكتب رقم السؤال...',
                  hintStyle: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => _onTextSubmitted(_textController.text),
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ChatbotProvider provider) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 80, color: AppColors.error),
              const SizedBox(height: 16),
              CustomText(
                text: provider.error!,
                fontSize: 16,
                color: AppColors.error,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 100,
                color: AppColors.textHint.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const CustomText(
                text: 'ابدأ المحادثة',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              const CustomText(
                text: 'اختر منظومة من الأسفل للبدء',
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.wifi_off, size: 60, color: AppColors.error),
        title: const Text('لا يوجد اتصال بالإنترنت'),
        content: const Text('تحقق من اتصالك بالإنترنت وأعد المحاولة'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
