import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class QuizService {
  final _quizCollection = FirebaseFirestore.instance.collection("quiz");

  Stream<QuerySnapshot> getQuiz() async* {
    yield* _quizCollection.snapshots();
  }

  void addQuestion(List<String> answers, int correct, String question) {
    _quizCollection
        .add({"options": answers, "question": question, "correct": correct});
  }
}
