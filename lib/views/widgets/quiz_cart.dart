import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'package:fribase/controllers/quiz_controller.dart';
import 'package:fribase/controllers/select_controller.dart';
import 'package:fribase/models/quiz_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizCart extends StatefulWidget {
  final int index;
  final Quiz quiz;
  final PageController pageController;
  final VoidCallback? onLastQuestionAnswered;

  const QuizCart({
    super.key,
    required this.index,
    required this.quiz,
    required this.pageController,
    this.onLastQuestionAnswered,
  });

  @override
  State<QuizCart> createState() => _QuizCartState();
}

class _QuizCartState extends State<QuizCart> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuestionText(question: widget.quiz.question),
            const Gap(20),
            ..._buildOptions(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(BuildContext context) {
    return widget.quiz.options.asMap().entries.map((entry) {
      final optionIndex = entry.key;
      final option = entry.value;

      return _OptionItem(
        index: optionIndex,
        quiz: widget.quiz,
        option: option,
        pageController: widget.pageController,
        onLastQuestionAnswered: widget.onLastQuestionAnswered,
      );
    }).toList();
  }
}

class _QuestionText extends StatelessWidget {
  final String question;

  const _QuestionText({required this.question});

  @override
  Widget build(BuildContext context) {
    return Text(
      question,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _OptionItem extends StatefulWidget {
  final int index;
  final Quiz quiz;
  final String option;
  final PageController pageController;
  final VoidCallback? onLastQuestionAnswered;

  const _OptionItem({
    required this.index,
    required this.option,
    required this.pageController,
    this.onLastQuestionAnswered,
    required this.quiz,
  });

  @override
  State<_OptionItem> createState() => _OptionItemState();
}

class _OptionItemState extends State<_OptionItem> {
  String? _userName;
  String? _userUID;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    _userUID = prefs.getString('uid');
    if (_userUID != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userUID)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'];
        });
      }
    }
  }

  void _saveResult(int score) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('leaderboard').add({
        'userId': user.uid,
        'userName': _userName,
        'score': score,
        'timestamp': Timestamp.now(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected =
        context.watch<SelectedOptionsNotifier>().selectedOptions[widget.index] ==
            widget.option;
    final isCorrect = widget.index == widget.quiz.correct;

    return GestureDetector(
      onTap: () async {
        final selectedOptionsNotifier = context.read<SelectedOptionsNotifier>();
        selectedOptionsNotifier.selectOption(widget.index, widget.option, isCorrect);
        if (widget.onLastQuestionAnswered != null) {
          widget.onLastQuestionAnswered!();
          _saveResult(selectedOptionsNotifier.count);
        } else {
          widget.pageController.nextPage(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: _optionDecoration(isSelected),
        child: Text(
          widget.option,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  BoxDecoration _optionDecoration(bool isSelected) {
    return BoxDecoration(
      color: isSelected
          ? Colors.blueAccent[100]
          : const Color.fromARGB(255, 112, 123, 243),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: isSelected
              ? Colors.black.withOpacity(.1)
              : Colors.black.withOpacity(0.5),
          offset: const Offset(8, 8),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    );
  }
}
