import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fribase/service/product_service.dart';

class QuizController extends ChangeNotifier {
  final Map<int, String> _selectedOptions = {};

  Map<int, String> get selectedOptions => _selectedOptions;

  final _quizService = QuizService();

  Stream<QuerySnapshot> get list {
    return _quizService.getQuiz();
  }

  void selectOption(int index, String option) {
    _selectedOptions[index] = option;
    notifyListeners();
  }

  void addQuestion(List<String> options, int correct, String question) {
    _quizService.addQuestion(options, correct, question);
    notifyListeners();
  }
}
