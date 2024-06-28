import 'package:flutter/material.dart';
import 'package:fribase/controllers/quiz_controller.dart';
import 'package:fribase/controllers/select_controller.dart';
import 'package:fribase/models/quiz_model.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class QuizCart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestion(),
            const Gap(20),
            ..._buildOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    return Text(
      quiz.question,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Widget> _buildOptions(BuildContext context) {
    return quiz.options.asMap().entries.map((entry) {
      final optionIndex = entry.key;
      final option = entry.value;

      return _OptionItem(
        index: optionIndex,
        quiz: quiz,
        option: option,
        pageController: pageController,
        onLastQuestionAnswered: onLastQuestionAnswered,
      );
    }).toList();
  }
}

class _OptionItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isSelected =
        context.watch<SelectedOptionsNotifier>().selectedOptions[index] ==
            option;
    final isCorrect = index == quiz.correct;

    return GestureDetector(
      onTap: () async {
        final selectedOptionsNotifier = context.read<SelectedOptionsNotifier>();
        selectedOptionsNotifier.selectOption(index, option, isCorrect);
        if (onLastQuestionAnswered != null) {
          onLastQuestionAnswered!();
        } else {
          pageController.nextPage(
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
          option,
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
