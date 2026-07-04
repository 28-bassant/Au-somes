class StoryResponse {
  final String storyId;
  final String theme;
  final String childName;
  final String mission;
  final List<StoryPage> pages;

  StoryResponse({
    required this.storyId,
    required this.theme,
    required this.childName,
    required this.mission,
    required this.pages,
  });

  factory StoryResponse.fromJson(Map<String, dynamic> json) {
    return StoryResponse(
      storyId: json["story_id"],
      theme: json["theme"],
      childName: json["child_name"],
      mission: json["mission"],
      pages: (json["pages"] as List)
          .map((e) => StoryPage.fromJson(e))
          .toList(),
    );
  }
}

class StoryPage {
  final int pageNumber;
  final String concept;
  final String narration;
  final String question;
  final List<String> options;
  final String answer;
  final StoryFeedback feedback;

  // بدل imagePrompt
  final String imageUrl;

  StoryPage({
    required this.pageNumber,
    required this.concept,
    required this.narration,
    required this.question,
    required this.options,
    required this.answer,
    required this.feedback,
    required this.imageUrl,
  });

  factory StoryPage.fromJson(Map<String, dynamic> json) {
    return StoryPage(
      pageNumber: json["page_number"],
      concept: json["concept"],
      narration: json["narration"],
      question: json["question"],
      options: List<String>.from(json["options"]),
      answer: json["answer"],
      feedback: StoryFeedback.fromJson(json["feedback"]),

      // لو اسمه image_url
      imageUrl: json["image_url"] ?? "",

      // لو الـ API عندكم بيرجع imageUrl استخدمي:
      // imageUrl: json["imageUrl"] ?? "",
    );
  }
}

class StoryFeedback {
  final String encouragementMessage;
  final String wrongFeedback;
  final String retryHint;

  StoryFeedback({
    required this.encouragementMessage,
    required this.wrongFeedback,
    required this.retryHint,
  });

  factory StoryFeedback.fromJson(Map<String, dynamic> json) {
    return StoryFeedback(
      encouragementMessage: json["encouragement_message"],
      wrongFeedback: json["wrong_feedback"],
      retryHint: json["retry_hint"],
    );
  }
}