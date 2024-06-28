import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  String id;
  num correct;
  List options;
  String question;

  Quiz({
    required this.id,
    required this.correct,
    required this.options,
    required this.question,
  });

  factory Quiz.fromJson(QueryDocumentSnapshot query) {
    return Quiz(
      id: query.id,
      correct: query['correct'],
      options: query['options'],
      question: query['question'],
    );
  }
}
