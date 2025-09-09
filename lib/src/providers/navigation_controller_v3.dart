import 'package:flutter/material.dart';

class NavigationControllerV3 extends ChangeNotifier {
  NavigationControllerV3();

  int _currentPage = 0;
  PageController pageController = PageController(initialPage: 0);

  int get currentPage => _currentPage;

  set currentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }

  void popPage(int pageIndex) {
    _currentPage = pageIndex;
    pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }



  void navigateToPage({int? pageIndex}) {
    _currentPage = pageIndex??1;
    pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }
}
