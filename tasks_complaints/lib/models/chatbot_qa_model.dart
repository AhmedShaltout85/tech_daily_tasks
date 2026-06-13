class ChatbotQAModel {
  final int? id;
  final String question;
  final String answer;
  final String? category;
  final int displayOrder;
  final bool isActive;

  ChatbotQAModel({
    this.id,
    required this.question,
    required this.answer,
    this.category,
    required this.displayOrder,
    required this.isActive,
  });

  factory ChatbotQAModel.fromJson(Map<String, dynamic> json) {
    return ChatbotQAModel(
      id: json['id'],
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      category: json['category'],
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'category': category,
      'displayOrder': displayOrder,
      'isActive': isActive,
    };
  }

  ChatbotQAModel copyWith({
    int? id,
    String? question,
    String? answer,
    String? category,
    int? displayOrder,
    bool? isActive,
  }) {
    return ChatbotQAModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
