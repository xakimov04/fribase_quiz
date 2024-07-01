import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:fribase/controllers/quiz_controller.dart';
import 'package:fribase/controllers/select_controller.dart';
import 'package:fribase/models/quiz_model.dart';
import 'package:fribase/views/screens/result_screen.dart';
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
  final AdvancedDrawerController _advancedDrawerController =
      AdvancedDrawerController();
  int _totalPages = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showCompletionDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog('User not logged in.');
      return;
    }

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
              "Quiz Completed",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            content: Text(
              "You answered ${selectedOptions.count} questions.",
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _retryQuiz(user.uid, selectedOptions.count);
                },
                child: const Text(
                  "Retry",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _saveResults(String uid, int correctAnswers) async {
    final resultsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('results');
    await resultsCollection.add({
      'correctAnswers': correctAnswers,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _retryQuiz(String uid, int correctAnswers) {
    _saveResults(uid, correctAnswers); // Save results before resetting
    _pageController.jumpToPage(0);
    context.read<SelectedOptionsNotifier>().clearSelections();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff041955),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        title: const Text(
          "Error",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

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
          _buildBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: _buildFloatingActionButtons(),
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
                        child: Text("No questions available"),
                      );
                    }
                    final quiz = snapshot.data!.docs;
                    _totalPages = quiz.length;
                    return PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: quiz.length,
                      itemBuilder: (context, index) {
                        final quizItem = Quiz.fromJson(quiz[index]);
                        return QuizCart(
                          index: index,
                          quiz: quizItem,
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
          _buildMenuButton(),
          _buildResultsButton(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xff969EF3),
            Color(0xff041955),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return Positioned(
      top: 50,
      left: 15,
      child: GestureDetector(
        onTap: _handleMenuButtonPressed,
        child: const CircleAvatar(
          backgroundImage: AssetImage("assets/icons/logo.gif"),
          radius: 25,
        ),
      ),
    );
  }

  Widget _buildResultsButton() {
    return Positioned(
      top: 50,
      right: 15,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
          );
        },
        child: const CircleAvatar(
          backgroundImage: AssetImage("assets/icons/lead.png"),
          radius: 25,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            _pageController.previousPage(
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
            _pageController.nextPage(
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
