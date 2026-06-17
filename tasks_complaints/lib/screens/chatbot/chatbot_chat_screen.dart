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

class _ChatMessage {
  final String role;
  final String text;

  const _ChatMessage({required this.role, required this.text});
}

class ChatbotChatScreen extends StatefulWidget {
  const ChatbotChatScreen({super.key});

  @override
  State<ChatbotChatScreen> createState() => _ChatbotChatScreenState();
}

class _ChatbotChatScreenState extends State<ChatbotChatScreen> {
  final ConnectivityService _connectivityService =
      ConnectivityService.instance;
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();

  bool _greetingAdded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryScrollController.dispose();
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

  void _addGreetingIfNeeded() {
    if (!_greetingAdded && !_messages.isNotEmpty) {
      _messages.add(const _ChatMessage(
        role: 'bot',
        text: 'مرحباً! أنا بوت الدعم الفني. كيف أقدر أساعدك؟ اختر سؤالاً من الأسفل:',
      ));
      _greetingAdded = true;
    }
  }

  void _onQuestionTapped(ChatbotQAModel question) {
    setState(() {
      _messages
          .add(_ChatMessage(role: 'user', text: question.question));
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(role: 'bot', text: question.answer));
      });
      _scrollToBottom();
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
      title: const Text('تشات بوت'),
      automaticallyImplyLeading: !kIsWeb,
      actions: [
        IconButton(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh),
          tooltip: 'تحديث',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<ChatbotProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const CustomLoading(size: 40);
        if (provider.error != null) return _buildErrorState(provider);

        _addGreetingIfNeeded();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final chatMaxWidth = isWide
                ? (constraints.maxWidth > 1024 ? 800.0 : constraints.maxWidth * 0.75)
                : constraints.maxWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: chatMaxWidth),
                child: Column(
                  children: [
                    _buildCategoryChips(provider),
                    const Divider(height: 1),
                    Expanded(child: _buildChatArea(provider)),
                    _buildQuickReplyArea(provider),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryChips(ChatbotProvider provider) {
    final allChips = <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: FilterChip(
          label: const Text('الكل'),
          selected: provider.selectedCategory == null,
          onSelected: (_) => provider.clearCategoryFilter(),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: provider.selectedCategory == null
                ? Colors.white
                : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: provider.selectedCategory == null
                ? AppColors.primary
                : AppColors.border,
          ),
        ),
      ),
      ...provider.categories.map((category) {
        final isSelected = provider.selectedCategory == category;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => provider.fetchByCategory(category),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
        );
      }),
    ];

    return SizedBox(
      height: 60,
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
              final position = _categoryScrollController.position;
              final delta = pointerSignal.scrollDelta.dy != 0
                  ? pointerSignal.scrollDelta.dy
                  : pointerSignal.scrollDelta.dx;

              final newOffset = (position.pixels + delta).clamp(
                position.minScrollExtent,
                position.maxScrollExtent,
              );

              _categoryScrollController.jumpTo(newOffset);
            }
          },
          child: SingleChildScrollView(
            controller: _categoryScrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: allChips,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea(ChatbotProvider provider) {
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
    if (provider.questions.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
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
                  final position = _categoryScrollController.position;
                  final delta = pointerSignal.scrollDelta.dy != 0
                      ? pointerSignal.scrollDelta.dy
                      : pointerSignal.scrollDelta.dx;

                  final newOffset = (position.pixels + delta).clamp(
                    position.minScrollExtent,
                    position.maxScrollExtent,
                  );

                  _categoryScrollController.jumpTo(newOffset);
                }
              },
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 16 : 8,
                  vertical: 8,
                ),
                itemCount: provider.questions.length,
                itemBuilder: (context, index) {
                  final question = provider.questions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      label: Text(
                        question.question,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () => _onQuestionTapped(question),
                      backgroundColor: AppColors.card,
                      side: const BorderSide(color: AppColors.primary),
                      labelStyle: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: isWide ? 13 : 12,
                      ),
                      avatar: Icon(
                        Icons.question_answer,
                        size: isWide ? 18 : 16,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
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
              const Icon(Icons.error_outline, size: 80, color: AppColors.error),
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
                text: 'اختر سؤالاً من الأسفل للبدء',
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
