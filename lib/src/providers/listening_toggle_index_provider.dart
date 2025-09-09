import 'package:flutter/cupertino.dart';

class ListeningToggleIndexProvider extends ChangeNotifier {
  int selectedIndex = 1;

  void changeIndex(int newIndex) {
    selectedIndex = newIndex;
    notifyListeners();
  }

  void setSelectedIndex(int newIndex) {
    selectedIndex = newIndex;
    notifyListeners();
  }
}
