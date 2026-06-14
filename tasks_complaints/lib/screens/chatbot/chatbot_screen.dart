
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

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final Set<int> _expandedItems = {};

  // Controller for the horizontal category chips list
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('شات بوت الدعم الفني'),
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
        return Column(
          children: [
            _buildCategoryChips(provider),
            const Divider(height: 1),
            Expanded(child: _buildQuestionList(provider)),
          ],
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
      // 1) ScrollConfiguration lets mouse-drag scroll the list on web/desktop
      //    (by default, only touch/stylus devices can drag a scrollable).
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
            PointerDeviceKind.trackpad,
          },
        ),
        // 2) Listener intercepts mouse-wheel / trackpad scroll events
        //    (which arrive as a vertical delta) and applies that delta
        //    to the horizontal scroll position.
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

  Widget _buildQuestionList(ChatbotProvider provider) {
    if (provider.questions.isEmpty) {
      return _buildEmptyState();
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return _buildResponsiveGrid(provider.questions, maxWidth: 1024);
          } else if (constraints.maxWidth > 600) {
            return _buildResponsiveGrid(provider.questions);
          }
          return _buildMobileList(provider.questions);
        },
      ),
    );
  }

  Widget _buildMobileList(List<ChatbotQAModel> questions) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: questions.length,
      itemBuilder: (context, index) => _buildQuestionCard(questions[index]),
    );
  }

  Widget _buildResponsiveGrid(List<ChatbotQAModel> questions,
      {double? maxWidth}) {
    final grid = GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: questions.length,
      itemBuilder: (context, index) => _buildQuestionCard(questions[index]),
    );

    if (maxWidth != null) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: grid,
        ),
      );
    }
    return grid;
  }

  Widget _buildQuestionCard(ChatbotQAModel question) {
    final isExpanded = _expandedItems.contains(question.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isExpanded ? 4 : 1,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isExpanded
            ? const BorderSide(color: AppColors.primary, width: 2)
            : const BorderSide(color: AppColors.border, width: 0.5),
      ),
      child: InkWell(
        onTap: question.id == null
            ? null
            : () {
                setState(() {
                  if (isExpanded) {
                    _expandedItems.remove(question.id);
                  } else {
                    _expandedItems.add(question.id!);
                  }
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.question_answer,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomText(
                      text: question.question,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (question.category != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    question.category!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomText(
                            text: question.answer,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ChatbotProvider provider) {
    return Center(
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
              text: 'لا توجد أسئلة متاحة',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            const CustomText(
              text: 'لم يتم العثور على أسئلة في هذا التصنيف',
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ],
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
