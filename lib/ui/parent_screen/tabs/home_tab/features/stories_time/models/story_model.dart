import 'package:flutter/material.dart';

enum AnswerResult { none, correct, wrong }

class StoryQuestion {
  final String questionKey;
  final List<String> optionKeys;
  final int correctIndex;
  final String hintKey;

  const StoryQuestion({
    required this.questionKey,
    required this.optionKeys,
    required this.correctIndex,
    required this.hintKey,
  });
}

class StoryPage {
  final String imagePath;
  final String storyTextKey;
  final StoryQuestion question;

  const StoryPage({
    required this.imagePath,
    required this.storyTextKey,
    required this.question,
  });
}

class StoryData {
  final String titleKey;
  final String subtitleKey;
  final List<StoryPage> pages;

  const StoryData({
    required this.titleKey,
    required this.subtitleKey,
    required this.pages,
  });
}

// يتم إنشاء القصة باستخدام المفاتيح
const sampleStoryAr = StoryData(
  titleKey: 'title',
  subtitleKey: 'subtitle',
  pages: [
    StoryPage(
      imagePath: 'assets/images/pizza_kitchen.png',
      storyTextKey: 'story_text_pizza',
      question: StoryQuestion(
        questionKey: 'where_is_pizza',
        optionKeys: ['inside_box', 'outside_box'],
        correctIndex: 0,
        hintKey: 'pizza_hint',
      ),
    ),
    StoryPage(
      imagePath: 'assets/images/delivery_bike.png',
      storyTextKey: 'story_text_bike',
      question: StoryQuestion(
        questionKey: 'where_is_bag',
        optionKeys: ['at_back', 'at_front'],
        correctIndex: 0,
        hintKey: 'bag_hint',
      ),
    ),
    StoryPage(
      imagePath: 'assets/images/delivery_arrive.png',
      storyTextKey: 'story_text_arrive',
      question: StoryQuestion(
        questionKey: 'where_is_grandma',
        optionKeys: ['in_front_of_door', 'behind_door'],
        correctIndex: 0,
        hintKey: 'grandma_hint',
      ),
    ),
  ],
);