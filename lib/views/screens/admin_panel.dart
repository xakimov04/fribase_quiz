import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:fribase/controllers/quiz_controller.dart';
import 'package:fribase/views/widgets/advansed_drawer.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class QuestionForm extends StatefulWidget {
  const QuestionForm({super.key});

  @override
  State<QuestionForm> createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  final _advancedDrawerController = AdvancedDrawerController();
  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  final _formKey = GlobalKey<FormState>();
  final _textEditingController = TextEditingController();
  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final _correctAnswerController = TextEditingController();
  late QuizController questionController;

  @override
  void initState() {
    super.initState();
    questionController = context.read<QuizController>();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _correctAnswerController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addAnswerField() {
    if (_answerControllers.length < 4) {
      setState(() {
        _answerControllers.add(TextEditingController());
      });
    }
  }

  void _removeAnswerField(int index) {
    if (_answerControllers.length > 2) {
      setState(() {
        _answerControllers.removeAt(index);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final question = _textEditingController.text;
      final answers =
          _answerControllers.map((controller) => controller.text).toList();
      final correct = int.tryParse(_correctAnswerController.text);

      if (correct != null && correct >= 0 && correct < answers.length) {
        questionController.addQuestion(
          answers,
          correct,
          question,
        );

        _textEditingController.clear();
        _correctAnswerController.clear();
        for (var controller in _answerControllers) {
          controller.clear();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid correct answer index')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: const Color(0xff041955),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      drawer: const CustomDrawer(),
      child: Scaffold(
        backgroundColor: const Color(0xff7b7bce),
        appBar: AppBar(
          toolbarHeight: 65,
          leadingWidth: 80,
          leading: GestureDetector(
            onTap: _handleMenuButtonPressed,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/icons/logo.gif"),
                radius: 15,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            'Add Question',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      borderSide: BorderSide(
                        width: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      borderSide: BorderSide(
                        width: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    labelText: 'Question',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a question';
                    }
                    return null;
                  },
                ),
                const Gap(15.0),
                ..._answerControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: controller,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  borderSide: BorderSide(
                                    width: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  borderSide: BorderSide(
                                    width: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                                labelText: 'Answer ${index + 1}',
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                              ),
                              style: const TextStyle(color: Colors.white),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an answer';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                      if (_answerControllers.length > 2)
                        IconButton(
                          icon: const Icon(Icons.remove),
                          color: Colors.white,
                          onPressed: () => _removeAnswerField(index),
                        ),
                    ],
                  );
                }).toList(),
                TextFormField(
                  controller: _correctAnswerController,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      borderSide: BorderSide(
                        width: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      borderSide: BorderSide(
                        width: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    labelText: 'Correct Answer Index (0-based)',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: (value) {
                    final index = int.tryParse(value ?? '');
                    if (index == null ||
                        index < 0 ||
                        index >= _answerControllers.length) {
                      return 'Please enter a valid index';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _addAnswerField,
                      child: const Text('Add Answer'),
                    ),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
