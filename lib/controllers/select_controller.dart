import 'package:flutter/material.dart';

class SelectedOptionsNotifier extends ChangeNotifier {
  final Map<int, String> _selectedOptions = {};
  int count = 0;

  Map<int, String> get selectedOptions => _selectedOptions;

  final PageController _pageController = PageController();

  PageController get pageController => _pageController;

  void nextPage() {
    _pageController.nextPage(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }
  

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void clearSelections() {
    selectedOptions.clear();
    count = 0;
    notifyListeners();
  }

  void selectOption(int index, String option, bool select) {
    _selectedOptions[index] = option;
    if (select) {
      count++;
    }
    notifyListeners();
  }
}
