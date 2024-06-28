import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:fribase/controllers/quiz_controller.dart';
import 'package:fribase/controllers/select_controller.dart';
import 'package:fribase/models/quiz_model.dart';
import 'package:fribase/views/widgets/advansed_drawer.dart';
import 'package:fribase/views/widgets/quiz_cart.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _totalPages = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SelectedOptionsNotifier>(
            builder: (context, selectedOptions, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              "Quiz tugadi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            content: Text(
              "Siz ${selectedOptions.count} tasiga javob berdingiz.",
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Bekor qilish",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _retryQuiz();
                },
                child: const Text(
                  "Qayta o'ynash",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void _retryQuiz() {
    _pageController.jumpToPage(0);
    context.read<SelectedOptionsNotifier>().clearSelections();
  }

  final _advancedDrawerController = AdvancedDrawerController();
  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
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
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color(0xff969EF3),
            floatingActionButton: _buildFloatingActionButtons(_pageController),
            body: Consumer<QuizController>(
              builder: (context, quizController, child) {
                return StreamBuilder(
                  stream: quizController.list,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("Savollar mavjud emas"),
                      );
                    }
                    final quiz = snapshot.data!.docs;
                    _totalPages = quiz.length;
                    return PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: quiz.length,
                      itemBuilder: (context, index) {
                        final quizs = Quiz.fromJson(quiz[index]);
                        return QuizCart(
                          index: index,
                          quiz: quizs,
                          pageController: _pageController,
                          onLastQuestionAnswered: index == quiz.length - 1
                              ? _showCompletionDialog
                              : null,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            top: 50,
            left: 15,
            child: GestureDetector(
              onTap: _handleMenuButtonPressed,
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/icons/logo.gif"),
                radius: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(
    PageController controller,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            controller.previousPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          icon: const Icon(
            Icons.keyboard_arrow_up_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        IconButton(
          onPressed: () {
            controller.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
      ],
    );
  }
}
